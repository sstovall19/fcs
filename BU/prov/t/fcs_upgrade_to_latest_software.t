use strict;
use warnings;
use Test::More qw( no_plan );
use Cwd qw( getcwd abs_path );
use File::Basename;
use Fap::StateMachine::Worker;

use_ok('Fap::StateMachine::Unit');
use_ok('Fap::Model::Fcs');
use_ok('Fap::Global');
use_ok('Fap::Util');

my $fcs_db = Fap::Model::Fcs->new();
my $dbh = $fcs_db->dbh();
my ($out, $err, $retval, $success, $exp_cp_ver);

my $bu = abs_path('../fcs_upgrade_to_latest_software.pl');
ok(defined($bu), 'BU command identified');

#########################
# PBXTRA a.k.a. Premise
#########################
my $server_id = 18801;

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

my $orig_sinfo = $fcs_db->table('server')->single({"me.server_id" => $server_id});
my $rs = $fcs_db->table('UpgradeUserDefined')->search({"me.server_id" => $server_id});
my $orig_last_project_id = $rs->get_column('project_id')->max;
ok($orig_last_project_id, "Original Project ID is $orig_last_project_id");


#-- Addon Orders --#
# execute the BU
my $order = '{"order_id" : ' . $order_id . '}';
my $output = Fap::StateMachine::Worker->new( executable => $bu, input => $order )->run('-t');
$out = $output->{output};
$retval = $output->{return_code};
$err = $output->{error};
$out =~ s/^(.*\s)?\{/\{/;

# gather data
my $cur_sinfo = $fcs_db->table('Server')->single({"me.server_id" => $server_id});
$rs = $fcs_db->table('UpgradeUserDefined')->search({"me.server_id" => $server_id});
my $rows = $rs->count;
my $cur_last_project_id = $rs->get_column('project_id')->max;

# compare gathered data from original data
ok($cur_last_project_id, "Current Project ID after processing addon order is $cur_last_project_id");
is($cur_sinfo->cp_version, $orig_sinfo->cp_version, "PBXtra Server cp_version is the same after addon order");
is($cur_last_project_id, $orig_last_project_id, "PBXtra Server last_project_id is the same after addon order");


#-- Addon Orders Rollback --#
# execute the BU
$output = Fap::StateMachine::Worker->new( executable => $bu, input => $order )->run('-r');
$out = $output->{output};
$retval = $output->{return_code};
$err = $output->{error};
$out =~ s/^(.*\s)?\{/\{/;

# gather data
$cur_sinfo = $fcs_db->table('server')->single({"me.server_id" => $server_id});
$rs = $fcs_db->table('UpgradeUserDefined')->search({"me.server_id" => $server_id});
$cur_last_project_id = $rs->get_column('project_id')->max;

# compare gathered data from original data
ok($cur_last_project_id, "Current Project ID after rollback addon order is $cur_last_project_id");
is($cur_sinfo->cp_version, $orig_sinfo->cp_version, "PBXtra Server info same after addon order rollback");
is($cur_last_project_id, $orig_last_project_id, "PBXtra Upgrades to take is same after addon order rollback");


#-- Setup the data --#
#orders
$dbh->do("update `orders` set order_type = 'NEW' where order_id = $order_id");


#-- New Orders --#
# execute the BU
$output = Fap::StateMachine::Worker->new( executable => $bu, input => $order )->run('-t');
$out = $output->{output};
$retval = $output->{return_code};
$err = $output->{error};
$out =~ s/^(.*\s)?\{/\{/;

# gather data
$cur_sinfo = $fcs_db->table('server')->single({"me.server_id" => $server_id});
$rs = $fcs_db->table('UpgradeUserDefined')->search({"me.server_id" => $server_id});
$cur_last_project_id = $rs->get_column('project_id')->max;

# compare gathered data from original data
ok($cur_last_project_id, "Current Project ID after processing new order is $cur_last_project_id");
ok($cur_sinfo->cp_version, 'Current CP Version after processing new order is ' . $cur_sinfo->cp_version);
ok(Fap::Global::kCP_VERSION(), 'Target CP Version after processing new order is ' . Fap::Global::kCP_VERSION());
if ($retval)
{
    isnt(Fap::Global::kCP_VERSION(), $cur_sinfo->cp_version, "Not reach target version since process was interupted.");
    
    # we should get a halt scenario at this point
    if ($retval == Fap::StateMachine::Unit::BU_CODE_HALT())
    {
        ok(1,'Its expected to halt process for some human intervention');
        isnt($cur_last_project_id, $orig_last_project_id, "The original Project ID should be different with the current one.");

        # execute the BU and simulate restart for halted
        $output = Fap::StateMachine::Worker->new( executable => $bu, input => $out )->run('-t');
        $out = $output->{output};
        $retval = $output->{return_code};
        $err = $output->{error};
        $out =~ s/^(.*\s)?\{/\{/;
    
        # gather data
        $cur_sinfo = $fcs_db->table('server')->single({"me.server_id" => $server_id});
        $rs = $fcs_db->table('UpgradeUserDefined')->search({"me.server_id" => $server_id});
        
        ok($cur_last_project_id eq $rs->get_column('project_id')->max,'Current Project ID should be same after restarting halted process.');
    }
    # not expecting for an error here
    else
    {
        is($retval, Fap::StateMachine::Unit::BU_CODE_HALT(), "No error is expected at this point\n\n$err");
    }
}
$exp_cp_ver = $cur_sinfo->cp_version;

if ($retval == Fap::StateMachine::Unit::BU_CODE_SUCCESS())
{
    # if the humans did their part
    is($exp_cp_ver, Fap::Global::kCP_VERSION(), "Reach the target PBxtra CP version.");
    ok($exp_cp_ver, "PBxtra Server is now ${exp_cp_ver}.");
    $success = 1;
}
else
{
    # still in limbo
    isnt($cur_sinfo->cp_version, Fap::Global::kCP_VERSION(), "Target version not reached since nothing was done.");
    ok($exp_cp_ver, "PBxtra Server is still ${exp_cp_ver}.");
    $success = 0;
}


#-- New Orders Rollback --#
# execute the BU
$output = Fap::StateMachine::Worker->new( executable => $bu, input => $out )->run('-r');
$out = $output->{output};
$retval = $output->{return_code};
$err = $output->{error};
$out =~ s/^(.*\s)?\{/\{/;

# gather data
$cur_sinfo = $fcs_db->table('server')->single({"me.server_id" => $server_id});

# compare gathered data from original data
is($retval, Fap::StateMachine::Unit::BU_CODE_SUCCESS(), "Rollback executed successfully for PBxtra");
if ($success)
{
    is($cur_sinfo->cp_version, Fap::Global::kCP_VERSION(), "PBxtra CP version remains unchange even after rollback");
}
else
{
    is($exp_cp_ver, $cur_sinfo->cp_version, "PBxtra CP version same after rollback.");
    
    #clean up
    $rs = $fcs_db->table('UpgradeStat')->search({"me.server_id" => $server_id},{select => [{abs => 'project'}], as => ['project']});
    $cur_last_project_id = $rs->get_column('project')->max;
    $rs = $fcs_db->table('UpgradeUserDefined')->search({"me.server_id" => $server_id, 'project_id' => { '>' => $cur_last_project_id}});
    $rs->delete;
    $rs = $fcs_db->table('UpgradeUserDefined')->search({"me.server_id" => $server_id});
    is($rs->count, $rows, "PBXtra Upgrades back to normal");
}    


#########################
# Connect a.k.a. Hosted
#########################
$server_id = 15226;


#-- Setup the data --#
#orders
$dbh->do("update `orders` set order_type = 'ADDON' where order_id = $order_id");

#order_group
$dbh->do("update `order_group` set server_id = $server_id, product_id = 7 where order_group_id = $order_group_id");


$orig_sinfo = $fcs_db->table('server')->single({"me.server_id" => $server_id});
ok($orig_sinfo->cp_version, 'Connect CP version is ' . $orig_sinfo->cp_version);

#-- Addon Orders --#
# execute the BU
$output = Fap::StateMachine::Worker->new( executable => $bu, input => $order )->run('-t');
$out = $output->{output};
$retval = $output->{return_code};
$err = $output->{error};
$out =~ s/^(.*\s)?\{/\{/;

# gather data
$cur_sinfo = $fcs_db->table('server')->single({"me.server_id" => $server_id});

# compare gathered data from original data
is($cur_sinfo->cp_version, $orig_sinfo->cp_version, "Connect CP version same after addon order");


#-- Addon Orders Rollback --#
# execute the BU
$output = Fap::StateMachine::Worker->new( executable => $bu, input => $out )->run('-r');
$out = $output->{output};
$retval = $output->{return_code};
$err = $output->{error};
$out =~ s/^(.*\s)?\{/\{/;

# gather data
$cur_sinfo = $fcs_db->table('server')->single({"me.server_id" => $server_id});

# compare gathered data from original data
is($cur_sinfo->cp_version, $orig_sinfo->cp_version, "Connect CP version same after addon order rollback");


#-- Setup the data --#
#orders
$dbh->do("update `orders` set order_type = 'NEW' where order_id = $order_id");


#-- New Orders --#
# execute the BU
ok(Fap::Global::kCP_VERSION(), 'Target CP Version after processing new order is ' . Fap::Global::kCP_VERSION());
$output = Fap::StateMachine::Worker->new( executable => $bu, input => $order )->run('-t');
$out = $output->{output};
$retval = $output->{return_code};
$err = $output->{error};
$out =~ s/^(.*\s)?\{/\{/;

# gather data
$cur_sinfo = $fcs_db->table('server')->single({"me.server_id" => $server_id});
$exp_cp_ver = $cur_sinfo->cp_version;

# compare gathered data from original data
if ($retval)
{
    isnt($cur_sinfo->cp_version, Fap::Global::kCP_VERSION(), "Can't reach the target Connect CP version after being interupted");
    # we should get a halt scenario at this point
    if ($retval == Fap::StateMachine::Unit::BU_CODE_HALT())
    {
        ok(1,'Its expected to halt process since host server needs to be upgraded first.');
        $success = 0;
    }
    # not expecting for an error here
    else
    {
        is($retval, Fap::StateMachine::Unit::BU_CODE_HALT(), "No error is expected at this point\n\n$err");
        $out ||= $order;
    }
} 
else
{
    is($cur_sinfo->cp_version, Fap::Global::kCP_VERSION(), "Reach the target Connect CP version.");
    $success = 1;
}
ok($exp_cp_ver, "Connect Server CP Version is now ${exp_cp_ver}.");


#-- New Orders Rollback --#
# execute the BU
$output = Fap::StateMachine::Worker->new( executable => $bu, input => $out )->run('-r');
$out = $output->{output};
$retval = $output->{return_code};
$err = $output->{error};
$out =~ s/^(.*\s)?\{/\{/;

# gather data
$cur_sinfo = $fcs_db->table('server')->single({"me.server_id" => $server_id});

# compare gathered data from original data
is($retval, Fap::StateMachine::Unit::BU_CODE_SUCCESS(), "Rollback executed successfully for Connect");
if ($success)
{
    is($cur_sinfo->cp_version, Fap::Global::kCP_VERSION(), "Connect CP version unchange after rollback");
}
else
{
    ok(
        Fap::Util::version_compare( $cur_sinfo->cp_version, '<', Fap::Global::kCP_VERSION()), 
        "Connect CP version unchange after rollback but unable to reach target version"
    );
}

#-- Cleanup the data --#
#order_bundle_detail
$dbh->do("delete from `order_bundle_detail` where order_bundle_detail_id = $order_bundle_detail_id");

#order_bundle
$dbh->do("delete from `order_bundle` where order_bundle_id = $order_bundle_id");

#order_group
$dbh->do("delete from `order_group` where order_group_id = $order_group_id");

#orders
$dbh->do("delete from `orders` where order_id = $order_id");
