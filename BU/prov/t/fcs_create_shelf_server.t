use strict;
use warnings;
use Test::More qw( no_plan );
use Cwd qw( getcwd abs_path );
use File::Basename;
use Fap::StateMachine::Worker;

use_ok('Fap::StateMachine::Unit');
use_ok('Fap::Model::Fcs');
use_ok('Fap::Net::RPC');
use_ok('Fap::Global');
use_ok('Fap::Util');
use_ok('Fap::Order');
use_ok('Fap::User');
use_ok('Fap::Server');
use_ok('Fap::Provision::Server'); 

my $fcs_db = Fap::Model::Fcs->new();
my $dbh = $fcs_db->dbh();
my ($out, $err, $retval, $success, $exp_cp_ver);

my $bu = abs_path('../fcs_create_shelf_server.pl');
ok(defined($bu), 'BU command identified');

#-- Setup the data --#
#orders
$dbh->do("INSERT INTO `orders`(order_id, customer_id, order_type, record_type, order_status_id, provisioning_status_id, manager_approval_status_id, 
billing_approval_status_id, credit_approval_status_id, contact_id) VALUES ('',29179,'ADDON','ORDER',7,1,1,1,1,1)");
my $order_id = $dbh->last_insert_id(undef,undef,'orders','order_id');

#order_group
$dbh->do("INSERT INTO `order_group`(order_group_id, order_id, server_id, shipping_address_id, billing_address_id, product_id) VALUES ('',$order_id,null,10000,10000,7)");
my $order_group_id = $dbh->last_insert_id(undef,undef,'order_group','order_group_id');

$fcs_db->switch_db('fcs');


#-- Addon Orders --#

# execute the BU
my $order = '{"order_id" : ' . $order_id . '}';
my $output = Fap::StateMachine::Worker->new( executable => $bu, input => $order )->run('-t');
$out = $output->{output};
$retval = $output->{return_code};
$err = $output->{error};
$out =~ s/^(.*\s)?\{/\{/;

my $o_sid = get_server_from_order_group($fcs_db, $order_group_id);

# entry creation test
is(undef,$o_sid,'Nothing got associated for addons');


#-- Addon Orders Rollback --#

# execute the BU
$output = Fap::StateMachine::Worker->new( executable => $bu, input => $out )->run('-r');
$out = $output->{output};
$retval = $output->{return_code};
$err = $output->{error};
$out =~ s/^(.*\s)?\{/\{/;

my $rb_o_sid = get_server_from_order_group($fcs_db, $order_group_id);

# entry creation test
is($rb_o_sid,$o_sid,'Nothing change after addons rollback');


#-- New Orders --#


#-- Setup the data --#
$fcs_db->table('Order')->search( { 'order_id' => $order_id } )->update( { 'order_type' => 'NEW' } );

# execute the BU
$output = Fap::StateMachine::Worker->new( executable => $bu, input => $order )->run('-t');
$out = $output->{output};
$retval = $output->{return_code};
$err = $output->{error};
$out =~ s/^(.*\s)?\{/\{/;

$o_sid = get_server_from_order_group($fcs_db, $order_group_id);

isnt(undef,$o_sid,'This order group got associated with a server');

# entry creation test
my $serv_rs = $fcs_db->table('Server')->find( { 'server_id' => $o_sid } );
my $serv = ($fcs_db->strip($serv_rs));
ok($serv,'Server info was created in the database');
ok($serv->{'server_id'},"Server can be identified as $serv->{'server_id'}");

# v-tun setup test
ok($serv->{'tun_address'} && $serv->{'tun_address2'},"V-tunnels were defined");
ok($serv->{'remote_auth_username'} && $serv->{'remote_auth_password'}, 'Remote Authentication was defined');
ok($serv->{'remote_mgr_password'} && $serv->{'local_mgr_password'},'Manager Password were defined');
my $mydns_rs = $fcs_db->table('RrInternal')->search( { 'name' => { 'like', "%" . $serv->{'server_id'} ."%" } } )->first;
my $mydns_info = ($fcs_db->strip($mydns_rs));
ok($mydns_info, 'Enries for the MyDNS were found');

# asterisk instalation test        
ok($serv->{'asterisk_version'}, 'Asterisk is installed');

# conf files creation test
is($serv->{'use_db_conf'}, 1, 'Conf files were created');

# audio file test
my $audio_rs = $fcs_db->table('Audio')->search( { 'server_id' => $serv->{'server_id'} } )->first;
my $audio_info = ($fcs_db->strip($audio_rs));
ok($audio_info->{'id'}, 'Default Audio files were installed');

# file syncing
my $rpc = Fap::Net::RPC::rpc_connect( $serv->{'mosted'} );
my $result_p = Fap::Net::RPC::ls($rpc, $serv->{'server_id'}, "/data/$o_sid", 1 );
isnt(undef, $result_p, 'Files are successfully sync to the host');

# role test
my $role_rs = $fcs_db->table('Role')->search( { 'server_id' => $serv->{'server_id'} } )->first;
my $role_info = ($fcs_db->strip($role_rs));
ok($role_info->{'role_id'}, 'Roles were defined');

# CDR creation test
is($serv->{'get_cdrs'}, 1, 'CDR was created');

# virtual device test
my $virt_rs = $fcs_db->table('Device')->find( { 'server_id' => $serv->{'server_id'}, 'name' => '/dev/null' });
my $virt_info = ($fcs_db->strip($virt_rs));
ok($virt_info->{'device_id'}, 'Virtual device created');

# server admin creation test
my $user_rs = $fcs_db->table('User')->find( { 'username' => "admin$serv->{'server_id'}", 'default_server_id' => $serv->{'server_id'} } );
my $user_info = ($fcs_db->strip($user_rs));
ok($user_info->{'user_id'},'Server admin was created');


#-- Addon Orders Rollback --#

# execute the BU
$output = Fap::StateMachine::Worker->new( executable => $bu, input => $out )->run('-r');
$out = $output->{output};
$retval = $output->{return_code};
$err = $output->{error};
$out =~ s/^(.*\s)?\{/\{/;

$rb_o_sid = get_server_from_order_group($fcs_db, $order_group_id);
# on this point its safe to clean up the mess we made
cleanup($dbh, $order_id, $order_group_id);

# entry deletion test
my $result_r = Fap::Net::RPC::ls($rpc, $serv->{'mosted'}, "/data/$o_sid", 1 );
$serv_rs = $fcs_db->table('Server')->find( { 'server_id' => $o_sid } );
$serv = ($fcs_db->strip($serv_rs));
is($serv, undef,'Server info was deleted from the database');
isnt($rb_o_sid, $o_sid, 'This order group is no longer associated with a server');

# host file removal test
isnt($result_r, $result_p, 'Files are removed from the host');

# local file removal test
my $local = Fap::Global::kNFS_MOUNT() . '/' . $o_sid;
if ( -e $local )
{
    fail("Local files copies weren't cleared");
}
else
{
    ok(1, 'Local files were removed');
}

# audio file removal test
$audio_rs = $fcs_db->table('Audio')->search( { 'server_id' => $o_sid } )->first;
$audio_info = ($fcs_db->strip($audio_rs));
is($audio_info, undef, 'Default Audio files were deleted');

# close tunnel test
$mydns_rs = $fcs_db->table('RrInternal')->search( { 'name' => { 'like', "%" . $o_sid ."%" } } )->first;
$mydns_info = ($fcs_db->strip($mydns_rs));
is($mydns_info, undef, 'Tunnels were closed');

# role removal test
$role_rs = $fcs_db->table('Role')->search( { 'server_id' => $o_sid } )->first;
$role_info = ($fcs_db->strip($role_rs));
is($role_info, undef, 'Roles were removed');

# server admin deletion test
$user_rs = $fcs_db->table('User')->find( { 'username' => "admin$o_sid", 'default_server_id' => $o_sid } );
$user_info = ($fcs_db->strip($user_rs));
is($user_info, undef, 'Server admin was deleted');

# virtual device deletion test
$virt_rs = $fcs_db->table('Device')->find( { 'server_id' => $o_sid, 'name' => '/dev/null' } );
$virt_info = ($fcs_db->strip($virt_rs));
is($virt_info, undef, 'Virtual device deleted');

sub get_server_from_order_group
{
	my $dbh = shift;
	my $order_group_id = shift;

	my $rs = $dbh->table('OrderGroup')->find( {'order_group_id' => $order_group_id} );
	my $ret = ($dbh->strip($rs));
	return $ret->{'server_id'};
}

#-- Cleanup the data --#
sub cleanup
{
    my $dbh = shift;
    my $order_id = shift;
    my $order_group_id = shift;

    #order_group
    $dbh->do("delete from `order_group` where order_group_id = $order_group_id");

    #orders
    $dbh->do("delete from `orders` where order_id = $order_id");
}
