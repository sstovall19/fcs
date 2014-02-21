
=head1 PACKAGE

=over 4

Fap::SolvingMaze

=head1 DESCRIPTION

Implementation of necessary bits of the SolvingMaze shipping and boxing API.

=head1 SYNOPSIS

=back

=cut

package Fap::External::SolvingMaze;
use strict;
use warnings;
use JSON::XS;
use Try::Tiny;
use LWP::UserAgent;

=head2 new()

=over 4

Params:

  warehouse	- SolvingMaze Warehouse Identifier
  key		- SolvingMaze API Key

Returns:

  An object of this class.

=back

=cut

sub new {
    my ($class) = shift;
    my $self = { warehouse => shift || 'UNDEF', key => shift || 'UNDEF' };
    $self->{'JSON'}     = JSON::XS->new->ascii->pretty->allow_nonref;
    $self->{'simplify'} = 0;
    bless $self, ref $class || $class;
    return $self;
}

=head2 destination()

=over 4

Sets the destination for a shipment.

Params:

  destination           - hashref containing destination address information:
				country - country
				region	- state
				post	- postal code
				city	- city

Returns:

  Nothing.

=back

=cut

sub destination {
    my ($self)        = shift;
    my ($destination) = shift;
    $self->{'destination'}->{'country'} = $destination->{'country'} || "UNDEF";
    $self->{'destination'}->{'region'}  = $destination->{'region'}  || "UNDEF";
    $self->{'destination'}->{'post'}    = $destination->{'post'}    || "UNDEF";
    $self->{'destination'}->{'city'}    = $destination->{'city'}    || "UNDEF";
    $self->{'destination'}->{'residential'} = JSON::XS::false;
}

=head2 simplify()

=over 4

Determines whether or not SolvingMaze output is simplified or full.

Params:

  1	- return simplified output.
  0	- return full output (default).


Returns:

  Nothing.

=back

=cut

sub simplify {
    my ($self)  = shift;
    my ($value) = shift;
    $self->{'simplify'} = $value;
}

=head2 add_item()

=over 4

Adds an item to the package.

Params:

  quantity	- Quantity of this item.
  sku		- SKU number.

Returns:

  Nothing.

=back

=cut

sub add_item {
    my ($self) = shift;
    my $qty    = shift;
    my $sku    = shift;
    push( @{ $self->{itemarray} }, { 'sku' => $sku, 'qty' => $qty } );
}

=head2 add_item_detail()

=over 4

Add an item to a package manually, specifying all metadata.

    Args: infomation_structure (see below)
 Returns: 1=success | undef=error

 Example: SolvingMaze::add_item_detail(
        {
                'sku' => 191,
                'qty' => 1,
                'name' => 'Extra Large Widget',
                'weight' => 6.2,
                'weightUnit' => 'oz',
                'unitPrice' => 4.98,
		'rotatable' => JSON::XS::true,
		'packable' => JSON::XS::true,
		'voidFiller' => JSON::XS::true,
                'dimensionUnit' => 'in',
                'dimensions' => { 'length' => 6, 'width' => 2, 'height'=> 6 }
        }
 );

 See also:   http://www.solvingmaze.com/apidoc

=back

=cut

sub add_item_detail {
    my ($self) = shift;
    my $ref = shift;
    unless ( ref($ref) eq 'HASH' ) {
        Fap->trace_error("Requires hashref argument");
        return undef;
    }

    push( @{ $self->{itemarray} }, { %{$ref} } );
    return (1);
}

=head2 get_rates()

=over 4

  Requests box packaging, sizing, weights, number of packages and shipping rates via SolvingMaze.com.

Params:

  None.

Returns:

  Simplified:  An arrayref of services and rates.
  Regular:  A hashref of packaging, services and rates.

Errors:

  Returns undefined and stores error information in $@.

=back

=cut

sub get_rates {
    my ($self) = shift;
    my $ua = LWP::UserAgent->new();
    $ua->timeout(300);
    $ua->agent('Fonality FAP/0.1');

    my $dest_json  = $self->{'JSON'}->encode( $self->{'destination'} );
    my $items_json = $self->{'JSON'}->encode( $self->{'itemarray'} );

    my $res = $ua->post(
        'http://api.solvingmaze.com/calculate',
        Content_Type => 'form-data',
        Content      => [
            warehouse   => '"' . $self->{'warehouse'} . '"',
            key         => '"' . $self->{'key'} . '"',
            destination => $dest_json,
            items       => $items_json
        ] );
    if ( $res->is_success ) {
        my $data;
        try {
            $data = $self->{'JSON'}->decode( $res->decoded_content );
        }
        catch {
            Fap->trace_error("Received invalid or empty JSON data from SolvingMaze.");
            return (undef);
        };

        if ( ( defined( $data->{'status'}->{'success'} ) ) && ( $data->{'status'}->{'success'} == 0 ) ) {
            if ( ref( $data->{'status'}->{'messages'} ) eq 'ARRAY' ) {
                Fap->trace_error("@{$data->{'status'}->{'messages'}}");
            } else {
                Fap->trace_error($data->{'status'}->{'messages'});
            }
            return (undef);
        }

        if ( $self->{'simplify'} ) {
            foreach my $item ( @{ $data->{'services'} } ) {
                delete $item->{'status'};
                delete $item->{'packing'};
            }
            return ( \@{ $data->{'services'} } );
        } else {
            return ($data);
        }
    } else {
        Fap->trace_error($res->status_line.$res->decoded_content);
        return (undef);
    }
}

1;
