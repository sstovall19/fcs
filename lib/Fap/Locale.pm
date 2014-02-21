package Fap::Locale;

use strict;
use Fap;
use Fap::Global;
use DateTime::TimeZone;
use Locale::SubCountry;

=head2 get_timezone

=over 4

Retrieves the appropriate timezone

Args: country_cide, state_code
Returns: timezone or undef if invalid

=back

=cut

sub get_timezone {
    my ( $self, $country_code, $state_code ) = @_;
    if ( !$country_code ) {
        Fap->trace_error('Undefined Country Code');
        return undef;
    }
    my @valid_timezone = DateTime::TimeZone->names_in_country($country_code);
    if ( scalar(@valid_timezone) == 0 ) {
        Fap->trace_error('Invalid Country Code');
        return undef;
    } elsif ( scalar(@valid_timezone) == 1 ) {

        #Country code enough to determine timezone
        return $valid_timezone[0];
    } else {

        #Multiple timezones returned for this country, using state code to derive timezone
        my $state = get_state_name( $country_code, $state_code );
        if ($state) {
            $state =~ s/\s+/_/g;
            $state = lc($state);
            my @timezone = grep( /.*$state.*/, @valid_timezone );
            if ( scalar(@timezone) == 0 ) {

                #Since we found no match in regex, lets return the most common timezone
                return $valid_timezone[0];
            } else {
                return $timezone[0];
            }
        } else {

            #Since we didnt get any state information, let's just get the first entry in the array - the most common as per documentation
            return $valid_timezone[0];
        }
    }

}

=head2 get_state_name

=over 4

Retrieve state name given country code and state code

Args: country code, state code
Returns: state name or undef on error 

=back

=cut

sub get_state_name {
    my ( $self, $country_code, $state_code ) = @_;
    my $obj_code = new Locale::SubCountry($country_code);
    if ( !$obj_code ) {
        Fap->trace_error('Invalid Country');
        return undef;
    }
    my $state = $obj_code->full_name($state_code);
    if ( !$state ) {
        Fap->trace_error('Invalid State Code');
        return undef;
    }
    return $state;
}

=head2 get_language

=over 4

Retrieve the default language given a country code

Args: country code
Returns: language, default to english

=back

=cut

sub get_language {
    my ($self, $country_code) = shift;
    if ( lc($country_code) eq 'jp' ) {
        return {Fap::Global::kCOUNTRY_LANGUAGE}->{'jp'};
    } elsif ( lc($country_code) eq 'au' ) {
        return Fap::Global::kCOUNTRY_LANGUAGE->{'au'};
    } else {
        return Fap::Global::kCOUNTRY_LANGUAGE->{'default'};
    }
}

1;
