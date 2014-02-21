use Test::More qw( no_plan );
use Cwd qw( getcwd abs_path );

use Fap::StateMachine::Unit;
use Fap::StateMachine::Worker;
use Fap::Model::Fcs;

my $server_id = 12354;
my @license_type_ids = qw/19/;

my $db = Fap::Model::Fcs->new();

use_ok('Fap::StateMachine::Unit');

my $bu = abs_path('../fcs_add_user_licenses.pl');
my ( $input, $output );

# Reset database 
_delete_licenses($db, $server_id, \@license_type_ids);

# Main test
$input = _read_file('main_test.json');
$output = Fap::StateMachine::Worker->new( executable => $bu, input => $input )->run;
my $licenses = _check_licenses($db, $server_id, \@license_type_ids);
ok($output->{'return_code'} eq Fap::StateMachine::Unit::BU_CODE_SUCCESS, 'Licenses added. execute() returned success');
ok(@{$licenses} == @license_type_ids, 'Licenses added. Database has been updated');

# Rollback test
$output = Fap::StateMachine::Worker->new( executable => $bu, input => $output->{'output'} )->run('-r');
my $licenses = _check_licenses($db, $server_id, \@license_type_ids);
ok($output->{'return_code'} eq Fap::StateMachine::Unit::BU_CODE_SUCCESS, 'Licenses removed. rollback() returned success');
ok(@{$licenses} == 0, 'Licenses removed. Database has been updated');
undef $output;

sub _read_file {
	my $filename = shift;
	open FILE, "<data/fcs_add_user_licenses/$filename";
	my $content = do { local $/; <FILE>};
	close FILE;
	return $content;
}

sub _delete_licenses {
	my $db = shift;
	my $server_id = shift;
	my $license_type_ids = shift;
	
	if (!defined($db)) {
		return undef;
	}
	
	if (!defined($server_id) || $server_id !~ /^\d+$/) {
		return undef;
	}
	
	if (!defined($license_type_ids) || !@{$license_type_ids}) {
		return undef;
	}
	
	my $rs = $db->table('ServerLicense')->search({
		server_id => $server_id,
		license_type_id => { -in => $license_type_ids }
	})->delete;

	return 1;
}

sub _check_licenses {
	my $db = shift;
	my $server_id = shift;
	my $license_type_ids = shift;
	
	if (!defined($db)) {
		return undef;
	}
	
	if (!defined($server_id) || $server_id !~ /^\d+$/) {
		return undef;
	}
	
	if (!defined($license_type_ids) || !@{$license_type_ids}) {
		return undef;
	}
	
	my $rs = $db->table('ServerLicense')->search({
		server_id => $server_id,
		license_type_id => { -in => $license_type_ids }
	});
	
	my @ret;
	while (my $row = $rs->next) {
		my %data = $row->get_columns;
		push @ret, \%data;
	}
	return @ret ? \@ret : [];
}

