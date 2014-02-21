#!/usr/bin/perl

use strict;
use warnings;

use Test::More qw( no_plan );
use File::Basename;
use Cwd qw( getcwd abs_path );

my $cwd;
BEGIN {
    $cwd = getcwd;
    chdir((fileparse($0))[1]);
}

END {
    chdir($cwd);
}

my $exe = '../run_sm_test.pl';
my $regex;
my $cmd;

$exe = abs_path($exe);

use_ok('SM::Config');
use_ok('SM::DB');
use_ok('JSON::XS');
use_ok('Data::Dumper');
use_ok('Data::UUID');
use_ok('SM::Model::Transaction');
use_ok('Getopt::Std');

ok((-x $exe),'Is it executable?');

# Does it run?
$regex = qr/^\s+Usage/;
like(`$exe`,$regex,'Testing runnability.');

# Can the test read input and step files and create entries into the db?
my $input = abs_path('test.input');
my $steps = abs_path('test.steps');
$cmd = "$exe -i $input -s $steps -w -cg";
my $out = `$cmd`;
ok(($out =~ m/Success/),'Reading input and steps file, then inserting records into the db.');

# Was a guid returned?
$out =~ m/transaction guid\((.*)\)/;
my $guid = $1;
ok(($guid =~ /\d+-\d+-\d+-\d+-\d+/),'Returning guid created for this transaction.');

__END__
