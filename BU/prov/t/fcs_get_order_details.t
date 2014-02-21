use strict;
use warnings;

use Test::More skip_all => 'Tests not needed anymore since BUs will have id-only inputs';
use Test::More qw( no_plan );
use Cwd qw( getcwd abs_path );
use File::Basename;
use Fap::StateMachine::Unit;
use SM::Test qw(
  spawnUnit
);
use F::Database;

use_ok('Fap::StateMachine::Unit');

#Ensure test data is available
my $dbh = F::Database::mysql_connect_fcs();
=head
#entity_address
my $sth = $dbh->prepare("INSERT INTO `entity_address` VALUES (20000,'Fonality PH Branch','shipping','28th floor Robinsons Summit','Paseo de Roxax cor Ayala','Makati',NULL,'1673','PH')");
$sth->execute();
$sth = $dbh->prepare("INSERT INTO `entity_address` VALUES (10000,'Fonality PH Branch','shipping','28th floor Robinsons Summit','Paseo de Roxax cor Ayala','Makati',NULL,'1673','PH')");
$sth->execute();

#orders
$sth = $dbh->prepare("INSERT INTO `orders`(order_id, customer_id, order_type, record_type) VALUES (52914,29179,'ADDON','ORDER')");
$sth->execute();
$sth = $dbh->prepare("INSERT INTO `orders`(order_id, customer_id, order_type, record_type) VALUES (52915,29179,'ADDON','ORDER')");
$sth->execute();
$sth = $dbh->prepare("INSERT INTO `orders`(order_id, customer_id, order_type, record_type) VALUES (52916,29179,'ADDON','ORDER')");
$sth->execute();

#order_group
$sth = $dbh->prepare("INSERT INTO `order_group`(order_group_id, order_id, server_id, shipping_address_id, billing_address_id, product_id) VALUES (10000,52914,15037,10000,10000,6)");
$sth->execute();
$sth = $dbh->prepare("INSERT INTO `order_group`(order_group_id, order_id, server_id, shipping_address_id, billing_address_id, product_id) VALUES (20000,52915,18800,20000,20000,NULL)");
$sth->execute();
$sth = $dbh->prepare("INSERT INTO `order_group`(order_group_id, order_id, server_id, shipping_address_id, billing_address_id, product_id) VALUES (30000,52916,18800,20000,20000,NULL)");
$sth->execute();

#order_bundle
$sth = $dbh->prepare("INSERT INTO `order_bundle`(order_bundle_id,bundle_id,order_group_id,quantity,list_price,unit_price,one_time_total) VALUES (10000,54,10000,2,'5000.00','4000.00','8000.00')");
$sth->execute();
$sth = $dbh->prepare("INSERT INTO `order_bundle`(order_bundle_id,bundle_id,order_group_id,quantity,list_price,unit_price,one_time_total) VALUES (20001,55,20000,3,'100.00','33.50','100.00')");
$sth->execute();
$sth = $dbh->prepare("INSERT INTO `order_bundle`(order_bundle_id,bundle_id,order_group_id,quantity,list_price,unit_price,one_time_total) VALUES (20000,55,20000,3,'100.00','33.50','100.00')");
$sth->execute();
$sth = $dbh->prepare("INSERT INTO `order_bundle`(order_bundle_id,bundle_id,order_group_id,quantity,list_price,unit_price,one_time_total) VALUES (30000,54,30000,2,'5000.00','4000.00','8000.00')");
$sth->execute();

#order_bundle_detail
$sth = $dbh->prepare("INSERT INTO `order_bundle_detail`(order_bundle_detail_id,order_bundle_id,extension_number,did_number,lnp) VALUES (1000,10000,123,'123',1)");
$sth->execute();
$sth = $dbh->prepare("INSERT INTO `order_bundle_detail`(order_bundle_detail_id,order_bundle_id,extension_number,did_number,lnp) VALUES (10000,10000,23,'6652122',1)");
$sth->execute();
$sth = $dbh->prepare("INSERT INTO `order_bundle_detail`(order_bundle_detail_id,order_bundle_id,extension_number,did_number,lnp) VALUES (20000,20000,1234,NULL,1)");
$sth->execute();
$sth = $dbh->prepare("INSERT INTO `order_bundle_detail`(order_bundle_detail_id,order_bundle_id,extension_number,did_number,lnp) VALUES (20001,20001,20001,NULL,1)");
$sth->execute();

#End of setup
=cut
my $bu = abs_path('../fcs_get_order_details.pl');
my ( $out, $err, $retval );
( $out, $err, $retval ) = spawnUnit( $bu, "{\"order_id\": 52914}" );
ok( $err eq '', "Successful retrieval of order details" );

( $out, $err, $retval ) = spawnUnit( $bu, "{\"no_order_id\": 123}" );
ok( !$out, "Empty output for empty json." );
like( $err, qr/ERR: Missing order_id./, "Empty order_id input" );

( $out, $err, $retval ) = spawnUnit( $bu, "{\"order_id\": 123}" );
like(
    $err,
    qr/ERR: Cannot find order with Order ID 123./,
    "Cannot find order_id in database"
);

( $out, $err, $retval ) = spawnUnit( $bu, "{\"order_id\": 52915}" );
like( $err, qr/.ERR: LNP with no phone number./, "LNP with no phone number" );
like(
    $err,
    qr/.ERR: DID Area Code not specified./,
    "DID area code not specified"
);

#Currently commented while waiting for database design modification
#like($err,qr/.ERR: Missing Server ID./,"Missing Server ID for ADDON");
( $out, $err, $retval ) = spawnUnit( $bu, "{\"order_id\": 52916}" );
like( $err, qr/.ERR: No details found./, "Order Detail not found" );
