use strict;
use warnings;

use Test::More qw( no_plan );
use Cwd qw( getcwd abs_path );
use File::Basename;
use Fap::StateMachine::Unit;
use F::Database;
use Fap::StateMachine::Worker;
use Fap::Model::Fcs;

#Setup data
my $fcs_obj = Fap::Model::Fcs->new();
my $dbh = $fcs_obj->dbh();
=head
#bundle_feature
my $sth = $dbh->prepare("INSERT INTO `bundle_feature`(bundle_id, feature_id) VALUES(89,16) ON DUPLICATE KEY UPDATE bundle_id=89, feature_id=16");
$sth->execute();
#order
$sth = $dbh->prepare("INSERT INTO `orders`(order_id, customer_id, contact_id, order_type, record_type) VALUES (80,1,1,'ADDON','ORDER') ON DUPLICATE KEY UPDATE customer_id=1, contact_id=1,order_type='ADDON',record_type='ORDER'");
$sth->execute();
$sth = $dbh->prepare("INSERT INTO `orders`(order_id, customer_id, order_type, record_type) VALUES (81,29179,'ADDON','ORDER') ON DUPLICATE KEY UPDATE customer_id=29179, order_type='ADDON',record_type='ORDER'");
$sth->execute();

#order_group
$sth = $dbh->prepare("INSERT INTO `order_group`(order_group_id, order_id, server_id, shipping_address_id, billing_address_id, product_id) VALUES (80,80,18800,10000,10000,6) ON DUPLICATE KEY UPDATE order_id=80, server_id=18800, shipping_address_id=10000, billing_address_id=10000, product_id=6");
$sth->execute();

#order_bundle
$sth = $dbh->prepare("INSERT INTO `order_bundle`(order_bundle_id,bundle_id,order_group_id,quantity,list_price,unit_price,one_time_total) VALUES (80,89,80,2,'5000.00','4000.00','8000.00') ON DUPLICATE KEY UPDATE bundle_id=89, order_group_id=80, quantity=2");
$sth->execute();
#End of Data Setup
=cut

use_ok('Fap::StateMachine::Unit');

my $bu = abs_path('../fcs_add_conference_bridge.pl');
my ( $output, $out, $err, $retval );

$output = Fap::StateMachine::Worker->new( executable=>$bu, input=>"{\"order_id\": 81}" )->run();
$out = $output->{output};
$retval = $output->{return_code};
$err = $output->{error};
like(
    $err,
    qr/.ERR: No order found with order id/,
    "Order without order group entries"
);
$out = $err = $retval = "";

$output = Fap::StateMachine::Worker->new( executable=>$bu, input=>"{\"order_id\": 80}" )->run();
$out = $output->{output};
$retval = $output->{return_code};
$err = $output->{error};

ok( $retval == Fap::StateMachine::Unit::BU_CODE_SUCCESS, "Successful submission of order" );
my $order = $out;
$out = $err = $retval = "";
$bu = abs_path('../fcs_add_conference_bridge.pl');
$output = Fap::StateMachine::Worker->new( executable=>$bu, input=>$order )->run('-r');
$out = $output->{output};
$retval = $output->{return_code};
$err = $output->{error};
ok( $retval == Fap::StateMachine::Unit::BU_CODE_SUCCESS, "Successful rollback procedure" );

sub _read_file {
    my $filename = shift;
    open FILE, "<$filename";
    my $content = do { local $/; <FILE> };
    close FILE;
    return $content;
}
