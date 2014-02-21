#!/usr/bin/perl
# collector_quote.t
#  Sends json to the collector to create a "QUOTE"(Test QUOTE) transaction for the SM to pick up.
# 
##

use strict;
use warnings;

use Test::More qw( no_plan );
use Cwd qw( getcwd abs_path );
use File::Basename;
use Try::Tiny;
use Data::Dumper;
use JSON::XS;
use Sys::Hostname;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Request::Common qw( POST );
use Fap::StateMachine::Client;

my $cwd;
BEGIN {
    $cwd = getcwd;
    chdir((fileparse($0))[1]);
}

END {
    chdir($cwd);
}
my $conf = Fap::StateMachine->load_conf();
if ($ENV{FCS_TEST}) {
	system(Fap->path_to("bin/statemachinectl stop"));
	if (-f $conf->{pidfile}) {
		fail("Test State Machine Failed to shut down");
	} else {
		ok("STATE MACHINE SHUT DOWN");
	}
	unlink($conf->{logfile});
} else {
	ok("Not running in test mode. The State Machine can live for now.");
}
__END__
