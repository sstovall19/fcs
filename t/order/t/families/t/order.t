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
use Fap::StateMachine::Client;
use Fap;
use Try::Tiny;
use File::Slurp;
use JSON::XS;

my $cwd;
BEGIN {
    $cwd = getcwd;
    chdir((fileparse($0))[1]);
}

my $client = Fap::StateMachine::Client->new();
system(Fap->path_to("bin/statemachinectl restart"));
if (!$client->ping->{status}) {
}
my $testInput = abs_path('test.input');
my $input;
my $trans;
try {
	my $txt = File::Slurp::read_file($testInput);
	$input = JSON::XS->new->decode($txt);
} catch {
	fail("Unable to read JSON: $_");
};
my $res = $client->submit_transaction("ORDER",JSON::XS->new->utf8->encode($input));
if (!$res->{status}) {
	fail("submit to state machine FAILED");
} else {
	ok("submitted to state machine");
	$trans = $client->run_transaction_monitored($res->{guid});
}
my $trans_status = $client->get_transaction_status($res->{guid});
if ($trans_status->{status} ne "SUCCESS") {
        fail(sprintf("QUOTE FAILED AT '%s' %d of %d:\n\n%s\n\n",$trans_status->{description},$trans_status->{steps_passed}+1,$trans_status->{steps},$trans_status->{error}));
} else {
	ok("transaction run!");
}
__END__




END {
    chdir($cwd);
}

my $testInput = (-f "$user.input") ? abs_path("$user.input") : abs_path('test.input');

__END__
