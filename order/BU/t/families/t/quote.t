#!/usr/bin/perl
#
# quote.t
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
use SM::Client;
use SM::Test qw(
    spawnUnit
);

my $cwd;
BEGIN {
    $cwd = getcwd;
    chdir((fileparse($0))[1]);
}

END {
    chdir($cwd);
}

my $smBinDir = (defined $ENV{SM_TARGET} ? $ENV{SM_TARGET} : '../../../../../SM');
my $smExe = abs_path($smBinDir.'/statemachine');
my $runSMExe = abs_path($smBinDir.'/tools/run_sm_test.pl');
my $testInput = abs_path('test.input');
my $testSteps = abs_path('test.steps');

my ($cmd,$out,$pid);

$cmd = "$runSMExe -i $testInput -s $testSteps -wg";
$out = `$cmd`;
ok(($out =~ m/Success/),'Creating test input and steps.');

# Retrieve created transaction input guid.
$out =~ m/transaction guid\((.*)\)/;
my $transGuid = $1;
ok($transGuid,'Retrieving created guid.');

# Can we run a test transaction?
$cmd = "$smExe -t $transGuid -DT";
diag("Running command: \"$cmd\"");
$pid = open2(*READ,*WRITE,$cmd);

ok($pid."Has State machine started?");

my $allPassed = 1;
while (my $read = <READ>) {
    chomp $read;
    last if !defined $read;

    # Did any jobs fail?
    if ( $read =~ /The job failed/ ) {
        $allPassed = 0;
        fail("A test job has failed: $read\n");
    }
    elsif ( $read =~ /Processing job:(.*)/ ) {
        diag("\tProcessing job:$1");
    }
    elsif ( $read =~ /Sequence:(.*)/ ) {
        diag("\t\tSequence:$1");
    }
    elsif ( $read =~ /Executable location:(.*)/ ) {
        diag("\t\tExecutable location:$1");
    }
    elsif ( $read =~ /Iterations left\.\.\.(.*)/ ) {
        diag("\t\tIteration count:$1");
    }
    elsif ( $read =~ /Has input\?\.\.\.(.*)/ ) {
        diag("\t\tHas input?$1");
    }
    elsif ( $read =~ /Has output\?\.\.\.(.*)/ ) {
        diag("\t\tHas output:$1");
    }
    elsif ( $read =~ /Return value:(.*)/ ) {
        diag("\t\tReturned:$1");
    }
    else {
        print "\t\t\t$read\n";
    }
}

ok($allPassed,"All test jobs passed?");

close READ;
close WRITE;

# Forceably kill the SM.
$out = kill 1,$pid;


__END__
