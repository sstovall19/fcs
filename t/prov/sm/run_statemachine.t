#!/usr/bin/perl

=pod

run_statemachine.t

This is a unit test for FCS provisionining State Machine which
integrates all of the FCS prov BUs into the right workflow setup by the FCS prov SM

=cut

use strict;
use warnings;

use Test::More qw( no_plan );
use Cwd qw( getcwd abs_path );
use File::Basename;
use Fap::StateMachine::Unit;
use Fap::StateMachine::Client;
use Fap::Model::Fcs;
use Fap;
use Fap::Global;
use Data::Dumper;

my $cwd;
BEGIN
{
    $cwd = getcwd;
    chdir((fileparse($0))[1]);
}

END
{
    chdir($cwd);
}

unless($ENV{FON_DIR})
{
    print "please set environment variable FON_DIR to the root of FCS trunk.\n";
    exit();
}

# select input and step files by username.
my $user = `whoami`;
chomp $user;

my $cmd;
my $out;
my $pid;
my $numSteps = 0;
my $transGuid;
my $dbh = new Fap::Model::Fcs();

# create test order
my $test_order = create_test_order($dbh);
if (!$test_order)
{
    print "Failed to create test order: $@\n";
    exit();
}
my $input = '{"order_id" : ' . $test_order->{'order_id'} . '}';
my @test_macs = ('0004F22CA1B6', '0004F22CA1B7');

# restart statemachine
if ($ENV{FCS_TEST})
{
    system(Fap->path_to("bin/statemachinectl restart"));
    sleep(5);
}

# start running the statemachine
my $client = Fap::StateMachine::Client->new();
if (!$client->ping()->{status})
{
    BAIL_OUT("NO STATE MACHINE!");
}

my $trans_step = $client->get_steps("PROV");

# check that we have steps defined
$numSteps = scalar(@{$trans_step->{data}->{steps}});
ok($numSteps,'Received the number of runnable steps?');

# check that we can submit to statemachine
my $res = $client->submit_transaction("PROV", $input);
ok($res->{status},"SUBMITTED TO STATE MACHINE $res->{guid}");

# run the steps
$client->run_transaction_monitored($res->{guid}, $ENV{FON_DIR});

my $trans_status = $client->get_transaction_status($res->{guid});

# handle first BU HALT in fcs_notify_provisioner_to_scan_phones
if ($trans_status->{status} =~ /HALTED/ && $trans_status->{sequence_name} eq 'K')
{
    # simulate scanning of phones by creating order_bundle_detail for the bundle id 42
    my $rs = $dbh->table('order_bundle')->find( { order_group_id => $test_order->{'order_group_id'}, bundle_id => 42 });
    if ($rs)
    {
        my $ob_id = $rs->get_column('order_bundle_id');
        foreach my $mac (@test_macs)
        {
            my $obd_id = $dbh->table('order_bundle_detail')->create( {
                order_bundle_id => $ob_id,
                mac_address => $mac
            } )->order_bundle_detail_id;

            push( @{$test_order->{'order_bundle_detail_ids'}}, $obd_id);
        }
    }

    # restart the statemachine
    $client->run_transaction_monitored($res->{guid}, $ENV{FON_DIR});
    $trans_status = $client->get_transaction_status($res->{guid});
}

my @test_polycom_logs;
# handle second BU HALT in fcs_notify_provisioner_to_connect_phones
if ($trans_status->{status} =~ /HALTED/ && $trans_status->{sequence_name} eq 'N')
{
    # get the server id provisioned
    my $rs = $dbh->table('order_group')->find( { order_id => $test_order->{'order_id'} });
    my $server_id;
    if ($rs)
    {
        $server_id = $rs->get_column('server_id');
    }

    ok($server_id, "Server ID provisioned");
    if ($server_id)
    {
	    # simulate connecting of phones to the prov box which will create a <mac>-boot.log files
	    foreach my $mac (@test_macs)
	    {
		my $file = Fap::Global::kNFS_MOUNT() . '/' . $server_id .
		Fap::Global::kPHONE_CONFIG_DIRECTORY() . '/' . $mac . '-boot.log';
		push(@test_polycom_logs, $file);
		system("/bin/touch $file");
		ok(-e $file, "polycom test boot file created: $file");
	    }

	    # restart the satemachine
	    $client->run_transaction_monitored($res->{guid}, $ENV{FON_DIR});
	    $trans_status = $client->get_transaction_status($res->{guid});
    }
}
 
# check for success for all other BU
if ($trans_status->{status} !~ /SUCCESS/)
{
    fail( sprintf("PROV FAILED AT '%s' %d of %d (%s):\n\n%s\n\n",
        $trans_status->{description},
        $trans_status->{steps_passed} + 1,
        $trans_status->{steps},
        $trans_status->{status},
        $trans_status->{error}
    ) );
}
else
{
    ok("Transaction success!");
}

# delete the test data
ok(delete_test_order($dbh, $test_order), "Deleted test order");
foreach my $test_log (@test_polycom_logs)
{
    system("/bin/rm $test_log");
    ok(! -e $test_log, "polycom test boot file deleted");
}

# stop the test statemachine
if ($ENV{FCS_TEST})
{
    system(Fap->path_to("bin/statemachinectl stop"));
}

=head2 create_test_order()

=over 4

Create the test order to feed into the provisioning statemachine

Args: $dbh
Returns: hashref of ids created

=back

=cut
sub create_test_order
{
    my $dbh = shift;

    if (!defined($dbh) || ref($dbh) ne 'Fap::Model::Fcs')
    {
        Fap->trace_error('Invalid dbh param');
        return undef;
    }

    my $order = {};

    # create the order
    $order->{'order_id'} = $dbh->table('orders')->create( {
        contact_id => 1,
        customer_id => 29179,
        order_status_id => 9,
        order_type => 'NEW',
        record_type => 'ORDER'
    } )->order_id;

    # create the order group
    $order->{'order_group_id'} = $dbh->table('order_group')->create( {
        order_id => $order->{'order_id'},
        is_primary => 1,
	shipping_address_id => 1,
        billing_address_id => 1,
	product_id => 7
    } )->order_group_id;

    # create the order bundles
    $order->{'order_bundle_ids'} = [];
    my @order_bundles = (
        { 'bundle_id' => 54, 'quantity' => 2 },
        { 'bundle_id' => 29, 'quantity' => 1 },
        { 'bundle_id' => 83, 'quantity' => 2 },
        { 'bundle_id' => 82, 'quantity' => 2 },
        { 'bundle_id' => 86, 'quantity' => 2 },
        { 'bundle_id' => 87, 'quantity' => 2 },
        { 'bundle_id' => 89, 'quantity' => 1 },
        { 'bundle_id' => 42, 'quantity' => 2 },
        { 'bundle_id' => 84, 'quantity' => 2 },
        { 'bundle_id' => 90, 'quantity' => 2 },
        { 'bundle_id' => 91, 'quantity' => 2 },
        { 'bundle_id' => 96, 'quantity' => 1 },
        { 'bundle_id' => 71, 'quantity' => 1 },
        { 'bundle_id' => 160, 'quantity' => 1 }
    );

    my $did_ob_id;
    foreach my $ob (@order_bundles)
    {
        my $ob_id = $dbh->table('order_bundle')->create( {
            order_group_id => $order->{'order_group_id'},
            bundle_id => $ob->{'bundle_id'},
            quantity => $ob->{'quantity'}
        } )->order_bundle_id;
        # 54 is the did_number bundle
        if ($ob->{'bundle_id'} == 54)
        {
            $did_ob_id = $ob_id;
        }

        push( @{$order->{'order_bundle_ids'}}, $ob_id );
    }

    if (!$did_ob_id)
    {
       Fap->trace_error("DID order bundle not created");
       return undef;
    }

    # create the order bundle detail for the dids
    $order->{'order_bundle_detail_ids'} = [];
    my @desired_dids = ('215','215');
    foreach my $did (@desired_dids)
    {
        my $detail_id = $dbh->table('order_bundle_detail')->create( {
            order_bundle_id => $did_ob_id,
            desired_did_number => $did
        } )->order_bundle_detail_id;

        push( @{$order->{'order_bundle_detail_ids'}}, $detail_id );
    }

    return $order;
}

=head2 delete_test_order()

=over 4

delete the test order from this unit test

Args: $dbh, $order hashref
Returns: 1 if succesfull, undef otherwise

=back

=cut
sub delete_test_order
{
    my ($dbh, $order) = @_;

    if (!defined($dbh) || ref($dbh) ne 'Fap::Model::Fcs')
    {
        Fap->trace_error('Invalid dbh param');
        return undef;
    }

    if (!defined($order) || ref($order) ne 'HASH')
    {
        Fap->trace_error('Invalid order param');
        return undef;
    }

    # delete the order_bundle_detail
    $dbh->table('order_bundle_detail')->search( { order_bundle_detail_id => { -in => $order->{'order_bundle_detail_ids'} } } )->delete;

    # delete the order_bundle
    $dbh->table('order_bundle')->search( { order_bundle_id => { -in => $order->{'order_bundle_ids'} } } )->delete;

    # delete the order_group
    $dbh->table('order_group')->search( { order_group_id => $order->{'order_group_id'} } )->delete;
    
    # delete the order
    $dbh->table('order')->search( { order_id => $order->{'order_id'} } )->delete;

    return 1;
}

__END__
