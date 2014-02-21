package Fap::External::UPS;

use strict;
use Carp ('croak');
use XML::Simple;
use LWP::UserAgent;
use Fap::External::UPS::ErrorHandler;
use Fap::External::UPS::Address;

@Net::UPS::ISA          = ( "Fap::External::UPS::ErrorHandler" );
$Net::UPS::VERSION      = '0.04';
$Net::UPS::LIVE         = 0;

sub AV_TEST_PROXY   () { 'https://wwwcie.ups.com/ups.app/xml/XAV'      }
sub AV_LIVE_PROXY   () { 'https://onlinetools.ups.com/ups.app/xml/XAV' }

sub live {
    my $class = shift;
    unless ( @_ ) {
        croak "$class->live(): usage error";
    }
    $Fap::External::UPS::LIVE = shift;
}

my $ups = undef;
sub new {
    my $class = shift;
    croak "new(): usage error" if ref($class);

    unless ( (@_ >= 1) || (@_ <= 4) ) {
        croak "new(): invalid number of arguments";
    }
    $ups = bless({
        __userid      => $_[0] || undef,
        __password    => $_[1] || undef,
        __access_key  => $_[2] || undef,
        __args        => $_[3] || {},
        __last_service=> undef
    }, $class);

    unless ( $ups->userid && $ups->password && $ups->access_key ) {
        croak "new(): usage error. Required arguments missing";
    }
    if ( my $cache_life = $ups->{__args}->{cache_life} ) {
        eval "require Cache::File";
        if (my $errstr = $@ ) {
            croak "'cache_life' requires Cache::File module";
        }
        unless ( $ups->{__args}->{cache_root} ) {
            require File::Spec;
            $ups->{__args}->{cache_root} = File::Spec->catdir(File::Spec->tmpdir, 'net_ups');
        }
        $ups->{__cache} = Cache::File->new( cache_root      => $ups->{__args}->{cache_root},
                                            default_expires => "$cache_life m",
                                            cache_depth     => 5,
                                            lock_level      => Cache::File::LOCK_LOCAL()
                                            );
    }
    return $ups;
}

sub instance {
    return $ups if defined($ups);
    croak "instance(): no object instance found";
}

sub av_proxy    { $Fap::External::UPS::LIVE ? AV_LIVE_PROXY   : AV_TEST_PROXY     }
sub cache_life  { return $_[0]->{__args}->{cache_life} = $_[1]          }
sub cache_root  { return $_[0]->{__args}->{cache_root} = $_[1]          }
sub userid      { return $_[0]->{__userid}                              }
sub password    { return $_[0]->{__password}                            }
sub access_key  { return $_[0]->{__access_key}                          }
sub dump        { return Dumper($_[0])                                  }

sub access_as_xml {
    my $self = shift;
    return XMLout({
        AccessRequest => {
            AccessLicenseNumber  => $self->access_key,
            Password            => $self->password,
            UserId              => $self->userid
        }
    }, NoAttr=>1, KeepRoot=>1, XMLDecl=>1);
}

sub transaction_reference {
    return {
        CustomerContext => "Fap::External::UPS",
        XpciVersion     => '1.0001'
    };
}

sub service {
    return $_[0]->{__last_service};
}

sub post {
    my $self = shift;
    my ($url, $content) = @_;

    unless ( $url && $content ) {
        croak "post(): usage error";
    }

    my $user_agent  = LWP::UserAgent->new();
    my $request     = HTTP::Request->new('POST', $url);
    $request->content( $content );
    my $response    = $user_agent->request( $request );
    if ( $response->is_error ) {
        die $response->status_line();
    }
    return $response->content;
}

sub validate_address {
    my $self    = shift;
    my ($address, $args) = @_;

    croak "verify_address(): usage error" unless defined($address);
    
    unless ( ref $address ) {
        $address = {postal_code => $address};
    }
    if ( ref $address eq 'HASH' ) {
        $address = Fap::External::UPS::Address->new(%$address);
    }
    $args ||= {};
    unless ( defined $args->{tolerance} ) {
        $args->{tolerance} = 0.05;
    }
    unless ( ($args->{tolerance} >= 0) && ($args->{tolerance} <= 1) ) {
        croak "validate_address(): invalid tolerance threshold";
    }

    my %data = (
        AddressValidationRequest    => {
            Request => {
                TransactionReference   => {
			CustomerContext => 'Something should go here.',
			XpciVersion => '1.0'
                },
                RequestAction   => 'XAV',
                RequestOption   => '3'
            }
        });

    if ( $address->city ) {
        $data{AddressValidationRequest}->{AddressKeyFormat}->{PoliticalDivision2} = $address->city;
    }

    if ( $address->state ) {
        if ( length($address->state) != 2 ) {
            croak "state has to be two letters long";
        }
        $data{AddressValidationRequest}->{AddressKeyFormat}->{PoliticalDivision1} = $address->state;
    }

    if ( $address->postal_code ) {
        $data{AddressValidationRequest}->{AddressKeyFormat}->{PostcodePrimaryLow} = $address->postal_code;
    }

    if ( $address->country_code ) {
        $data{AddressValidationRequest}->{AddressKeyFormat}->{CountryCode} = $address->country_code;
    } else {
        $data{AddressValidationRequest}->{AddressKeyFormat}->{CountryCode} = 'US';
    }

    if ( $address->address ) {
        $data{AddressValidationRequest}->{AddressKeyFormat}->{AddressLine} = $address->address;
    }

    my $xml = $self->access_as_xml . XMLout(\%data, KeepRoot=>1, NoAttr=>1, KeyAttr=>[], XMLDecl=>1);
    my $response = XMLin($self->post($self->av_proxy, $xml),
                                                KeepRoot=>0, NoAttr=>1,
                                                KeyAttr=>[], ForceArray=>["AddressValidationResponse"]);
    if ( my $error = $response->{Response}->{Error} ) {
        return $self->set_error( $error->{ErrorDescription} );
    }
    my @addresses = ();

    if (defined($response->{AddressKeyFormat})) {
        # If we got an array back, then there are some suggestions.
        # Load them up into an array of UPS::Address objects.
        if (ref($response->{AddressKeyFormat}) eq 'ARRAY') {
            for (my $i=0; $i < @{$response->{AddressKeyFormat}}; $i++ ) {
                my $ref = $response->{AddressKeyFormat}->[$i];
                while ( $ref->{PostalCodeLowEnd} <= $ref->{PostalCodeHighEnd} ) {
                    if (ref($ref->{AddressLine}) eq 'ARRAY') {
                        $ref->{AddressLine} = join("\n", @{$ref->{AddressLine}});
                    }
                    my $address = Fap::External::UPS::Address->new(
                        address         => $ref->{AddressLine},
                        city            => $ref->{PoliticalDivision2},
                        postal_code     => $ref->{PostcodePrimaryLow}."-".$ref->{PostcodeExtendedLow},
                        state           => $ref->{PoliticalDivision1},
                        is_valid        => $ref->{ValidAddressIndicator},
                        address_type    => $ref->{AddressClassification}->{Description},
                        country_code    => $ref->{CountryCode}
                    );
                    push @addresses, $address;
                    $ref->{PostalCodeLowEnd}++;
                }
            }
        } else {
            # We did not get an array.  This could be a failure or a success.

            # Did it fail entirely?  ie No match, No suggestions?
            if ($response->{NoCandidatesIndicator}) {
                my $address = Fap::External::UPS::Address->new(
                        is_valid        => 0
                );
                push @addresses, $address;
            # Is it a valid address?
            } elsif ($response->{ValidAddressIndicator}) {
                if (ref($response->{AddressKeyFormat}->{AddressLine}) eq 'ARRAY') {
                    $response->{AddressKeyFormat}->{AddressLine} = join("\n", @{$response->{AddressKeyFormat}->{AddressLine}});
                }
                my $address = Fap::External::UPS::Address->new(
                        address         => $response->{AddressKeyFormat}->{AddressLine},
                        city            => $response->{AddressKeyFormat}->{PoliticalDivision2},
                        postal_code     => $response->{AddressKeyFormat}->{PostcodePrimaryLow}."-".$response->{AddressKeyFormat}->{PostcodeExtendedLow},
                        state           => $response->{AddressKeyFormat}->{PoliticalDivision1},
                        is_valid        => 1,
                        address_type    => $response->{AddressKeyFormat}->{AddressClassification}->{Description},
                        country_code    => $response->{AddressKeyFormat}->{CountryCode}
                    );
                    push @addresses, $address;
            } else {
                # Something is wrong -- it didn't succeed and didn't fail.  Let's just fail.
                my $address = Fap::External::UPS::Address->new(
                        is_valid        => 0
                );
                push @addresses, $address;
            }
        }
    }
    return \@addresses;
}

1;
__END__

=head1 NAME

Fap::External::UPS - Implementation of UPS Online Tools API in Perl

=head1 SYNOPSIS

    use Fap::External::UPS;
    $ups = Fap::External::UPS->new($userid, $password, $accesskey);

=head1 DESCRIPTION

Fap::External::UPS implements UPS' Address Level Verification Service ("XAV") API in Perl.

=head1 METHODS

Following are the list and description of methods available through Fap::External::UPS. Provided examples may also use other Fap::External::UPS::* libraries and their methods. For the details of those please read their respective manuals. (See L<SEE ALSO|/"SEE ALSO">)

=over 4

=item live ($bool)

By default, all the API calls in Fap::External::UPS are directed to UPS.com's test servers. This is necessary in testing your integration interface, and not to exhaust UPS.com live servers.

Once you want to go live, L<live()|/"live"> class method needs to be called with a true argument to indicate you want to switch to the UPS live interface. It is recommended that you call live() before creating a Fap::External::UPS instance by calling L<new()|/"new">, like so:

    use Fap::External::UPS;
    Fap::External::UPS->live(1);
    $ups = Fap::External::UPS->new($userid, $password, $accesskey);

=item new($userid, $password, $accesskey)

=item new($userid, $password, $accesskey, \%args)

Constructor method. Builds and returns Fap::External::UPS instance. If an instance exists, C<new()> returns that instance.

C<$userid> and C<$password> are your login information to your UPS.com profile. C<$accesskey> is something you have to request from UPS.com to be able to use UPS Online Tools API.

C<\%args>, if present, are the global arguments you can pass to customize Fap::External::UPS instance, and further calls to UPS.com. Available arguments are as follows:

=over 4

=item cache_life

Enables caching, as well as defines the life of cache in minutes.

=item cache_root

File-system location of a cache data. Return value of L<tmpdir()|File::Spec/tempdir> is used as default location.

=back

=item instance ()

Returns an instance of Fap::External::UPS object. Should be called after an instance is created previously by calling C<new()>. C<instance()> croaks if there is no object instance.

=item userid ()

=item password ()

=item access_key ()

Return UserID, Password and AccessKey values respectively

=item *

Fap::External::UPS::Address class instance

=back


    use Fap::External::UPS;
    Fap::External::UPS->live(1);
    my $ups = Fap::External::UPS->new('FONALITY_UPS_ACCOUNT_NAME', 'FONALITY_UPS_PASSWORD', 'FONALITY_UPS_API_KEY');
    my $address = new Fap::External::UPS::Address;
    $address->address("205 Stillwood Drive");
    $address->city("Wake Forest");
    $address->postal_code("27587");
    $address->state("NC");
    $address->country_code("US");
    
    my $addresses = $ups->validate_address($address);
    
    unless ( defined $addresses ) {
        die $ups->errstr;
    }
    
    unless ( @$addresses ) {
        die "Address is not correct, nor are there any suggestions\n";
    }
    
    if ( $addresses->[0]->is_match ) {
        print "Address Matches Exactly!\n";
        for (@$addresses ) {
            printf("%s, %s %s %s %s %s\n", $_->address,  $_->city, $_->state, $_->postal_code, $_->country_code, $_->address_type);
        }
    } else {
        print "Your address didn't match exactly. Following are some valid suggestions\n";
        for (@$addresses ) {
            printf("%s, %s %s %s %s %s\n", $_->address,  $_->city, $_->state, $_->postal_code, $_->country_code, $_->address_type);
        }
    }
    
=pod

=back

=head1 SEE ALSO

L<Net::UPS::Address|Net::UPS::Address>

=back

=cut
