use strict;
use warnings;
use Test::More qw( no_plan );
use Cwd qw( getcwd abs_path );
use Fap::StateMachine::Worker;

use_ok('Fap::StateMachine::Unit');
use_ok('Fap::Model::Fcs');
use_ok('Fap::Provider');
use_ok('Fap::Provider::Fusion');

my ($out, $err, $retval);
my $server_id = 500229;
my $fcs_db = Fap::Model::Fcs->new();
my $dbh = $fcs_db->dbh();

my $bu = abs_path('../fcs_order_did.pl');
ok(defined($bu), 'BU command identified');

#-- Setup the data --#
my $dids = [ '0507575893','0508318066'];
my $goal = scalar(@{$dids});    

#orders
$dbh->do("INSERT INTO `orders`(order_id, customer_id, order_type, record_type, order_status_id, provisioning_status_id, manager_approval_status_id, 
billing_approval_status_id, credit_approval_status_id, contact_id) VALUES ('',29179,'ADDON','ORDER',7,1,1,1,1,1)");
my $order_id = $dbh->last_insert_id(undef,undef,'orders','order_id');

#order_group
$dbh->do("INSERT INTO `order_group`(order_group_id, order_id, server_id, shipping_address_id, billing_address_id, product_id) VALUES ('',$order_id,$server_id,10000,10000,8)");
my $order_group_id = $dbh->last_insert_id(undef,undef,'order_group','order_group_id');

#order_bundle
my ($bundle_id) =  $dbh->selectrow_array("select bundle_id from bundle where name = 'did_number' and is_inventory=0");
if (!$bundle_id)
{
    $dbh->do("delete from `orders` where order_id = $order_id");
    $dbh->do("delete from `order_group` where order_id = $order_id");
    fail('VoIP database entry is missing');
    exit;
}    
$dbh->do("INSERT INTO `order_bundle`(order_bundle_id,bundle_id,order_group_id,quantity,list_price,one_time_total) VALUES ('',$bundle_id,$order_group_id,3,'5000.00','12000.00')");
my $order_bundle_id = $dbh->last_insert_id(undef,undef,'order_bundle','order_bundle_id');

#order_bundle_detail
foreach my $did (@{$dids})
{
    $dbh->do("INSERT INTO `order_bundle_detail`(order_bundle_detail_id,order_bundle_id,desired_did_number) VALUES ('',$order_bundle_id,'$did')");
}

my $order = '{"order_id" : ' . $order_id . '}';


#-- Orders Execute --#
# execute the BU
my $output = Fap::StateMachine::Worker->new( executable => $bu, input => $order )->run('-t');
$out = $output->{output};
$retval = $output->{return_code};
$err = $output->{error};
$out =~ s/^(.*\s)?\{/\{/;

if ($retval == Fap::StateMachine::Unit::BU_CODE_SUCCESS())
{
    my $cnt = 0;
    my $sth = $dbh->prepare("select alias_username from opensips.dbaliases where username=$server_id");
    $sth->execute;
    my $dbaliases = $sth->fetchall_arrayref({});
    
    foreach my $entry (@{$dbaliases})
    {
        my $data = $entry->{'alias_username'};
        $data =~ s/^81/0/g;
        $cnt++ if grep(/^$data$/, @{$dids});
    }
    
    is($cnt, $goal, 'All DIDs are present in dbaliases table.');
    $cnt = 0;

    $sth = $dbh->prepare("SELECT me.number FROM pbxtra.phone_numbers me WHERE server_id=$server_id");
    $sth->execute;
    my $phone_numbers = $sth->fetchall_arrayref({});
    
    foreach my $entry (@{$phone_numbers})
    {
        my $data = $entry->{'number'};
        $data =~ s/^81/0/g;
        $cnt++ if grep(/^$data$/, @{$dids});
    }
    
    is($cnt, $goal, 'All DIDs are present in phone_numbers table.');
    $cnt = 0;
    
    $sth = $dbh->prepare("SELECT me.did_number FROM order_bundle_detail me WHERE order_bundle_id = $order_bundle_id");
    $sth->execute;
    my $did_number = $sth->fetchall_arrayref({});
    
    foreach my $entry (@{$did_number})
    {
        my $data = $entry->{'did_number'};
        $data =~ s/^81/0/g;
        $cnt++ if grep(/^$data$/, @{$dids});
    }
    
    is($cnt, $goal, 'All DIDs are present in the did_number of the order_bundle_detail table.');
        
}
else
{
    is($retval, Fap::StateMachine::Unit::BU_CODE_SUCCESS(), "Not expecting any error!!!\nout : $out\nerr : $err");
    $out = $order;
}    

#-- Orders Rollback --#
# execute the BU
$output = Fap::StateMachine::Worker->new( executable => $bu, input => $out )->run('-r -t');
$out = $output->{output};
$retval = $output->{return_code};
$err = $output->{error};
$out =~ s/^(.*\s)?\{/\{/;


if ($retval == Fap::StateMachine::Unit::BU_CODE_SUCCESS())
{
    my $cnt = 0;
    my $sth = $dbh->prepare("SELECT me.did_number FROM order_bundle_detail me WHERE order_bundle_id = $order_bundle_id");
    $sth->execute;
    my $did_number = $sth->fetchall_arrayref({});
    
    foreach my $entry (@{$did_number})
    {
        my $data = $entry->{'did_number'};
        $data =~ s/^81/0/g;
        $cnt++ if grep(/^$data$/, @{$dids});
    }
    
    is($cnt, 0, 'All DIDs are removed from the did_number of the order_bundle_detail table.');
    
    $sth = $dbh->prepare("select alias_username from opensips.dbaliases where username=$server_id");
    $sth->execute;
    my $dbaliases = $sth->fetchall_arrayref({});
    $cnt = scalar(@{$dbaliases});
    
    is($cnt, 0, 'All new DIDs are removed from the dbaliases table.');

    $sth = $dbh->prepare("SELECT me.number FROM pbxtra.phone_numbers me WHERE server_id=$server_id");
    $sth->execute;
    my $phone_numbers = $sth->fetchall_arrayref({});
    $cnt = scalar(@{$phone_numbers});
    
    is($cnt, 0, 'All new DIDs are removed from the phone_numbers table.');
}
else
{
    is($retval, Fap::StateMachine::Unit::BU_CODE_SUCCESS(), "Not expecting any error from rollback!!!\nout : $out\nerr : $err");
}    

#-- Setup the data --#
#order_bundle_detail
$dbh->do("update `order_bundle_detail` set is_lnp = 1, did_number = '' where order_bundle_id = $order_bundle_id");

#-- LNP Orders Execute --#
# execute the BU
$output = Fap::StateMachine::Worker->new( executable => $bu, input => $order )->run('-t');
$out = $output->{output};
$retval = $output->{return_code};
$err = $output->{error};
$out =~ s/^(.*\s)?\{/\{/;

if ($retval == Fap::StateMachine::Unit::BU_CODE_SUCCESS())
{
    my $cnt = 0;
    my $sth = $dbh->prepare("select alias_username from opensips.dbaliases where username=$server_id");
    $sth->execute;
    my $dbaliases = $sth->fetchall_arrayref({});
    
    foreach my $entry (@{$dbaliases})
    {
        my $data = $entry->{'alias_username'};
        $data =~ s/^81/0/g;
        $cnt++ if grep(/^$data$/, @{$dids});
    }
    
    is($cnt, $goal, 'All LNPs are present in dbaliases table.');
    $cnt = 0;

    $sth = $dbh->prepare("SELECT me.number FROM pbxtra.phone_numbers me WHERE server_id=$server_id");
    $sth->execute;
    my $phone_numbers = $sth->fetchall_arrayref({});
    
    foreach my $entry (@{$phone_numbers})
    {
        my $data = $entry->{'number'};
        $data =~ s/^81/0/g;
        $cnt++ if grep(/^$data$/, @{$dids});
    }
    
    is($cnt, $goal, 'All LNPs are present in phone_numbers table.');
    $cnt = 0;

    $sth = $dbh->prepare("SELECT me.did_number FROM order_bundle_detail me WHERE order_bundle_id = $order_bundle_id");
    $sth->execute;
    my $did_number = $sth->fetchall_arrayref({});
    
    foreach my $entry (@{$did_number})
    {
        my $data = $entry->{'did_number'};
        $data =~ s/^81/0/g;
        $cnt++ if grep(/^$data$/, @{$dids});
    }
    
    is($cnt, $goal, 'All LNPs are present in the did_number of the order_bundle_detail table.');
}
else
{
    is($retval, Fap::StateMachine::Unit::BU_CODE_SUCCESS(), "Not expecting any error FOR LNP!!!\nout : $out\nerr : $err");
    $out = $order;
}    

#-- LNP Orders Rollback --#
# execute the BU
$output = Fap::StateMachine::Worker->new( executable => $bu, input => $out )->run('-r -t');
$out = $output->{output};
$retval = $output->{return_code};
$err = $output->{error};
$out =~ s/^(.*\s)?\{/\{/;


if ($retval == Fap::StateMachine::Unit::BU_CODE_SUCCESS())
{
    my $cnt = 0;
    my $sth = $dbh->prepare("SELECT me.did_number FROM order_bundle_detail me WHERE order_bundle_id = $order_bundle_id");
    $sth->execute;
    my $did_number = $sth->fetchall_arrayref({});
    
    foreach my $entry (@{$did_number})
    {
        my $data = $entry->{'did_number'};
        $data =~ s/^81/0/g;
        $cnt++ if grep(/^$data$/, @{$dids});
    }
    
    is($cnt, 0, 'All LNPs are removed from the did_number of the order_bundle_detail table.');
    
    $sth = $dbh->prepare("select alias_username from opensips.dbaliases where username=$server_id");
    $sth->execute;
    my $dbaliases = $sth->fetchall_arrayref({});
    $cnt = scalar(@{$dbaliases});
    
    is($cnt, 0, 'All new LNPs are removed from the dbaliases table.');

    $sth = $dbh->prepare("SELECT me.number FROM pbxtra.phone_numbers me WHERE server_id=$server_id");
    $sth->execute;
    my $phone_numbers = $sth->fetchall_arrayref({});
    $cnt = scalar(@{$phone_numbers});
    
    is($cnt, 0, 'All new LNPs are removed from the phone_numbers table.');
}
else
{
    is($retval, Fap::StateMachine::Unit::BU_CODE_SUCCESS(), "Not expecting any error from LNP rollback!!!\nout : $out\nerr : $err");
}    


#####################################################
# Clean up
#####################################################
#order_bundle_detail
$dbh->do("delete from `order_bundle_detail` where order_bundle_id = $order_bundle_id");

#order_bundle
$dbh->do("delete from `order_bundle` where order_bundle_id = $order_bundle_id");

#order_group
$dbh->do("delete from `order_group` where order_group_id = $order_group_id");

#orders
$dbh->do("delete from `orders` where order_id = $order_id");
