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
my $bu = abs_path('../fcs_verify_order.pl');
ok(defined($bu), 'BU command identified');

my ($order_id) = load_test_data($fcs_schema);
$input = '{"order_id" : ' . $order_id . '}';

my $order = Fap::Order->new('order_id' => $order_id, 'fcs_schema' => $fcs_schema);
$order->set_billing_approval_status('Required');
$order->set_credit_approval_status('Required');
$order->set_manager_approval_status('Required');

#   ***** Test Approval Notification, SM HALT and pickup with approval *****

# Run the BU, make sure we halted and set Credit Approval to Pending.
testpending('Halting for credit check','Successful Run.  Halted for credit check..', 'credit_approval_status');

# Set the Credit Approval to Approved.
ok($order->set_credit_approval_status('Approved'), 'Set Credit Approval to Approved');

# Run the BU, make sure we halted and set Manager Approval to Pending.
testpending('Halting for manager approval','Successful Run.  Halted for manager approval..', 'manager_approval_status');

# Set the Manager Approval to Approved.
ok($order->set_manager_approval_status('Approved'), 'Set Credit Approval to Approved');

# Run the BU, make sure we halted and set Billing Approval to Pending.
testpending('Halting for billing approval','Successful Run.  Halted for billing approval..', 'billing_approval_status');

#   ***** Test Rejection *****

# Credit Approval Rejected.
ok($order->set_credit_approval_status('Rejected'), 'Set Credit Approval to Rejected');
testrejection('Halting due to credit rejection');
ok($order->set_credit_approval_status('Approved'), 'Set Credit Approval to Approved');

# Manager Rejection.
ok($order->set_manager_approval_status('Rejected'), 'Set Manager Approval to Rejected');
testrejection('Halting due to manager rejection');
ok($order->set_manager_approval_status('Approved'), 'Set Manager Approval to Approved');

# Billing Rejection.
ok($order->set_billing_approval_status('Rejected'), 'Set Billing Approval to Rejected');
testrejection('Halting due to billing rejection');
ok($order->set_billing_approval_status('Approved'), 'Set Billing Approval to Approved');

ok($order->set_billing_approval_status('In Progress') &&  $order->set_credit_approval_status('In Progress') && $order->set_manager_approval_status('In Progress'),"Set all order information to In Progress");

# Run the BU in rollback.
$output = Fap::StateMachine::Worker->new( executable => $bu, input => $input )->run('-r -t');
ok($output->{'return_code'} eq Fap::StateMachine::Unit::BU_CODE_SUCCESS, 'Successful Rollback.  execute() returned success.');

my $orderDetails = $order->get_details();
ok($orderDetails->{order}->{billing_approval_status}->{name} eq 'Required',"Billing approval status is now Required.");
ok($orderDetails->{order}->{manager_approval_status}->{name} eq 'Required',"Manager approval status is now Required.");
ok($orderDetails->{order}->{credit_approval_status}->{name}  eq 'Required',"Credit approval status is now Required.");

## Cleanup.

ok($fcs_schema->table('Order')->search({'order_id' => $order_id})->delete,'Cleaned up our mess!');

exit;

sub testrejection {
    my ($search) = shift;
    ok($order->set_status('In Progress'),'Set order_status to In Progress.');
    my $output = Fap::StateMachine::Worker->new( executable => $bu, input => $input )->run('-t');
    my $order = Fap::Order->new('order_id' => $order_id, 'fcs_schema' => $fcs_schema);
    my $orderDetails = $order->get_details();
    ok($output->{'return_code'} eq Fap::StateMachine::Unit::BU_CODE_HALT, 'Successful Run.  execute() returned HALT.');
    ok($output->{'output'} =~ /$search/, "Successful Run.  $search");
}

sub testpending {
    my ($search) = shift;
    my ($display) = shift;
    my ($item) = shift;
    my $output = Fap::StateMachine::Worker->new( executable => $bu, input => $input )->run('-t');
    my $order = Fap::Order->new('order_id' => $order_id, 'fcs_schema' => $fcs_schema);
    my $orderDetails = $order->get_details();
    ok($output->{'return_code'} eq Fap::StateMachine::Unit::BU_CODE_HALT, 'Successful Run.  execute() returned HALT.');
    ok($output->{'output'} =~ /$search/, $display);
    ok($orderDetails->{order}->{$item}->{name} eq 'Pending', "Successful Run:  $item is now Pending.");
}

sub load_test_data {
    my ($fcs_schema) = shift;

    my $order = $fcs_schema->table('Order')->create( {
                                                        order_type                 => 'NEW',
                                                        record_type                => 'QUOTE',
                                                        company_name               => 'Veridian Dynamics (FON TEST)',
                                                        website                    => 'http://www.youtube.com/playlist?list=PL40FCDF2860CD4AB3',
                                                        industry                   => 'Veridian Dynamics: We Make That',
                                                        netsuite_lead_id           => 0,
                                                        order_status_id            => 7,
                                                        netsuite_salesperson_id    => 7,
                                                        provisioning_status_id     => 1,
                                                        proposal_pdf               => 'http://www.fonality.com/proposal.pdf',
                                                        contact_id=> 1,
                                             } );

    my $group = $fcs_schema->table('OrderGroup')->create ( {
                                                             order_id=> $order->order_id,
                                                             shipping_address_id=> 1,
                                                             billing_address_id=> 1,
                                                             product_id=> 8,
                                                         } );

    return($order->order_id);
}
