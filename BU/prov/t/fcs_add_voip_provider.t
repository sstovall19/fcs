use strict;
use warnings;
use Test::More qw( no_plan );
use Cwd qw( getcwd abs_path );
use File::Basename;
use JSON::XS;
use Fap::StateMachine::Worker;

use_ok('Fap::StateMachine::Unit');
use_ok('Fap::Model::Fcs');
use_ok('Fap::Provider');
use_ok('Fap::Provider::Symbio');
use_ok('Fap::Provider::Fusion');
use_ok('Fap::Provider::Inphonex');
use_ok('F::VOIP');

my ($out, $err, $retval);
my $server_id = 18801;
my $fcs_db = Fap::Model::Fcs->new();
my $dbh = $fcs_db->dbh();

my $bu = abs_path('../fcs_add_voip_provider.pl');
ok(defined($bu), 'BU command identified');

#-- Setup the data --#
my $sth = $dbh->prepare('select c.alpha_code_3,p.name from provider p join provider_country pc using (provider_id) join country c using (country_id)');
$sth->execute;
my $providers = $sth->fetchall_arrayref({});

#orders
$dbh->do("INSERT INTO `orders`(order_id, customer_id, order_type, record_type, order_status_id, provisioning_status_id, manager_approval_status_id, 
billing_approval_status_id, credit_approval_status_id, contact_id) VALUES ('',29179,'ADDON','ORDER',7,1,1,1,1,1)");
my $order_id = $dbh->last_insert_id(undef,undef,'orders','order_id');

#order_group
$dbh->do("INSERT INTO `order_group`(order_group_id, order_id, server_id, shipping_address_id, billing_address_id, product_id) VALUES ('',$order_id,$server_id,10000,10000,8)");
my $order_group_id = $dbh->last_insert_id(undef,undef,'order_group','order_group_id');

#order_bundle
my ($bundle_id) =  $dbh->selectrow_array("select bundle_id from bundle where name = '$providers->[0]->{'name'}' and is_inventory=0");
if (!$bundle_id)
{
    $dbh->do("delete from `orders` where order_id = $order_id");
    fail('VoIP database entry is missing');
    exit;
}    
$dbh->do("INSERT INTO `order_bundle`(order_bundle_id,bundle_id,order_group_id,quantity,list_price,one_time_total) VALUES ('',$bundle_id,$order_group_id,3,'5000.00','12000.00')");
my $order_bundle_id = $dbh->last_insert_id(undef,undef,'order_bundle','order_bundle_id');

#order_bundle_detail
$dbh->do("INSERT INTO `order_bundle_detail`(order_bundle_detail_id,order_bundle_id) VALUES ('',$order_bundle_id)");
my $order_bundle_detail_id = $dbh->last_insert_id(undef,undef,'order_bundle_detail','order_bundle_detail_id');

my $order = '{"order_id" : ' . $order_id . '}';
my $orig_sinfo = $fcs_db->table('Server')->single({"me.server_id" => $server_id});


#####################################################
# Generic test for Servers with existing providers
# This test is true for Inphonex, Symbio, and Fusion
#####################################################
$fcs_db->table('Server')->search({'server_id' => $server_id})->update({'provider_type' => 'YadaYadaYada'});

# execute the BU
my $output = Fap::StateMachine::Worker->new( executable => $bu, input => $order )->run('-t');
$out = $output->{output};
$retval = $output->{return_code};
$err = $output->{error};
$out =~ s/^(.*\s)?\{/\{/;

# gather data
my $cur_sinfo = $fcs_db->table('Server')->single({"me.server_id" => $server_id});

# compare gathered data from original data
is($cur_sinfo->provider_type, 'YadaYadaYada', "No change for Servers with existing providers");

#-- Addon Orders Rollback --#
# execute the BU
$output = Fap::StateMachine::Worker->new( executable => $bu, input => $out )->run('-r -t');
$out = $output->{output};
$retval = $output->{return_code};
$err = $output->{error};
$out =~ s/^(.*\s)?\{/\{/;

# gather data
$cur_sinfo = $fcs_db->table('server')->single({"me.server_id" => $server_id});

# compare gathered data from original data
is($cur_sinfo->provider_type, 'YadaYadaYada', "No change for Servers with existing providers after rollback");
$fcs_db->table('Server')->search({'server_id' => $server_id})->update({'provider_type' => undef});

#####################################################
# Generic test for Inphonex, Symbio, and Fusion
#####################################################
my $done = {};
foreach my $provider (@{$providers})
{
    ($bundle_id) = $dbh->selectrow_array("select bundle_id from bundle where name = '$provider->{'name'}' and is_inventory=0");
    next if $done->{$bundle_id};
    $fcs_db->table('OrderBundle')->search({'order_bundle_id' => $order_bundle_id})->update({'bundle_id' => $bundle_id});
    $fcs_db->table('EntityAddress')->search({'entity_address_id' => 10000})->update({'country' => $provider->{'alpha_code_3'}});
    my $cnt = 0;
    # execute the BU
    $output = Fap::StateMachine::Worker->new( executable => $bu, input => $order )->run('-t');
    $out = $output->{output};
    $retval = $output->{return_code};
    $err = $output->{error};

    $out =~ s/^(.*\s)?\{/\{/;

    # gather data
    $cur_sinfo = $fcs_db->table('Server')->single({"me.server_id" => $server_id});

    # compare gathered data from original data
    if ($retval == Fap::StateMachine::Unit::BU_CODE_SUCCESS())
    {
        my $json = JSON::XS->new->utf8->pretty->allow_nonref->decode($out);
        $fcs_db->dbh('pbxtra');
        my $voip = F::VOIP->new($dbh, $server_id);
        my $details = $voip->get_provider_details($json->{'added_provider'}->{$order_group_id}->{'added_voip_sip'});
        $cnt = $voip->number_of_voip_accounts();
        is(ref($details),'HASH',"Confirmed its a successful add for the $provider->{'name'} provider");
        $fcs_db->switch_db('fcs');
        isnt($cur_sinfo->provider_type, $orig_sinfo->provider_type, "Server's provider info is been defined under $provider->{'name'} provider");
        ok($cur_sinfo->provider_type, "Server's provider is set to " . $cur_sinfo->provider_type);
    }
    else
    {
        is($retval, Fap::StateMachine::Unit::BU_CODE_SUCCESS(), "Not expecting any error for $provider->{'name'} provider\nout : $out\nerr : $err");
        last;
    }    

    #-- Addon Orders Rollback --#
    # execute the BU
    $output = Fap::StateMachine::Worker->new( executable => $bu, input => $out )->run('-r -t');
    $out = $output->{output};
    $retval = $output->{return_code};
    $err = $output->{error};
    $out =~ s/^(.*\s)?\{/\{/;

    # gather data
    $cur_sinfo = $fcs_db->table('server')->single({"me.server_id" => $server_id});

    # compare gathered data from original data
    if ($retval == Fap::StateMachine::Unit::BU_CODE_SUCCESS())
    {
        $fcs_db->dbh('pbxtra');
        my $voip = F::VOIP->new($dbh, $server_id);
        ok($voip->number_of_voip_accounts() < $cnt,"Confirmed diminished $provider->{'name'} voip account on server");
        $fcs_db->switch_db('fcs');
        is($cur_sinfo->provider_type, $orig_sinfo->provider_type, "Server's back to original setting after this $provider->{'name'} rollback");
    }
    else
    {
        is($retval, Fap::StateMachine::Unit::BU_CODE_SUCCESS(), "Not expecting any error for $provider->{'name'} rollback\nout : $out\nerr : $err");
	last;
    }
    $done->{$bundle_id} = 1;
}


#####################################################
# Clean up
#####################################################
$fcs_db->table('EntityAddress')->search({'entity_address_id' => 10000})->update({'country' => 'PH'});

#order_bundle_detail
$dbh->do("delete from `order_bundle_detail` where order_bundle_id = $order_bundle_id");

#order_bundle
$dbh->do("delete from `order_bundle` where order_bundle_id = $order_bundle_id");

#order_group
$dbh->do("delete from `order_group` where order_group_id = $order_group_id");

#orders
$dbh->do("delete from `orders` where order_id = $order_id");

# this server has no voip provider set up and it will stay that way
$fcs_db->switch_db('pbxtra');
my $voip = F::VOIP->new($dbh, $server_id);
my $cnt = $voip->number_of_voip_accounts();
if ($cnt > 0) 
{
    my $accts = $voip->list_voip_accounts();
    foreach my $acct (@{$accts})
    {
        if ($voip->delete_voip_account($acct->{'NAME'}))
        {
            $voip->commit();
            if ($acct->{'REG'} =~ /siprealm.com/)
            {
                $dbh->do("delete from `unbound_map` where server_id = $server_id");
            }
            $dbh->do("update server set provider_type=null,provider_customer_id=null,provider_password=null,virtual_number=null,inphonex_pin=null where server_id = $server_id");
            $fcs_db->switch_db('fcs');
            $dbh->do("delete from server_provider where server_id = $server_id");
            $fcs_db->switch_db('pbxtra');
        }    
    }
}
