#!/usr/bin/perl
#
# Business Unit example
#
#  Notes:
#
# 	A sample Business Unit using SM::Client.
#
#  Options:
#
#	-r	Rollback.
#
#  Testing:
#
#	Make sure the SM can handle the following
#
#	- Success 					(no options)
#	- Success with debug message			-d
#	- Rollback Success				-r
#
# #

use strict;
use warnings;
use Fap::StateMachine::Unit;

my $client = new Fap::StateMachine::Unit;
$client->run();

# Execute:  This is where we actually do something.   This is a demo, so we'll
# just reverse the values we were given... or fail with a meaningful message.
sub execute {
	my $input   = $client->input;
	my $options = $client->options;
	my $output  = $input;
	my $error;
        $client->displaysuccess($output); 
}

sub rollback {
	my $options = $client->options;
        $client->displaysuccess();
}
