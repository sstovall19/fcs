use strict;
use warnings;
use Test::More qw( no_plan );
use Cwd qw( getcwd abs_path );
use File::Basename;
use Fap::StateMachine::Worker;

use_ok('Fap::StateMachine::Unit');
use_ok('Fap::Bundle');
use_ok('Fap::Global');
use_ok('Fap::Model::Fcs');

my $fcs_db = Fap::Model::Fcs->new();
my $dbh = $fcs_db->dbh();
my $server_id = 18801;
my $bu = abs_path('../fcs_notify_provisioner_to_connect_phones.pl');
ok(defined($bu), 'BU command identified');
my ($out, $err, $retval);

#-- Setup the data --#
#orders
$dbh->do("INSERT INTO `orders`(order_id, customer_id, order_type, record_type, order_status_id, provisioning_status_id, manager_approval_status_id, 
billing_approval_status_id, credit_approval_status_id, contact_id) VALUES ('',29179,'ADDON','ORDER',7,1,1,1,1,1)");
my $order_id = $dbh->last_insert_id(undef,undef,'orders','order_id');

#order_group
$dbh->do("INSERT INTO `order_group`(order_group_id, order_id, server_id, shipping_address_id, billing_address_id, product_id) VALUES ('',$order_id,$server_id,10000,10000,8)");
my $order_group_id = $dbh->last_insert_id(undef,undef,'order_group','order_group_id');

#order_bundle
my ($cat_id) =  $dbh->selectrow_array("select bundle_category_id from bundle_category where name = 'phone'");
my ($bundle_id) =  $dbh->selectrow_array("select bundle_id from bundle where category_id=$cat_id and is_inventory=1");
$dbh->do("INSERT INTO `order_bundle`(order_bundle_id,bundle_id,order_group_id,quantity,list_price,one_time_total) VALUES ('',$bundle_id,$order_group_id,3,'5000.00','12000.00')");
my $order_bundle_id = $dbh->last_insert_id(undef,undef,'order_bundle','order_bundle_id');

#order_bundle_detail
my @phone_mac = qw/0004F221BE9 0004F221BED 0004F221CE9/;
foreach my $mac (@phone_mac)
{
    $dbh->do("INSERT INTO `order_bundle_detail`(order_bundle_detail_id,order_bundle_id,mac_address) VALUES ('',$order_bundle_id,'$mac')");
}    

my $order = '{"order_id" : ' . $order_id . '}';

###############################################################################
# 1st run, its expected that this BU will halt if it contains phone orders
###############################################################################
my $output = Fap::StateMachine::Worker->new( executable => $bu, input => $order )->run('-t');
$out = $output->{output};
$retval = $output->{return_code};
$err = $output->{error};
$out =~ s/^(.*\s)?\{/\{/;
if ($retval == Fap::StateMachine::Unit::BU_CODE_HALT())
{
    ok(1, "BU halted after firing up an email to the provisioners");
}
else
{
    is($retval, Fap::StateMachine::Unit::BU_CODE_HALT(), "out : $out\n==============\nerr : $err\n==============\nretval : $retval");
}

###############################################################################
# Now we simulate the human activity by creating boot log files
###############################################################################
my @logs;
foreach my $mac (@phone_mac)
{
    # ok we've found a newly provisioned phone here
    my $file = Fap::Global::kNFS_MOUNT() . '/' . $server_id . 
        Fap::Global::kPHONE_CONFIG_DIRECTORY() . '/' . $mac . '-boot.log';
    push(@logs, $file);
    system("/bin/touch $file");
    ok(-e $file,"created $file");
}

################################################################################
# 2nd run, simulated State Machine restart and human did what they need to do
################################################################################
$output = Fap::StateMachine::Worker->new( executable => $bu, input => $out )->run('-t');
$out = $output->{output};
$retval = $output->{return_code};
$err = $output->{error};
$out =~ s/^(.*\s)?\{/\{/;
if ($retval == Fap::StateMachine::Unit::BU_CODE_SUCCESS())
{
    ok(1, "BU restart was successful");
}
else
{
    is($retval, Fap::StateMachine::Unit::BU_CODE_SUCCESS(), "out : $out\n==============\nerr : $err\n==============\nretval : $retval");
}

################################################################################
# 3rd run, rollback
################################################################################
$output = Fap::StateMachine::Worker->new( executable => $bu, input => $out )->run('-r');
$out = $output->{output};
$retval = $output->{return_code};
$err = $output->{error};
$out =~ s/^(.*\s)?\{/\{/;
if ($retval == Fap::StateMachine::Unit::BU_CODE_SUCCESS())
{
    ok(1, "Rollback was successfull");
}
else
{
    is($retval, Fap::StateMachine::Unit::BU_CODE_SUCCESS(), "out : $out\n==============\nerr : $err\n==============\nretval : $retval");
}

################################################################################
# clean up, make sure that those generated boot logs are indeed gone.
################################################################################
foreach (@logs)
{
    unlink($_);
}

#order_bundle_detail
$dbh->do("delete from `order_bundle_detail` where order_bundle_id = $order_bundle_id");

#order_bundle
$dbh->do("delete from `order_bundle` where order_bundle_id = $order_bundle_id");

#order_group
$dbh->do("delete from `order_group` where order_group_id = $order_group_id");

#orders
$dbh->do("delete from `orders` where order_id = $order_id");
