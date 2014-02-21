use strict;
use warnings;
use Test::More qw( no_plan );
use Cwd qw( getcwd abs_path );
use File::Basename;
use Fap::StateMachine::Unit;
use Fap::StateMachine::Worker;
use Fap::Order;

use_ok('Fap::StateMachine::Unit');
use_ok('Fap::Order::Convert');

my ( $output, $input );
my $fcs_schema = Fap::Model::Fcs->new();

my $bu = abs_path('../fcs_create_order.pl');
ok(defined($bu), 'BU command identified');

my ($order_id) = load_test_data($fcs_schema);
$input = '{"order_id" : ' . $order_id . '}';

# Run the BU.

$output = Fap::StateMachine::Worker->new( executable => $bu, input => $input )->run('-t');
ok($output->{'return_code'} eq Fap::StateMachine::Unit::BU_CODE_SUCCESS, 'Successful Run.  execute() returned success.');
my $fcs_details = order_details_fcs($order_id, $fcs_schema);
my $pbxtra_details = order_details_pbxtra($fcs_details->{order}->{customer_id}, $fcs_schema);

# Main tests.

ok($pbxtra_details->{customer_id} > 0, "FCS customer_id is valid ( $pbxtra_details->{customer_id} ).");
ok($fcs_details->{order}->{customer_id} == $pbxtra_details->{customer_id}, 'FCS.orders.customer_id and PBXTRA.customer.customer_id match.');
ok($fcs_details->{order}->{record_type} eq 'ORDER', 'FCS orders.record_type is now ORDER.');


# Run the BU in rollback.
$output = Fap::StateMachine::Worker->new( executable => $bu, input => $output->{output} )->run('-r -t');
ok($output->{'return_code'} eq Fap::StateMachine::Unit::BU_CODE_SUCCESS, 'Successful Rollback.  execute() returned success.');
$fcs_details = order_details_fcs($order_id, $fcs_schema);
$pbxtra_details = order_details_pbxtra($fcs_details->{order}->{customer_id}, $fcs_schema);

# Rollback tests.
ok(! $pbxtra_details->{customer_id}, 'pbxtra customer row is gone.');
ok(! $fcs_details->{order}->{customer_id}, 'FCS customer_id is null.');
ok ($fcs_details->{order}->{record_type} eq 'QUOTE','FCS record_type is back to QUOTE.');

# Cleanup.

$fcs_schema->table('Order')->search({'order_id' => $order_id})->delete;

exit;

sub order_details_fcs {
    my ($order_id) = shift;
    my ($fcs_schema) = shift;

    my $order = Fap::Order->new('order_id' => $order_id, 'fcs_schema' => $fcs_schema);
    return($order->get_details);
}

sub order_details_pbxtra {
    my ($customer_id) = shift;
    my ($fcs_schema) = shift;

    return($fcs_schema->strip($fcs_schema->table('Customer')->find({ 'customer_id' => $customer_id })));
}

sub load_test_data {
    my ($fcs_schema) = shift;

    my $order = $fcs_schema->table('Order')->create( {
                                                        order_type		=> 'NEW',
                                                        record_type		=> 'QUOTE',
                                                        company_name		=> 'Veridian Dynamics (FON TEST)',
                                                        website			=> 'http://www.youtube.com/playlist?list=PL40FCDF2860CD4AB3',
                                                        industry		=> 'Veridian Dynamics: We Make That',
                                                        netsuite_lead_id	=> 0,
                                                        order_status_id		=> 7,
                                                        provisioning_status_id	=> 1,
                                                        contact_id		=> 1,
                                             } );

    my $order_id = $order->order_id;

    my $group = $fcs_schema->table('OrderGroup')->create ( {
                                                             order_id			=> $order_id,
                                                             shipping_address_id	=> 1,
                                                             billing_address_id		=> 1,
                                                             product_id			=> 8,
                                                         } );

    return($order->order_id);
}
