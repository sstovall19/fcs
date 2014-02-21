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

my $exe = '../sm';
my $regex;
my $cmd;
my ($out,$pid);

$exe = abs_path($exe);

use_ok('SM::Config');
use_ok('SM::Client::Registry');
use_ok('SM::Config');
use_ok('SM::Model::Registry::Register');
use_ok('SM::SMClient');
use_ok('SM::DB');
use_ok('Data::Dumper');
use_ok('JSON::XS');

ok((-x $exe),'Is it executable?');

$cmd = "$exe refresh";
$regex = qr/State machine list refreshed/i;
like(`$cmd`,$regex,'Can refresh the SM list?');

$cmd = "$exe list all";
$regex = qr/Listing all running state machines/i;
like(`$cmd`,$regex,'Can list all running SMs?');

__END__
