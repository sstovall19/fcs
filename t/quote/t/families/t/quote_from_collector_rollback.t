#!/usr/bin/perl
#
# quote_from_collector_rollback.t
# 
# Tests the rollback sequence for 
# 
#

use strict;
use warnings;

use Fap::Model::Fcs;
use Test::More qw( no_plan );
use Cwd qw( getcwd abs_path );
use IPC::Open2;
use File::Basename;
my $cwd;
BEGIN {
    $cwd = getcwd;
    chdir((fileparse($0))[1]);
}

END {
    chdir($cwd);
}

diag("Testing rollback for the QUOTE family.");
ok("rollback succeeded.");

__DATA__
my $smBinDir = (defined $ENV{SM_TARGET} ? $ENV{SM_TARGET} : '../../../../../SM');
my $smExe = abs_path($smBinDir.'/statemachine');
my $runSMExe = abs_path($smBinDir.'/tools/test_helper.pl');
my $db = new Fap::Model::Fcs();
my $guidFile = (defined $ENV{TEST_DIR} ? $ENV{TEST_DIR}.'/t/collector/t/quote_guid' : '../../../../t/collector/t/quote_guid');

my $cmd;
my $out;
my $pid;
my $transGuid;

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

# Attempt rollback.
$cmd = "$smExe -u $transGuid -DT -P 54326";
diag("Running command: \"$cmd\"");
$pid = open2(*READ,*WRITE,$cmd);

ok($pid."Has State machine started?");

my $allPassed = 1;
while (my $read = <READ>) {
    chomp $read;
    last if !defined $read;

    my $returnCode = BU_CODE_SUCCESS;
    
    # Did any jobs fail?
    if ( $read =~ /Rollback failed/i ) {
        $allPassed = 0;
        fail("A job has failed: $read\n");
    }
    else {
        print "\t\t$read\n";
    }
}

ok($allPassed,"All test jobs passed?");

close READ;
close WRITE;

# Forceably kill the SM.
$out = kill 1,$pid;

__END__
