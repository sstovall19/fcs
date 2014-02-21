use strict;

use Test::More qw( no_plan );
use Cwd qw( getcwd abs_path );
use Data::Compare;
use JSON;

use Fap::StateMachine::Unit;
use Fap::StateMachine::Worker;
use Fap::Model::Fcs;

# Constants
my $server_id = 12354;
my $contact_id = 1;
my $shipping_address_id = 1;
my $quantity = 2;
my $addon_quantity = 2;

my $db = Fap::Model::Fcs->new();

use_ok('Fap::StateMachine::Unit');

my $bu = abs_path('../fcs_create_users_extensions.pl');

# Check and setup database
my $user_count = get_user_count($db, $server_id);
my $order = create_order($db, [ undef, undef, undef ]);

my $input = '{ "order_id" : "' . $order->{'order_id'} . '" }';
my $output;

# Create users
$output = Fap::StateMachine::Worker->new( executable => $bu, input => $input )->run;
ok($output->{'return_code'} eq Fap::StateMachine::Unit::BU_CODE_SUCCESS, 'Creating users, returned success');
my $perl_out = decode_json($output->{'output'});
my $created_user_ids = $perl_out->{'created_user_ids'};
my $user_ids = get_user_ids($created_user_ids);
ok(get_user_count($db, $server_id, $user_ids) == $quantity, 'Creating users, user records created');
ok(Compare($created_user_ids, get_db_records($db, $user_ids)), 'Creating users, extension records created');

# Delete users
$output = Fap::StateMachine::Worker->new( executable => $bu, input => $output->{'output'} )->run('-r');
ok($output->{'return_code'} eq Fap::StateMachine::Unit::BU_CODE_SUCCESS, 'Deleting users, returned success');
ok(get_user_count($db, $server_id, $user_ids) == 0, 'Deleting users, user records deleted');
ok(@{get_db_records($db, $user_ids)} == 0, 'Deleting users, extension records deleted');
undef $output;
delete_order($db, $order);

sub get_user_count {
	my ($db, $default_server_id, $user_ids) = @_;
	
	my $cond = { default_server_id => $default_server_id };
	if (defined($user_ids) && @{$user_ids}) {
		$cond->{'user_id'} = { -in => $user_ids };
	}
	
	return $db->table('User')->count($cond);
}

sub get_db_records {
	my ($db, $user_ids) = @_;
	
	if (!@{$user_ids}) {
		return [];
	}
	
	my $rs = $db->table('Extension')->search(
		{
			user_id => { -in => $user_ids }
		},
		{
			select => [ qw/extension server_id user_id/ ]
		}
	);
	
	my @rows;
	while (my $row = $rs->next) {
		my %data = $row->get_columns;
		push @rows, {
			extension => $data{'extension'},
			user_id => $data{'user_id'}
		};
	}
	
	return \@rows;
}

sub get_user_ids {
	my $created_user_ids = shift;
	
	my @user_ids;
	
	foreach my $created_user_id (@$created_user_ids) {
		push @user_ids, $created_user_id->{'user_id'};
	}
	
	return \@user_ids;
}

sub get_extension_numbers {
	my ($created_user_ids) = @_;
	
	my @extensions;
	foreach my $created_user_id (@$created_user_ids) {
		push @extensions, $created_user_id->{'extension'};
	}
	
	return \@extensions;
}

sub create_order {
	my $db = shift;
	my $macs = shift;

	my $order = {};
	
	$order->{'order_id'} = $db->table('orders')->create( { contact_id => $contact_id } )->order_id;
	
	$order->{'order_group_id'} = $db->table('order_group')->create( {
		order_id => $order->{'order_id'},
		server_id => $server_id,
		shipping_address_id => $shipping_address_id,
		product_id => 7
	} )->order_group_id;
	
	# 81 is fcs user license bundle
	$order->{'order_bundle_id1'} = $db->table('order_bundle')->create( {
		bundle_id => 81,
		order_group_id => $order->{'order_group_id'},
		quantity => $quantity
	} )->order_bundle_id;
	
	# 82 is fcs cc user license bundle (not basic)
	$order->{'order_bundle_id2'} = $db->table('order_bundle')->create( {
		bundle_id => 82,
		order_group_id => $order->{'order_group_id'},
		quantity => $addon_quantity
	} )->order_bundle_id;

	return $order;
}

sub delete_order {
	my $db = shift;
	my $order = shift;
	
	if (!defined($db) || ref($db) ne 'Fap::Model::Fcs') {
		Fap->trace_error('Invalid db param');
		return undef;
	}
	
	my $regex = '^\d+$';
	
	if (!defined($order) || ref($order) ne 'HASH' ||
			!exists($order->{'order_id'}) || $order->{'order_id'} !~ /$regex/ ||
			!exists($order->{'order_group_id'}) || $order->{'order_group_id'} !~ /$regex/ ||
			!exists($order->{'order_bundle_id'}) || $order->{'order_bundle_id'} !~ /$regex/
	) {
		Fap->trace_error('Invalid order param');
		return undef;
	}
	
	$db->table('order_bundle')->search( { order_bundle_id => $order->{'order_bundle_id'} } )->delete;
	$db->table('order_group')->search( { order_group_id => $order->{'order_group_id'} } )->delete;
	$db->table('order')->search( { order_id => $order->{'order_id'} } )->delete;
	
	return 1;
}

