
=head1 PACKAGE

=over 4

Fap::Order::Convert

=head1 DESCRIPTION

Module to support the conversion of a quote to an order.

=head1 SYNOPSIS

=back

=cut

package Fap::Order::Convert;
use strict;
use warnings;
use Fap::Model::Fcs;
use Fap::Order;

sub new {
    my ($class, %args) = @_;

    if ($args{order_id} !~ /^\d\d*$/)
    {
        Fap->trace_error("order_id value is invalid");
        return undef;
    }

    my $fcs_schema = $args{fcs_schema}||Fap::Model::Fcs->new();
    my $order = Fap::Order->new('order_id' => $args{order_id}, 'fcs_schema' => $fcs_schema);

    my $self = { fcs_schema	=> $fcs_schema,
                 order		=> $order,
                 order_id	=> $args{order_id},
                 order_data	=> $order->get_details()
               };
    bless $self, ref $class || $class;
    return $self;
}

=head2 create_pbxtra()

=over 4

Creates the PBXtra customer from the FCS customer.

Params:

Returns:

  Status (0 = failure, 1 = success)

  Error message in $@.

=back

=cut

sub create_pbxtra {
    my ($self) = shift;

    # We need a valid netsuite_id.
    #      TODO:  This is commented out because all/most netsuite_id is invalid in the fcs db.
    #unless ($self->{order_data}->{order}->{contact}->{netsuite_id})
    #{
        #Fap->trace_error('ERR: Invalid netsuite id -- but continuing anyway..');
        #return(0);
    #}

    # We need a valid order_id.
    unless ($self->{order_data}->{order}->{order_id})
    {
        Fap->trace_error('ERR: Invalid order id.');
        return(0);
    }

    # We need a valid shipping_address_id.
    unless ($self->{order_data}->{order}->{order_groups}->[0]->{shipping_address_id})
    {
        Fap->trace_error('ERR: Invalid shipping address id.');
        return(0);
    }

    my $customer;
    $customer->{netsuite_id}            = $self->{order_data}->{order}->{contact}->{netsuite_id};
    $customer->{name}                   = $self->{order_data}->{order}->{company_name};
    $customer->{can_link_servers}       = $self->{order_data}->{order}->{can_link_server} || 0;
    # Main address is supplied in the first order_groups -- This should probably be revisited.
    $customer->{main_address_id}        = $self->{order_data}->{order}->{order_groups}->[0]->{shipping_address_id};
    $customer->{created}                = $self->{order_data}->{order}->{created};
    $customer->{order_date}             = $self->{order_data}->{order}->{created};
    $customer->{reseller_id}            = $self->{order_data}->{order}->{reseller_id};
    $customer->{website}                = $self->{order_data}->{order}->{website};
    $customer->{industry}               = $self->{order_data}->{order}->{industry};

    $self->{order_data}->{order}->{customer_id} = $self->{fcs_schema}->strip($self->{fcs_schema}->table('Customer')->find_or_create($customer))->{customer_id};
    # Update our customer_id in fcs.orders with the one in pbxtra.customer.  This is critical for rollback.
    $self->{fcs_schema}->table('Order')->search({'order_id' => $self->{order_id}})->update({'customer_id' => $self->{order_data}->{order}->{customer_id}});
    return(1);
}

=head2 convert_record()

=over 4

Converts an FCS record from one type to another (ie QUOTE to ORDER).

Params:

Returns:

  Status (0 = failure, 1 = success)

  Error message in $@.

=back

=cut

sub convert_record {
    my ($self) = shift;
    my ($type) = shift;

    if ($self->{order_data}->{order}->{record_type} eq $type) {
        Fap->trace_error("ERR: This record is already a $type.");
        return(undef);
    }
    return($self->{fcs_schema}->table('Order')->search({'order_id' => $self->{order_id}})->update({'record_type' => $type}));
}

=head2 drop_abandoned_customer()

=over 4

Drops a customer record from FCS and PBXtra databases ONLY if the customer does not have any servers associated.

Params:

Returns:

  Status (0 = failure, 1 = success)

  Error message in $@.

=back

=cut

sub drop_abandoned_customer {
    my ($self) = shift;

    # If there customer_id is already NULL, just kick back.  There's nothign to see here.
    if (!defined($self->{order_data}->{order}->{customer_id})) {
        return(1);
    }

    # Is the pbxtra.customer.customer_id associated with any servers?  If so, do nothing.
    my $ret = $self->{fcs_schema}->table('Server')->search('customer_id' => $self->{order_data}->{order}->{customer_id})->first;
    if (defined($ret->{server_id})) {
        Fap->trace_error("Warning: Customer is not abandoned -- found associated server ($ret->{server_id}).");
        return(0);
    }

    # Drop the pbxtra.customer record.
    $self->{'fcs_schema'}->table("Customer")->search( { customer_id => $self->{order_data}->{order}->{customer_id} } )->delete;
    # Zap the customer_id in fap.orders.
    $self->{fcs_schema}->table('Order')->search({'order_id' => $self->{order_id}})->update({'customer_id' => \'NULL'});
    return(1);
}

1;
