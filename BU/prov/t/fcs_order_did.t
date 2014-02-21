use strict;
use warnings;
use Test::More qw( no_plan );
#use Test::More skip_all=> 'skipping test to avoid devt conflicts';
use Cwd qw( getcwd abs_path );
use File::Basename;
use Fap::StateMachine::Unit;
use Fap::StateMachine::Worker;
use Fap::Model::Fcs;
use Data::Dumper;

#54 - did_number
#55 - did_international
#57 - paperless_fax_did
#58 - did_tollfree
#Setup data
my $fcs_obj = Fap::Model::Fcs->new();
my $dbh = $fcs_obj->dbh();
my $pbxtra_obj = Fap::Model::Fcs->new();
$pbxtra_obj->switch_db('pbxtra');
my $pbxtra_dbh = $pbxtra_obj->dbh();
#Order with LNP but did prefix
#order
$dbh->do("INSERT INTO `orders`(customer_id, contact_id, order_type, record_type) VALUES (1,1,'ADDON','ORDER')"); 
my $order_id_1 =  $dbh->last_insert_id(undef, undef, 'orders','order_id');
#order_group
$dbh->do("INSERT INTO `order_group`(order_id, server_id, shipping_address_id, billing_address_id, product_id) VALUES ($order_id_1,500342,10000,10000,7)");
my $order_group_id_11 = $dbh->last_insert_id(undef, undef, 'order_group', 'order_group_id');
#order_bundle
$dbh->do("INSERT INTO `order_bundle`(bundle_id,order_group_id,quantity,list_price,discounted_price,one_time_total) VALUES (54,$order_group_id_11, 2, '5000.00', '4000.00', '8000.00')");
my $order_bundle_id_111 = $dbh->last_insert_id(undef, undef, 'order_bundle', 'order_bundle_id');
#order_bundle_detail
$dbh->do("INSERT INTO `order_bundle_detail`(order_bundle_id,desired_did_number,is_lnp) VALUES ($order_bundle_id_111, 213, 1)");
$dbh->do("INSERT INTO `order_bundle_detail`(order_bundle_id,desired_did_number,is_lnp) VALUES ($order_bundle_id_111, 213, 1)");

#Order DID but full did number
#orders
$dbh->do("INSERT INTO `orders`(customer_id, contact_id, order_type, record_type) VALUES (1,1,'ADDON','ORDER')"); 
my $order_id_2 =  $dbh->last_insert_id(undef, undef, 'orders','order_id');
#order_group
$dbh->do("INSERT INTO `order_group`(order_id, server_id, shipping_address_id, billing_address_id, product_id) VALUES ($order_id_2,500342,10000,10000,7)");
my $order_group_id_21 = $dbh->last_insert_id(undef, undef, 'order_group', 'order_group_id');
#order_bundle
$dbh->do("INSERT INTO `order_bundle`(bundle_id,order_group_id,quantity,list_price,discounted_price,one_time_total) VALUES (54,$order_group_id_21, 2, '5000.00', '4000.00', '8000.00')");
my $order_bundle_id_211 = $dbh->last_insert_id(undef, undef, 'order_bundle', 'order_bundle_id');
#order_bundle_detail
$dbh->do("INSERT INTO `order_bundle_detail`(order_bundle_id,desired_did_number) VALUES ($order_bundle_id_211, '2134567890')");
$dbh->do("INSERT INTO `order_bundle_detail`(order_bundle_id,desired_did_number) VALUES ($order_bundle_id_211, '2134567890')");

#Valid Order
#order
$dbh->do("INSERT INTO `orders`(customer_id, contact_id, order_type, record_type) VALUES (1,1,'ADDON','ORDER')"); 
my $order_id_3 =  $dbh->last_insert_id(undef, undef, 'orders','order_id');
#order_group
$dbh->do("INSERT INTO `order_group`(order_id, server_id, shipping_address_id, billing_address_id, product_id) VALUES ($order_id_3,500342,10000,10000,7)");
my $order_group_id_31 = $dbh->last_insert_id(undef, undef, 'order_group', 'order_group_id');
#order_bundle
$dbh->do("INSERT INTO `order_bundle`(bundle_id,order_group_id,quantity,list_price,discounted_price,one_time_total) VALUES (54,$order_group_id_31, 2, '5000.00', '4000.00', '8000.00')");
my $order_bundle_id_311 = $dbh->last_insert_id(undef, undef, 'order_bundle', 'order_bundle_id');
#order_bundle_detail
$dbh->do("INSERT INTO `order_bundle_detail`(order_bundle_id,desired_did_number,is_lnp) VALUES ($order_bundle_id_311, 215, 0)");
$dbh->do("INSERT INTO `order_bundle_detail`(order_bundle_id,desired_did_number,is_lnp) VALUES ($order_bundle_id_311, 215, 0)");
#End of Data Setup

use_ok('Fap::StateMachine::Unit');

my $bu = abs_path('../fcs_order_did.pl');
my ( $output, $out, $err, $retval );
=head
$output = Fap::StateMachine::Worker->new( executable=>$bu, input=>"{\"order_id\": $order_id_1}" )->run(-t);
$out = $output->{output};
$retval = $output->{return_code};
$err = $output->{error};
like(
    $err,
    qr/.ERR: LNP request contains invalid DID/,
    "LNP order with DID prefix "
);
=cut
$out = $err = $retval = "";
$output = Fap::StateMachine::Worker->new( executable=>$bu, input=>"{\"order_id\": $order_id_2}" )->run('-t');
$out = $output->{output};
$retval = $output->{return_code};
$err = $output->{error};
like(
    $err,
    qr/.ERR: DID request contains invalid prefix/,
    "DID order with full numbers instead of DID prefix"
);

$output = Fap::StateMachine::Worker->new( executable=>$bu, input=>"{\"order_id\": $order_id_3}" )->run('-t');
$out = $output->{output};
$retval = $output->{return_code};
$err = $output->{error};
ok( $retval == Fap::StateMachine::Unit::BU_CODE_SUCCESS, "Successful submission of order" );
if ($retval == Fap::StateMachine::Unit::BU_CODE_SUCCESS) {
    #Determine the DID numbers provided
    my $rows = $dbh->selectall_arrayref("SELECT did_number from order_bundle_detail where order_bundle_id=$order_bundle_id_311",{ Slice => {} });
    foreach (@$rows) {
       if ($pbxtra_dbh->selectrow_arrayref("SELECT * FROM unbound_map WHERE phone_number=$_->{did_number}",{ Slice => {} })) {
           pass("DID $_->{did_number} found in unbound_map");
       }
       else {
           fail("DID $_->{did_number} not found in unbound_map");
       }

       if ($pbxtra_dbh->selectrow_arrayref("SELECT * FROM phone_numbers WHERE number=$_->{did_number}",{ Slice => {} })) {
           pass("DID $_->{did_number} found in phone_numbers");
       }
       else {
           fail("DID $_->{did_number} not found in phone_numbers");
       }
    }
    $output = Fap::StateMachine::Worker->new( executable=>$bu, input=>"{\"order_id\": $order_id_3}" )->run('-t -r');
    $out = $output->{output};
    $retval = $output->{return_code};
    $err = $output->{error};
    ok( $retval == Fap::StateMachine::Unit::BU_CODE_SUCCESS, "Successful rollback of order" );
    $rows = $dbh->selectall_arrayref("SELECT did_number FROM order_bundle_detail WHERE order_bundle_id=$order_bundle_id_311 AND (did_number = '' OR did_number IS NULL)",{ Slice => {} });
    if ($rows) {
        pass("DID detail in order_bundle_detail with order_bundle_id $order_bundle_id_311 successfully reset");
    }
    else {
        fail("DID detail in order_bundle_detail with order_bundle_id $order_bundle_id_311 not reset");
    }
}
# Data clean up
$dbh->do("DELETE FROM `orders` WHERE order_id = $order_id_1"); 
$dbh->do("DELETE FROM `order_group` WHERE order_group_id = $order_group_id_11"); 
$dbh->do("DELETE FROM `order_bundle` WHERE order_bundle_id = $order_bundle_id_111"); 
$dbh->do("DELETE FROM `order_bundle_detail` WHERE order_bundle_id = $order_bundle_id_111"); 
$dbh->do("DELETE FROM `orders` WHERE order_id = $order_id_2"); 
$dbh->do("DELETE FROM `order_group` WHERE order_group_id = $order_group_id_21"); 
$dbh->do("DELETE FROM `order_bundle` WHERE order_bundle_id = $order_bundle_id_211"); 
$dbh->do("DELETE FROM `order_bundle_detail` WHERE order_bundle_id = $order_bundle_id_211");
$dbh->do("DELETE FROM `orders` WHERE order_id = $order_id_3"); 
$dbh->do("DELETE FROM `order_group` WHERE order_group_id = $order_group_id_31"); 
$dbh->do("DELETE FROM `order_bundle` WHERE order_bundle_id = $order_bundle_id_311"); 
$dbh->do("DELETE FROM `order_bundle_detail` WHERE order_bundle_id = $order_bundle_id_311"); 
# End of Data clean up
1;
