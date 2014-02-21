#!/usr/bin/perl
#
# EK - This script could easily become a procedural mess if it gets much larger.
# That shouldn't happen, but please refactor this if you're thinking about
# adding functionality.
#

use strict;
use warnings;

use SM::Config qw(
    SM_DSN
    SM_USER
    SM_PASS
);
use SM::DB;
use JSON::XS;
use Data::Dumper;
use Data::UUID;
use SM::Model::Transaction;
use Getopt::Std;
use Cwd qw( getcwd abs_path );
use File::Basename;

my $cwd = getcwd;
BEGIN {
    chdir((fileparse($0))[1]);
}

END {
    chdir($cwd);
}

my %OPTS;
getopts('i:s:cm:owg',\%OPTS);

my $printUsage = sub {
    print "\nUsage: $0"
     ."\n\t -i <input file> - The path to the file containing the json input. Possibly created by transaction_submit_input_fetch.pl."
     ."\n\t -s <step file> - The path to the step file."
     ."\n\t -c - (optional) Set to remove records from the transaction* tables when finished."
     ."\n\t -m <path to statemachine> - (optional) Path to the state machine to use."
     ."\n\t -o - (optional) Set to have input/ouput files for each job written to the cwd."
     ."\n\t -w - (optional) Writes input and steps to the db. Doesn't call the SM." #Does not randomize \"familyname\" and doesn't call the SM." 
     ."\n\t -g - (optional) Set to return the guid created for the transaction."
     ."\n\n";
};

my $submitFile = defined $OPTS{i} ? $OPTS{i} : undef;
my $stepFile = defined $OPTS{s} ? $OPTS{s} : undef;
my $cleanUp = $OPTS{c} ? 1 : 0;
my $smPath = defined $OPTS{m} ? $OPTS{m} :  '../statemachine';
my $writeIO = $OPTS{o} ? 1 : 0;
my $modeWrite = $OPTS{w} ? 1 : 0;
my $returnGuid = $OPTS{g} ? 1 : 0;

my $json = JSON::XS->new->ascii->pretty->allow_nonref;

# Make sure we have what we need to run properly.
if ( !defined $submitFile || !defined $stepFile ) {
    &$printUsage;
    exit(0);
}

# Get the absolute paths to the argument files.
$submitFile = abs_path($submitFile);
$stepFile = abs_path($stepFile);
$smPath = abs_path($smPath);

if ( -x $smPath ) {
    print "Using the state machine at \"$smPath\"\n";
}
else {
    print "Can't find the state machine at \"$smPath\"...";
    &$printUsage;
    exit(0);
}

#print "Connecting to ".SM_DSN." as ".SM_USER."\n";
our $DB = SM::DB->new(dsn => SM_DSN, user => SM_USER, pass => SM_PASS);

# Slurp up that json submit file.
my $input;
$/ = undef;

my $rv = open (SUB,$submitFile);
if (!$rv) {
    print "Couldn't open the transaction input file: $!\n";
    exit(0);
}

binmode SUB;
$input = <SUB>;
close SUB;

if ( !$input ) {
    print "The transaction submission file is empty!\n";
    exit(0);
}

# Slurp in the steps file.
my $steps;
$rv = open (STEP,$stepFile);
if (!$rv) {
    print "Couldn't open the transaction step file: $!\n";
    exit(0);
}

binmode STEP;
$steps = <STEP>;
close STEP;

if ( !$steps ) {
    print "The transaction steps file is empty.!\n";
    exit(0);
}

$steps = eval $steps;
if ( ref($steps) ne 'ARRAY' ) {
    print "The transaction steps file is not in the correct format.!\n";
    exit(0);
}

my $header = shift @$steps;

if ( !defined $header->{familyname} ) {
    print "You must include familyname in the \"header\" portion in \"$stepFile\".\n";
    exit(0);
}

# Create the transaction in transaction_submit.
my $testFamilyName;

#if ( $modeWrite ) {
#    $testFamilyName = $header->{familyname};
#}
#else {
    my $time = time();
    $time = substr($time,(length($time)-4),length($time));
    $testFamilyName = $time.'T_'.$header->{familyname};
    $testFamilyName = substr($testFamilyName,0,15); # familyname is varchar(16) in the db. damn that's needlessly short.
#}

# Generate the guid.
my $guid = Data::UUID->new();
$guid = $guid->to_string($guid->create_hex());

my $subRow = $DB->table("TransactionSubmit")->create({
    guid => $guid,
    familyname => $testFamilyName,
    input => $input,
    status => 'RUNNING', # so that it's guaranteed to not be picked up by any running SM.
});

my $transStep = new SM::Model::Transaction( db => $DB );

my @stepObj;
foreach my $step (@$steps) {
    $step->{familyname} = $testFamilyName;
    push @stepObj,$transStep->createStep(%$step);
}

# Exit early if write mode is on.
if ( $modeWrite ) {
   cleanUp($subRow,\@stepObj) if $cleanUp;
   exitSuccess("Write Mode is on. Finished.\n");
}

# Start the statemachine.
my @smArgs = ( "-f $testFamilyName", '-P 51111', '-D', "-t \"$guid\"" );
push @smArgs,'-T' if $writeIO; 
my $cmdArgs = join ' ',@smArgs;
my $cmd = "$smPath $cmdArgs";
my $ret = `$cmd`;

#EK make this below work!
if ( $writeIO ) {
    while ( $ret =~ /.*JOB_BEGIN(.*)JOB_END.*/ ) {
    print Dumper($1);

    }
exit(0);
}
else {
    print "\nReturned from \"$smPath\":\n".$ret."\n";
}

cleanUp($subRow,\@stepObj) if $cleanUp;

exitSuccess();

sub cleanUp {
    my $sub = shift;
    my $stepObjs = shift;
    print "Auto clean up is on. Removing everything from the DB.\n";
    $sub->delete;
    map { $_->delete; } @$stepObjs;
}

sub exitSuccess {
    print $_[0] if defined $_[0];
    print "Created transaction guid($guid)\n" if $returnGuid && defined $guid;
    print "Success.\n";
    exit(0);
}

__END__
