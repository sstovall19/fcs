use strict;
use warnings;

use Data::Dumper;
use Test::More qw( no_plan );
use Cwd qw( getcwd abs_path );
use File::Basename;
use Fap::StateMachine::Unit;
use Fap::StateMachine::Worker;

use_ok('Fap::Model::Fcs');
use_ok('Fap::Model::Pbxtra');
use_ok('Fap::StateMachine::Unit');
my $fcs_schema = Fap::Model::Fcs->new();
my $dbh = $fcs_schema->dbh();

#Setup Data
#order
$dbh->do("INSERT INTO `orders`(customer_id, contact_id, order_type, record_type, order_status_id) VALUES (1,1,'ADDON','ORDER',8)");
my $order_id_1 =  $dbh->last_insert_id(undef, undef, 'orders','order_id');
#order_group
$dbh->do("INSERT INTO `order_group`(order_id, server_id, shipping_address_id, billing_address_id, product_id) VALUES ($order_id_1,500113,10000,10000,7)");
my $order_group_id_11 = $dbh->last_insert_id(undef, undef, 'order_group', 'order_group_id');
#order_bundle
$dbh->do("INSERT INTO `order_bundle`(bundle_id,order_group_id,quantity,list_price,one_time_total) VALUES (54,$order_group_id_11, 2, '5000.00', '8000.00')");
my $order_bundle_id_111 = $dbh->last_insert_id(undef, undef, 'order_bundle', 'order_bundle_id');
#order_bundle_detail
$dbh->do("INSERT INTO `order_bundle_detail`(order_bundle_id,desired_did_number,is_lnp) VALUES ($order_bundle_id_111, 213, 1)");
$dbh->do("INSERT INTO `order_bundle_detail`(order_bundle_id,desired_did_number,is_lnp) VALUES ($order_bundle_id_111, 213, 1)");

#End of setup
my $bu = abs_path('../fcs_mark_order_as_complete.pl');
my ( $input, $output, $out, $err, $retval );
$output = Fap::StateMachine::Worker->new( executable=>$bu, input=>"{\"order_id\": $order_id_1}" )->run('-t');
$out = $output->{output};
$retval = $output->{return_code};
$err = $output->{error};
ok( $retval == Fap::StateMachine::Unit::BU_CODE_SUCCESS,
    "Successfully updated status of order to completed" );
$out = $err = $retval = undef;
$output = Fap::StateMachine::Worker->new( executable=>$bu, input=>"{\"order_id\": $order_id_1}" )->run(-t);
$out = $output->{output};
$retval = $output->{return_code};
$err = $output->{error};
like( $err, qr/.already marked as provisioned./, "Attempted to update an already completed order" );
#Rollback test
$bu = abs_path('../fcs_mark_order_as_complete.pl');
$output = Fap::StateMachine::Worker->new( executable=>$bu, input=>"{\"order_id\": $order_id_1}" )->run('-r -t');
$out = $output->{output};
$retval = $output->{return_code};
$err = $output->{error};
my $order_rollback = $fcs_schema->table('orders')->count({'order_id'=>$order_id_1, 'order_status_id'=>10});
ok( $order_rollback == 1,
    "Successful rollback" );

# Data clean up
$dbh->do("DELETE FROM `orders` WHERE order_id = $order_id_1");
$dbh->do("DELETE FROM `order_group` WHERE order_group_id = $order_group_id_11");
$dbh->do("DELETE FROM `order_bundle` WHERE order_bundle_id = $order_bundle_id_111");
$dbh->do("DELETE FROM `order_bundle_detail` WHERE order_bundle_id = $order_bundle_id_111");

#Verify if rollback did occur
sub _get_server_details {
    my $server_id = shift;
    return $fcs_schema->table('server')->find( { 'server_id' => $server_id } );
}

sub _count_server_bundle {
    my ( $server_id, $bundle_id ) = @_;
    $fcs_schema->table('server_bundle')
      ->count( { 'server_id' => $server_id, 'bundle_id' => $bundle_id } );

}
