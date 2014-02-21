package Fap::External::UPS::Address;

use strict;
use Carp;
use XML::Simple;
use Class::Struct;

struct(
    address             => '$',
    city                => '$',
    postal_code         => '$',
    state               => '$',
    country_code        => '$',
    address_type        => '$',
    is_valid            => '$'
);

*is_exact_match = \&is_match;
sub is_match {
    my $self = shift;
    return unless $self->is_valid();
    return (1);
}

sub cache_id { return $_[0]->postal_code }

sub validate {
    my $self = shift;
    my $args = shift || {};

    require Fap::External::UPS;
    my $ups = Fap::External::UPS->instance();
    return $ups->validate_address($self, $args);
}

sub as_hash {
    my $self = shift;
    unless ( defined $self->postal_code ) {
        croak "as_string(): 'postal_code' is empty";
    }
    my %data = (
        Address => {
            CountryCode => $self->country_code || "US",
            PostalCode  => $self->postal_code,
        }
    );
    if ( defined $self->city ) {
        $data{Address}->{City} = $self->city();
    }
    if ( defined $self->state ) {
        $data{Address}->{StateProvinceCode} = $self->state_province_code;
    }

    return \%data;
}

1;

__END__;

=head1 NAME

Fap::External::UPS::Address - UPS address class

=head1 SYNOPSIS

    use Fap::External::UPS::Address;
    $address = Fap::External::UPS::Address->new();
    $address->address("205 Stillwood Drive");
    $address->city("Wake Forest");
    $address->state("NC");
    $address->postal_code("27587");
    $address->country_code("US");

=head1 DESCRIPTION

Fap::External::UPS::Address is a class representing a shipping address. Valid address attributes are C<address>, C<city>, C<state>, C<postal_code>, C<country_code> and C<address_type>.

If address was run through Address Validation Service, additional attribute C<is_valid> to represent the validity of the match.

=head1 METHODS

In addition to accessor methods documented above, following convenience methods are provided.

=over 4

=item is_match()

When address is returned from Address Validation Service, above attribute can be consulted to find out the quality of the match.

=item validate()

=item validate(\%args)

Validates the address by submitting itself to UPS eXtended Address Validation (XAV) service. For this method to work Fap::External::UPS singleton needs to be created first.

=cut
