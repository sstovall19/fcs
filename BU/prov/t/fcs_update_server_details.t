use strict;
use warnings;

use Test::More qw( no_plan );
use Cwd qw( getcwd abs_path );
use File::Basename;
use Fap::StateMachine::Unit;
use F::Database;
use Fap::StateMachine::Worker;
use Data::Dumper;

use_ok('Fap::Model::Fcs');
use_ok('Fap::Model::Pbxtra');
use_ok('Fap::StateMachine::Unit');
my $bu = abs_path('../fcs_update_server_details.pl');
my ( $output, $out, $err, $retval );
my $fcs_schema        = Fap::Model::Fcs->new();
my $fcs_dbh = F::Database::mysql_connect_fcs();
my $pbxtra_dbh = F::Database::mysql_connect();
# get the bundle for link
my $sth = $fcs_dbh->prepare("select bundle_id from bundle where name = 'software_site_linking'");
$sth->execute();
my $row = $sth->fetchrow_hashref();
my $link_bundle_id = $row->{'bundle_id'};

# Setup test data
my $dbh = $fcs_schema->dbh();
my $test_server_id = 18800;
my $orig_server_value = _get_server_details($test_server_id);
# orders
$sth = $dbh->prepare("INSERT INTO `orders`(customer_id, contact_id, order_type, record_type) VALUES (29179,1,'NEW','ORDER')");
$sth->execute();
my $test_order_id1 = $dbh->last_insert_id(undef, undef, 'orders', 'order_id');
$sth->finish();

# order_group
$sth = $dbh->prepare("INSERT INTO `order_group`(order_id, server_id, shipping_address_id, billing_address_id, product_id) VALUES ($test_order_id1,$test_server_id,1,1,7)");
$sth->execute();
my $test_order_group1 = $dbh->last_insert_id(undef, undef, 'order_group', 'order_group_id');
$sth->finish();

#order bundle
$sth = $dbh->prepare("INSERT INTO `order_bundle`(bundle_id,order_group_id,quantity) VALUES (54,$test_order_group1,1)");
$sth->execute();
my $test_order_bundle1 = $dbh->last_insert_id(undef, undef, 'order_bundle', 'order_bundle_id');
$sth->finish();

$sth = $dbh->prepare("INSERT INTO `order_bundle`(bundle_id,order_group_id,quantity) VALUES (81,$test_order_group1,1)");
$sth->execute();
my $test_order_bundle2 = $dbh->last_insert_id(undef, undef, 'order_bundle', 'order_bundle_id');
$sth->finish();

$output = Fap::StateMachine::Worker->new( executable=>$bu, input=>"{\"order_id\": $test_order_id1}" )->run();
$out = $output->{output};
$retval = $output->{return_code};
$err = $output->{error};
ok( $retval eq Fap::StateMachine::Unit::BU_CODE_SUCCESS, "Successful submission of order" );
my $link_bundle_count = _count_server_bundle( $test_server_id, 54 );
ok( $link_bundle_count == 1, "Bundle ID 54 added to $test_server_id" );
my $bcount = _count_server_bundle( $test_server_id, 81 );
my $revised_server_value = _get_server_details($test_server_id);
ok( $revised_server_value->get_column('can_link_server') == 1,
    "server.can_link_server updated in database" );
ok( $bcount == 1, "added bundle 81");

my $order = $out;
$output = Fap::StateMachine::Worker->new( executable=>$bu, input=>$order )->run('-r');
$out = $output->{output};
$retval = $output->{return_code};
$err = $output->{error};
ok( $retval == Fap::StateMachine::Unit::BU_CODE_SUCCESS, "Successful rollback procedure" );
$revised_server_value = _get_server_details($test_server_id);
$link_bundle_count = _count_server_bundle( $test_server_id, 81 );
$bcount = _count_server_bundle( $test_server_id, 54 );
ok( $link_bundle_count == 0, "Successfully reverted bundle 81 insertion" );
ok( $bcount == 0, "Successfully reverted bundle 54 insertion" );
ok(
    $revised_server_value->get_column('can_link_server') ==
      $orig_server_value->get_column('can_link_server'),
    "server.can_link_server rollback successful"
);
is(
    $revised_server_value->get_column('country'), undef, "reset country to undef on rollback successful"
);
is(
    $revised_server_value->get_column('localtime_file'), undef, "reset localtime_file to undef on rollback successful"
);
is(
    $revised_server_value->get_column('language'), undef, "reset language to undef on rollback successful"
);

$sth = $pbxtra_dbh->prepare("UPDATE server SET can_link_server=0 WHERE server_id=$test_server_id");
$sth->execute();

# delete test data
$sth = $dbh->prepare("delete from order_bundle where order_bundle_id in ($test_order_bundle1, $test_order_bundle2)");
$sth->execute();
$sth->finish();
$sth = $dbh->prepare("delete from order_group where order_group_id in ($test_order_group1)");
$sth->execute();
$sth->finish();
$sth = $dbh->prepare("delete from orders where order_id in ($test_order_id1)");
$sth->execute();
$sth->finish();


sub _get_server_details {
    my $server_id     = shift;
    return $fcs_schema->table('server')
      ->find( { 'server_id' => $server_id } );
}

sub _count_server_bundle {
    my ( $server_id, $bundle_id ) = @_;
    $fcs_schema->table('server_bundle')
      ->count( { 'server_id' => $server_id, 'bundle_id' => $bundle_id } );

}
