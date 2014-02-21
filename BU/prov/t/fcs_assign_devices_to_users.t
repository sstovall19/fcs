use strict;
use warnings;

use Test::More qw( no_plan );
use Cwd qw( getcwd abs_path );
use Fap::StateMachine::Unit;
use Fap::StateMachine::Worker;
use Fap::Model::Fcs;

####
# Setup test data
my $fcs_obj = Fap::Model::Fcs->new();
my $dbh = $fcs_obj->dbh();
my $test_server_id = 12354;
# orders
my $sth = $dbh->prepare("INSERT INTO `orders`(customer_id, contact_id, order_type, record_type) VALUES (29179,1,'NEW','ORDER')");
$sth->execute();
my $test_order_id1 = $dbh->last_insert_id(undef, undef, 'orders', 'order_id');
$sth->finish();

$sth = $dbh->prepare("INSERT INTO `orders`(customer_id, contact_id, order_type, record_type) VALUES (29179,1,'NEW','ORDER')");
$sth->execute();
my $test_order_id2 = $dbh->last_insert_id(undef, undef, 'orders', 'order_id');
$sth->finish();

# order_group
$sth = $dbh->prepare("INSERT INTO `order_group`(order_id, server_id, shipping_address_id, billing_address_id, product_id) VALUES ($test_order_id1,$test_server_id,1,1,7)");
$sth->execute();
my $test_order_group1 = $dbh->last_insert_id(undef, undef, 'order_group', 'order_group_id');
$sth->finish();

$sth = $dbh->prepare("INSERT INTO `order_group`(order_id, server_id, shipping_address_id, billing_address_id, product_id) VALUES ($test_order_id2,$test_server_id,1,1,7)");
$sth->execute();
my $test_order_group2 = $dbh->last_insert_id(undef, undef, 'order_group', 'order_group_id');
$sth->finish();

# order_bundle
# 42 is the bundle for polycom 331
$sth = $dbh->prepare("INSERT INTO `order_bundle`(bundle_id,order_group_id,quantity) VALUES (42,$test_order_group1,2)");
$sth->execute();
my $test_order_bundle1 = $dbh->last_insert_id(undef, undef, 'order_bundle', 'order_bundle_id');
$sth->finish();

$sth = $dbh->prepare("INSERT INTO `order_bundle`(bundle_id,order_group_id,quantity) VALUES (42,$test_order_group2,2)");
$sth->execute();
my $test_order_bundle2 = $dbh->last_insert_id(undef, undef, 'order_bundle', 'order_bundle_id');
$sth->finish();

my @phone_macs = ('0004F22CA1B6', '0004F22CA1B7');

my @test_order_bundle_details;
# order_bundle_detail
foreach my $pm (@phone_macs) {
	$sth = $dbh->prepare("INSERT INTO `order_bundle_detail` (order_bundle_id,mac_address) VALUES ($test_order_bundle1,'$pm')");
	$sth->execute();
	my $test_order_bundle_detail_id = $dbh->last_insert_id(undef, undef, 'order_bundle_detail', 'order_bundle_detail_id');
	push(@test_order_bundle_details, $test_order_bundle_detail_id);
	$sth->finish();
}

# no order_bundle_detail for test order 2 to test orders without any mac address details in the order
# to represent orders not yet going through scan phones
# End of Data Setup

####
# begin test
use_ok('Fap::StateMachine::Unit');

my $bu = abs_path('../fcs_assign_devices_to_users.pl');
my ( $output, $out, $err, $retval );

# test order with no mac_address details
$output = Fap::StateMachine::Worker->new( executable=>$bu, input=>"{\"order_id\": $test_order_id2}" )->run();
$out = $output->{output};
$retval = $output->{return_code};
$err = $output->{error};
like(
    $err,
    qr/ERR: Missing order bundle details/,
    "Order without phone mac address"
);
$out = $err = $retval = "";

# test correct order with phones not yet added
$output = Fap::StateMachine::Worker->new( executable=>$bu, input=>"{\"order_id\": $test_order_id1}" )->run();
$out = $output->{output};
$retval = $output->{return_code};
$err = $output->{error};
like(
    $err,
    qr/ERR: Found mac address without existing device/,
    "Correct order but with missing phones from devices table"
);
$out = $err = $retval = "";

# test correct order
# insert phones into devices table
my @test_device_ids;
foreach my $pm (@phone_macs) {
	my $dname = "SIP/$pm-$test_server_id";
	$sth = $dbh->prepare("insert into pbxtra.devices set name = ?, password = 'test41ddD21', type = 'polycom', description = 'Polycom IP331', firmware = '3.2.3.revc', server_id = ?");
	$sth->execute($dname, $test_server_id);
	my $test_devid = $dbh->last_insert_id(undef, undef, 'pbxtra.devices', 'device_id');
	$sth->finish();
	push (@test_device_ids, $test_devid);
}
$output = Fap::StateMachine::Worker->new( executable=>$bu, input=>"{\"order_id\": $test_order_id1}" )->run();
$out = $output->{output};
$retval = $output->{return_code};
$err = $output->{error};
ok( $retval == Fap::StateMachine::Unit::BU_CODE_SUCCESS, "Successful run" );

# check that devices are assigned
my $count = _count_assigned_devices($dbh, $test_server_id, \@phone_macs);
ok( $count == 2, "All phones assigned");

# test rollback
my $order = $out;
$out = $err = $retval = "";
$output = Fap::StateMachine::Worker->new( executable=>$bu, input=>$order )->run('-r');
$out = $output->{output};
$retval = $output->{return_code};
$err = $output->{error};
ok( $retval == Fap::StateMachine::Unit::BU_CODE_SUCCESS, "Successful rollback procedure" );

# check that devies are not assigned
$count = _count_assigned_devices($dbh, $test_server_id, \@phone_macs);
ok( $count == 0, "All phones unassigned");

# delete test data
$sth = $dbh->prepare("delete from order_bundle_detail where order_bundle_detail_id in (" . join(",", @test_order_bundle_details) . ")");
$sth->execute();
$sth->finish();
$sth = $dbh->prepare("delete from order_bundle where order_bundle_id in ($test_order_bundle1, $test_order_bundle2)");
$sth->execute();
$sth->finish();
$sth = $dbh->prepare("delete from order_group where order_group_id in ($test_order_group1, $test_order_group2)");
$sth->execute();
$sth->finish();
$sth = $dbh->prepare("delete from orders where order_id in ($test_order_id1, $test_order_id2)");
$sth->execute();
$sth->finish();
$sth = $dbh->prepare("delete from pbxtra.devices where device_id in (" . join(",", @test_device_ids) . ")");
$sth->execute();
$sth->finish();

sub _count_assigned_devices
{
	my $db = shift;
	my $sid = shift;
	my $mac = shift;

	# use the right device name
	my @dname;
	foreach my $m (@{$mac}) {
		push(@dname, "SIP/" . $m . "-$sid");
	}

	my $sql = "select e.extension, e.device_id from pbxtra.extensions e left join pbxtra.devices d on e.device_id = d.device_id where d.server_id = 12354 and d.name in ('" . join ("','", @dname) ."')";

	my $chk = $db->prepare($sql);
	$chk->execute();

	my $count = 0;
	while (my $row = $chk->fetchrow_hashref()) {
		if ($row->{'extension'} ne '') {
			$count++;
		}
	}
	$chk->finish();

	return $count;
}

