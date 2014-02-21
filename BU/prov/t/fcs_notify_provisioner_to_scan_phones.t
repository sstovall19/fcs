use strict;

use Test::More qw( no_plan );
use Cwd qw( getcwd abs_path );

use Fap::StateMachine::Unit;
use Fap::StateMachine::Worker;
use Fap::Model::Fcs;

my $order_bundle_id = 30211;
my $order_id = 67;
my @macs = qw/0004f2000001 0004f2000002 0004f2000003/;

my $db = Fap::Model::Fcs->new();

use_ok('Fap::StateMachine::Unit');

my $bu = abs_path('../fcs_notify_provisioner_to_scan_phones.pl');
my ( $input, $output );

# Reset database 
delete_db_records($db, $order_bundle_id);

# Main tests
insert_db_records($db, $order_bundle_id, \@macs);
$input = _read_file('main_test.json');
$output = Fap::StateMachine::Worker->new( executable => $bu, input => $input )->run('-t');
ok($output->{'return_code'} eq Fap::StateMachine::Unit::BU_CODE_SUCCESS, 'Phones successfully scanned');
undef $output;

delete_db_records($db, $order_bundle_id);
$input = _read_file('main_test.json');
$output = Fap::StateMachine::Worker->new( executable => $bu, input => $input )->run('-t');
ok($output->{'return_code'} eq Fap::StateMachine::Unit::BU_CODE_HALT, 'Phones were not scanned');
undef $output;

insert_db_records($db, $order_bundle_id, [ @macs, '0004f2000004' ]);
$input = _read_file('main_test.json');
$output = Fap::StateMachine::Worker->new( executable => $bu, input => $input )->run('-t');
ok($output->{'return_code'} eq Fap::StateMachine::Unit::BU_CODE_FAILURE, 'Too many phones scanned, checking error code');
like($output->{'error'}, qr/.ERR: the number of scanned phones is bigger than ordered./, 'Too many phones scanned, checking error message');
undef $output;

# Invalid input test
$input = _read_file('invalid_order.json');
$output = Fap::StateMachine::Worker->new( executable => $bu, input => $input )->run('-t');
ok($output->{'return_code'} eq Fap::StateMachine::Unit::BU_CODE_FAILURE, 'Invalid order, checking error code');
like($output->{'error'}, qr/.ERR: Invalid order./, 'Invalid order, checking error message');
undef $output;

# Rollback test
delete_db_records($db, $order_bundle_id);
insert_db_records($db, $order_bundle_id, \@macs);
$input = _read_file('main_test.json');
$output = Fap::StateMachine::Worker->new( executable => $bu, input => $input )->run('-r -t');
ok($output->{'return_code'} eq Fap::StateMachine::Unit::BU_CODE_SUCCESS, 'Rollback test');
undef $output;

sub _read_file {
	my $filename = shift;
	open FILE, "<data/fcs_notify_provisioner_to_scan_phones/$filename";
	my $content = do { local $/; <FILE>};
	close FILE;
	return $content;
}

sub insert_db_records {
	my ($db, $order_bundle_id, $macs) = @_;
	
	foreach my $mac (@$macs) {
		$db->table('OrderBundleDetail')->create(
			{
				order_bundle_id => $order_bundle_id,
				mac_address => $mac
			}
		);
	}
}

sub delete_db_records {
	my ($db, $order_bundle_id) = @_;
	
	if (!defined($db) || !defined($order_bundle_id)) {
		return undef;
	}

	return $db->table('OrderBundleDetail')->search( { order_bundle_id => $order_bundle_id } )->delete;
}

