use strict;

use Test::More qw( no_plan );
use Cwd qw( getcwd abs_path );

use Fap::StateMachine::Unit;
use Fap::StateMachine::Worker;
use Fap::Model::Fcs;

my $server_id = 12354;
my @device_names = (
	'SIP/0004f2000001-12354',
	'SIP/0004f2000002-12354',
	'SIP/0004f2000003-12354'
);

my $db = Fap::Model::Fcs->new();

use_ok('Fap::StateMachine::Unit');

my $bu = abs_path('../fcs_add_devices.pl');
my ( $input, $output );

# Reset database
_delete_devices($db, $server_id, \@device_names);

# Main test
$input = _read_file('main_test.json');
$output = Fap::StateMachine::Worker->new( executable => $bu, input => $input )->run;
my $device_count = _get_device_count($db, $server_id, \@device_names);
ok($output->{'return_code'} eq Fap::StateMachine::Unit::BU_CODE_SUCCESS, 'Devices added. execute() returned success');
ok($device_count == @device_names, 'Devices added. Database has been updated');

# Rollback test
$output = Fap::StateMachine::Worker->new( executable => $bu, input => $output->{'output'} )->run('-r');
$device_count = _get_device_count($db, $server_id, \@device_names);
ok($output->{'return_code'} eq Fap::StateMachine::Unit::BU_CODE_SUCCESS, 'Devices removed. rollback() returned success');
ok($device_count == 0, 'Devices removed. Database has been updated');
undef $output;

# Invalid input test
$input = _read_file('phone_mac_empty.json');
$output = Fap::StateMachine::Worker->new( executable => $bu, input => $input )->run;
like($output->{'error'}, qr/.ERR: Incomplete phone information in order group 30047 order bundle 30212 order bundle detail 21508./, 'Invalid input: phone_mac is empty');
undef $output;

sub _read_file {
	my $filename = shift;
	open FILE, "<data/fcs_add_devices/$filename";
	my $content = do { local $/; <FILE>};
	close FILE;
	return $content;
}

sub _delete_devices {
	my $db = shift;
	my $server_id = shift;
	my $device_names = shift;
	
	if (!defined($db)) {
		return undef;
	}
	
	if (!defined($server_id) || $server_id !~ /^\d+$/) {
		return undef;
	}
	
	if (!defined($device_names) || !@{$device_names}) {
		return undef;
	}
	
	my $rs = $db->table('Device')->search({
		server_id => $server_id,
		name => { -in => $device_names }
	})->delete;

	return 1;
}

sub _get_device_count {
	my $db = shift;
	my $server_id = shift;
	my $device_names = shift;
	
	if (!defined($db)) {
		return undef;
	}
	
	if (!defined($server_id) || $server_id !~ /^\d+$/) {
		return undef;
	}
	
	if (!defined($device_names) || !@{$device_names}) {
		return undef;
	}
	
	my $count = $db->table('Device')->count({
			server_id => $server_id,
			name => { -in => $device_names }
			});

	if (!$count) {
		$count = 0;
	}

	return $count;
}
