#!/usr/bin/perl
#
# quote_from_collector.t
# 
# Houses tests for the QUOTE family sequence.
# 
#

use strict;
use warnings;

use Test::More qw( no_plan );
use Cwd qw( getcwd abs_path );
use IPC::Open2;
use File::Basename;
use Fap::StateMachine::Unit;
use Fap::StateMachine::Client;
use Fap::Model::Fcs;
use Fap;
use Data::Dumper;
use Try::Tiny;

my $cwd;
BEGIN {
    $cwd = getcwd;
    chdir((fileparse($0))[1]);
}

END {
    chdir($cwd);
}

# select input and step files by username.
my $user = `whoami`;
chomp $user;
my $db = new Fap::Model::Fcs();
my $guidFile = "/dev/shm/quote_guid";

my $cmd;
my $out;
my $pid;
my $numSteps = 0;
my $transGuid;
if ($ENV{FCS_TEST}) {
	system(Fap->path_to("bin/statemachinectl start"));
}
my $client = Fap::StateMachine::Client->new();
if (!$client->ping()->{status}) {
	BAIL_OUT("NO STATE MACHINE!");
}
my $trans_step = $client->get_steps("QUOTE");
$numSteps = scalar(@{$trans_step->{data}->{steps}});

#$numSteps = scalar(@{$trans+step->{data $1 if $1;
ok($numSteps,'Received the number of runnable steps?');

# Retrieve created transaction guid.
if ( !-f $guidFile )
{
    fail("Couldn't read the transaction guid from the file: \"$guidFile\". It doesn't exist.");
}

open GUID,"$guidFile" or fail("Couldn't read the transaction guid from the file: \"$guidFile\". It didn't open.");
$transGuid = <GUID>;
close GUID;

ok($transGuid,'Retrieving created guid.');

if (!defined $transGuid)
{
    BAIL_OUT("The Collector didn't return a guid. There's no point in continuing this test.");
}

# Can we run a test transaction?

$client->run_transaction_monitored($transGuid,$ENV{FON_DIR});
my $trans_status = $client->get_transaction_status($transGuid);
if ($trans_status->{status}!~/SUCCESS|RUNNING/) {
	fail(sprintf("QUOTE FAILED AT '%s' %d of %d:\n\n%s\n\n",$trans_status->{description},$trans_status->{steps_passed}+1,$trans_status->{steps},$trans_status->{error}));
}
	

__END__
