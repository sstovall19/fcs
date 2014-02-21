use strict;
use warnings;
use Test::More qw( no_plan );
use Cwd qw( getcwd abs_path );
use File::Basename;
use Fap::StateMachine::Worker;

use_ok('Fap::StateMachine::Unit');
use_ok('Fap::Model::Fcs');
use_ok('Fap::HUD');

my ($out, $err, $retval);
my $server_id = 18801;
my $fcs_db = Fap::Model::Fcs->new();
my $dbh = $fcs_db->dbh();

my $bu = abs_path('../fcs_add_hud.pl');
ok(defined($bu), 'BU command identified');
my $burb = abs_path('../fcs_add_hud.pl -r');
ok(defined($burb), 'BU rollback command identified');

#-- Setup the data --#
#orders
$dbh->do("INSERT INTO `orders`(order_id, customer_id, order_type, record_type, order_status_id, provisioning_status_id, manager_approval_status_id, 
billing_approval_status_id, credit_approval_status_id, contact_id) VALUES ('',29179,'ADDON','ORDER',7,1,1,1,1,1)");
my $order_id = $dbh->last_insert_id(undef,undef,'orders','order_id');

#order_group
$dbh->do("INSERT INTO `order_group`(order_group_id, order_id, server_id, shipping_address_id, billing_address_id, product_id) VALUES ('',$order_id,$server_id,10000,10000,8)");
my $order_group_id = $dbh->last_insert_id(undef,undef,'order_group','order_group_id');

#order_bundle
$dbh->do("INSERT INTO `order_bundle`(order_bundle_id,bundle_id,order_group_id,quantity,list_price,one_time_total) VALUES ('',51,$order_group_id,2,'5000.00','8000.00')");
my $order_bundle_id = $dbh->last_insert_id(undef,undef,'order_bundle','order_bundle_id');

#order_bundle_detail
$dbh->do("INSERT INTO `order_bundle_detail`(order_bundle_detail_id,order_bundle_id) VALUES ('',$order_bundle_id)");
my $order_bundle_detail_id = $dbh->last_insert_id(undef,undef,'order_bundle_detail','order_bundle_detail_id');

my $orig_sinfo = $fcs_db->table('Server')->single({"me.server_id" => $server_id});
my $orig_policy = Fap::HUD::get_server_policy('server_id' => $server_id);


# did the has_hud changed
my $order = '{"order_id" : ' . $order_id . '}';
my $output = Fap::StateMachine::Worker->new( executable => $bu, input => $order )->run('-t');
$out = $output->{output};
$retval = $output->{return_code};
$err = $output->{error};
$out =~ s/^(.*\s)?\{/\{/;

my $cur_sinfo = $fcs_db->table('Server')->single({"me.server_id" => $server_id});
my $cur_policy = Fap::HUD::get_server_policy('server_id' => $server_id);

if ($retval == Fap::StateMachine::Unit::BU_CODE_SUCCESS())
{
	ok($cur_sinfo->has_hud && $cur_sinfo->has_hud !~ /^\s+$/, "has_hud entry got some value after processing");
	isnt($cur_sinfo->has_hud, $orig_sinfo->has_hud, "has_hud entry is not the same after processing");
	isnt($cur_policy, $orig_policy, "HUD policy is not the same after processing");
}
else
{
    ok($retval,"exiting with code : $retval");
    ok(1,"out : $out\n============\nerr : $err");
}

# Rollback
isnt($order, $out, "Input for the rollback process is different from the original input");

# Rollback only if has_hud is changed
$output = Fap::StateMachine::Worker->new( executable => $bu, input => $out )->run('-r');
$out = $output->{output};
$retval = $output->{return_code};
$err = $output->{error};
$out =~ s/^(.*\s)?\{/\{/;

$cur_sinfo = $fcs_db->table('Server')->single({"me.server_id" => $server_id});
$cur_policy = Fap::HUD::get_server_policy('server_id' => $server_id);
	
is($cur_policy, $orig_policy, "HUD policy is the same after rollback");
is($cur_sinfo->has_hud, $orig_sinfo->has_hud, "has_hud is back to orignal value after rollback");


################################################################################
# clean up, make sure that those generated boot logs are indeed gone.
################################################################################

#order_bundle_detail
$dbh->do("delete from `order_bundle_detail` where order_bundle_id = $order_bundle_id");

#order_bundle
$dbh->do("delete from `order_bundle` where order_bundle_id = $order_bundle_id");

#order_group
$dbh->do("delete from `order_group` where order_group_id = $order_group_id");

#orders
$dbh->do("delete from `orders` where order_id = $order_id");

# this server has no HUD set up and it will stay that way
if ($cur_sinfo->has_hud)
{
    $fcs_db->switch_db('pbxtra');
    $dbh->do("update server set has_hud = null where server_id = $server_id");
    
    Fap::HUD::set_hud_variable(
                'config_file' => 'server.properties', 
                'server_id'   => $server_id, 
                'type'        => 'instance.serverId', 
                'hostname'    => undef
            );
    Fap::HUD::set_server_policy('server_id' => $server_id, 'policy' => undef);
    Fap::HUD::set_hud_enabled('server_id' => $server_id, 'enabled' => 0);
    
    $fcs_db->switch_db('hus');
    $dbh->do("delete from update_policy where server_id = $server_id");
}    
