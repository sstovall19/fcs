package Fap::Customer;

use strict;
use Fap::Model::Fcs;
use Fap::Model::Pbxtra;


=head2 new

=over 4

Create a new instance of Customer object

Args: customer_id
Returns: $self

=back

=cut

sub new {
    my $subname = 'Fap::Customer::new';
    my ( $class, %args ) = @_;
    my $fcs_schema    = Fap::Model::Fcs->new();
    my $self          = bless {
        customer_id   => $args{customer_id},
        fcs_schema    => $fcs_schema,
    }, $class;
    $self->{'details'} = $self->get();

    return $self;
}

=head2 get

=over 4

Derives a hashmap of customer details.  This is being called in the object instantiation

Returns: hash of customer details

=back

=cut

sub get {
    my $self   = shift;
    my $rec    = $self->{'fcs_schema'}->table('Customer')->find( { "me.customer_id" => $self->{'customer_id'} } );
    my $customer = ( $self->{'fcs_schema'}->strip($rec) );

    foreach my $id (keys %{$self->get_servers()}) {
        push @{$customer->{'servers'}}, $id;
    }
	
    return $customer;
}

=head2 get_servers

=over 4

Retrieves a list of servers belonging to this customer

Args: None
Returns: has with server ids as keys
=back

=cut

sub get_servers {
    my $self = shift;
    my $rs_server = $self->{'fcs_schema'}->table('Server')->search( { 'customer_id' => $self->{'customer_id'} }, { columns => ['server_id'] } );
    my $customer_server_id;
    while ( my $tmp_server = $rs_server->next ) {
        $customer_server_id->{ $tmp_server->get_column('server_id') } = 1;
    }

    return $customer_server_id;
}

=head2 get_attribute

=over 4

Accesses database through dbix and returns the values of the fields requested

Args: array reference of fieldnames in customer table
Returns: hashref of field values

=back

=cut

sub get_attribute {
    my $self      = shift;
    my $attribute = shift;
	
    return { $self->{'fcs_schema'}->table('Customer')->find( { customer_id => $self->{'customer_id'}, { columns => @{$attribute} } } )->get_inflated_columns() };
}

1;
