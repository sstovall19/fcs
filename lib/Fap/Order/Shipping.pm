
=head1 PACKAGE

=over 4

Fap::Order::Shipping

=head1 DESCRIPTION

Uses the Fap::External::SolvingMaze module to determine shipping rates.

=head1 SYNOPSIS

=back

=cut

package Fap::Order::Shipping;
use strict;
use warnings;
use Fap::Model::Fcs;
use Fap::External::SolvingMaze;
use Locale::Country;
use Locale::US;

sub new {
    my ($class) = shift;
    my $self = {
	 db => Fap::Model::Fcs->new(), conf => Fap::ConfLoader->load("bu/shipping") };
    bless $self, ref $class || $class;
    return $self;
}

=head2 calculate()

=over 4

Calculates shipping carrier costs.

Params:

  A valid order_id

Returns:

  Status (0 = failure, 1 = success)

  Error message in $@.

=back

=cut

sub calculate {
    my $self     = shift;
    my $order_id = shift;

    if ( $order_id !~ /(\d+)/ ) {
        return ( "", "calculate() Must pass an order_id", -1 );
    }

    # Remove any existing shipping data from the order_shipping table.
    $self->zap_order_shipping($order_id);

    my $order =
      $self->{'db'}->table("Order")->search( { "me.order_id" => $order_id }, { prefetch => { "order_groups" => { "order_bundles" => "bundle" } } } )->first;
    if ( !defined($order) ) {
        Fap->trace_error("Could not find order information for order_id $order_id");
        return (0);
    }
    foreach my $group ( $order->order_groups ) {
        my ($address) = $self->{'db'}->table("EntityAddress")->search( { 'entity_address_id' => $group->shipping_address_id } );
        if ( !defined($address) ) {
            Fap->trace_error("Could not find address_id for order_id $order_id order_group_id $group->order_group_id");
            return (0);
        }
        my ($rates) = $self->_GetUPSRate( $address, $group );

        if ( !defined($rates) ) {
            Fap->trace_error("Could not get UPS rates for for order_id $order_id order_group_id $group->order_group_id");
            return (0);
        }
        my $retail_rates = $self->_markup( $rates, $group->product_id );
	my $rows=[];
        foreach my $retail_rate ( @{$retail_rates} ) {
		my $service =  $retail_rate->{'carrier'} . " " . $retail_rate->{'service'};
		if (defined $self->{conf}->{methods}->{$service}) {
            		push(@$rows,{
                    		order_group_id => $group->order_group_id,
                    		shipping_text  => $retail_rate->{'carrier'} . " " . $retail_rate->{'service'},
                    		shipping_rate  => $retail_rate->{'customer_rate'} }
	 		);
		}

            }
	$self->{db}->table("OrderShipping")->populate($rows);
        }
    return (1);
}

=head2 zap_order_shipping()

=over 4

Removes order_shipping entries associated with a supplied order_id.

Params:

  A valid order_id

Returns:

  Status (0 = failure, 1 = success)

  Error message in $@.

=back

=cut

sub zap_order_shipping {
    my ($self)     = shift;
    my ($order_id) = shift;

    my $order = $self->{'db'}->table("Order")->search( { "me.order_id" => $order_id }, { prefetch => "order_groups" } )->first;
    if ( !defined($order) ) {
        return;
    }

    foreach my $group ( $order->order_groups ) {
        $self->{'db'}->table("OrderShipping")->search( { order_group_id => $group->order_group_id } )->delete;
    }
    return (1);
}

sub _GetUPSRate {
    my ($self)    = shift;
    my ($address) = shift;
    my ($group)   = shift;

    my $sm = Fap::External::SolvingMaze->new( 'Los Angeles', 'B941SJC7QP42PR7RNSQW' );

    # ISO country code required.

    if ( !defined($address) ) {
        Fap->trace_error("Could not find a valid address!");
        return (undef);
    }

    my $country = country2code( $address->country ) || $address->country;

    my $state = $address->state_prov;

    # United States?  State name must be two letters.
    if ( ( $country =~ /^US$/i ) && ( length($state) > 2 ) ) {
        my $u = Locale::US->new;
        $state = $u->{state2code}{ uc($state) };
    }

    $sm->destination( {
            'country' => $country,
            'region'  => $state,
            'post'    => $address->postal,
            'city'    => $address->city
        } );
    $sm->simplify(1);

    my $shippable = 0;
    foreach my $product ( $group->order_bundles ) {
        next if ( ( !defined( $product->bundle_id ) ) || ( !defined( $product->quantity ) ) || ( $product->quantity !~ /^[0-9]+$/ ) );
        my ($i) = $self->{'db'}->table('bundle_packing')->single( { 'me.bundle_id' => $product->bundle_id } );
        my ($data) = $self->{'db'}->strip($i);
        if ( defined($data) ) {
            my $packable = JSON::XS::true;
            my $filler   = JSON::XS::false;

            # If an item is filler, it is automatically packable.
            if ( $data->{'packing'} eq 'filler' ) {
                $filler   = JSON::XS::true;
                $packable = JSON::XS::true;

                # If an item has a box, it is not packable and not filler.
            } elsif ( $data->{'packing'} eq 'is_boxed' ) {
                $packable = JSON::XS::false;
                $filler   = JSON::XS::false;
            }

            $sm->add_item_detail( {
                    'sku'           => $product->bundle_id,
                    'qty'           => $product->quantity,
                    'name'          => 'fonality product',
                    'weight'        => $data->{'ounces'},
                    'weightUnit'    => 'oz',
                    'unitPrice'     => $product->list_price / $product->quantity,
                    'rotatable'     => JSON::XS::true,
                    'packable'      => $packable,
                    'voidFiller'    => $filler,
                    'dimensionUnit' => 'in',
                    'dimensions'    => [ {
                            'length' => $data->{'l'},
                            'width'  => $data->{'w'},
                            'height' => $data->{'h'} } ] } );
            $shippable++;
        }

    }
    if ($shippable) {
        return ( $sm->get_rates() );
    } else {
        return (0);
    }
}

sub _markup {
    my $self    = shift;
    my $rateref = shift;
    my $product = shift;

    # If we don't have a ref in rateref, the order
    #   does not contain shippable items.
    unless ( ref($rateref) ) {
        return (undef);
    }

    # Default to product_id 9 in the event we aren't passed a product.
    if ( !defined($product) ) {
        $product = 9;
    }

    # Default shipping markup to 30% and minimum of $100 in the event we don't have markup/minimum information.
    my $markup  = ( defined( $self->{'conf'}->{'markup'}->{$product} ) )  ? $self->{'conf'}->{'markup'}->{$product}  : 30;
    my $minimum = ( defined( $self->{'conf'}->{'minimum'}->{$product} ) ) ? $self->{'conf'}->{'minimum'}->{$product} : 100;

    # Apply the markups, apply the minimum shipping price if needed.
    foreach my $rate ( @{$rateref} ) {
        $rate->{customer_rate} = int( $rate->{rate} * ( .01 * $markup ) + $rate->{rate} + 1 );
        if ( $rate->{customer_rate} < $minimum ) {
            $rate->{customer_rate} = $minimum if ( $rate->{customer_rate} < $minimum );
        }
    }

    return ($rateref);
}

1;
