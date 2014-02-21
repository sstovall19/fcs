#!/usr/bin/perl
#
# order.t
# 
# Houses tests for the QRDER family sequence.
# 
#

use strict;
use warnings;

use Test::More qw( no_plan );
use Cwd qw( getcwd abs_path );
use IPC::Open2;
use File::Basename;
use Fap::StateMachine::Unit;
use SM::Test qw(
    spawnUnit
);
use Fap::Model::Fcs;
use Try::Tiny;

use constant STEP_SCHEMA => 'TransactionStep';
use constant JOB_SCHEMA  => 'TransactionJob';

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
my $runSMExe = abs_path($smBinDir.'/tools/test_helper.pl');
my $db = new Fap::Model::Fcs();

# select input and step files by username.
my $user = `whoami`;
chomp $user;

my $testInput = (-f "$user.input") ? abs_path("$user.input") : abs_path('test.input');
my $testSteps = (-f "$user.steps") ? abs_path("$user.steps") : abs_path('test.steps'); 

my ($cmd,$out,$pid);

my $steps;
my @tests;
my $numSteps = 0;
{
    local $/;
    open TS,$testSteps or fail("Couldn't read from step file '$testSteps'");
    $steps = eval <TS>;
    close TS;
    
    if ( !scalar(@$steps) ) {
        fail("$testSteps is empty. You can create your own step file under '$user.steps'");
    }
   
    for my $step (@$steps) {
       if (exists $step->{_test}) {
           $numSteps++ unless (defined $step->{test}{run} && $step->{test}{run} == 0);
           push @tests,$step->{_test};
           delete $step->{_test};
       }
       else {
           push @tests,undef; 
       }
    }
}

$cmd = "$runSMExe -i $testInput -s $testSteps -wg";
diag("Running: $cmd");
$out = `$cmd`;
ok(($out =~ m/Success/),'Creating test input and steps.');

# Retrieve created transaction input guid.
$out =~ m/transaction guid\((.*)\)/;
my $transGuid = $1 || undef;
ok($transGuid,'Retrieving created guid.');

$out =~ m/test familyname\((.*)\)/;
my $testFamilyName = $1 || undef;
ok($testFamilyName,'Retrieving test familyname.');

# Can we run a test transaction?
$cmd = "$smExe -t $transGuid -DT";
diag("Running command: \"$cmd\"");
$pid = open2(*READ,*WRITE,$cmd);

ok($pid."Has State machine started?");

my $allPassed = 1;
my $onStep = 0;
my $lastStep = '';
while (my $read = <READ>) {
    chomp $read;
    last if !defined $read;

    my $testConstraints;
    my $returnCode = 1;
    
    if ( defined $tests[$onStep] ) {
        $testConstraints = $tests[$onStep];
        $returnCode = $tests[$onStep]->{return_code};
    }

    # Did any jobs fail?
    if ( $read =~ /The job failed/ ) {
        $allPassed = 0;
        fail("A test job has failed: $read\n");
    }
    elsif ( $read =~ /Processing job:(.*)/ ) {
        diag("\tProcessing job:$1");
        if ( $1 ne $lastStep ) {
            $lastStep = $1;
            $onStep++;
        }
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
    elsif ( $read =~ /Return value:\s?(.*)/ ) {
        diag("\t\tReturned: $1");
        is($1,$returnCode,"Returns success?");
    }
    elsif ( $read =~ /Familyname:\s?(.*)/ ) {
        diag("\t\tFamilyname: $1");
    }
    elsif ( $read =~ /Job creation failed/ ) {
        $allPassed = 0;
        fail("Job creation failed.");
    }
    else {
        print "\t\t$read\n";
    }
}

is($onStep,$numSteps,"Have all $numSteps run?");
ok($allPassed,"All test jobs passed?");

close READ;
close WRITE;

# Forceably kill the SM.
$out = kill 1,$pid;

# Delete the testfamily namne from transaction_job and transaction_step;
try {
    my @steps = $db->table(STEP_SCHEMA)->search({ familyname => $testFamilyName });
    my @jobs = $db->table(JOB_SCHEMA)->search({ familyname => $testFamilyName });
    map { $_->delete; } @steps,@jobs;
}
catch {
    diag("Unable to clean up steps and jobs: $_");
};

__END__
