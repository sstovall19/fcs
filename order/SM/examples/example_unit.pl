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
#	-e	Return error.
#	-d	Add debug messages.
#
#  Testing:
#
#	Make sure the SM can handle the following
#
#	- Success 					(no options)
#	- Success with debug message			-d
#	- Failure					-e
#	- Failure eith error				-e -d
#	- Rollback Success				-r
#	- Rollback Success, with Debug			-r -d
#	- Rollback Failure				-r -e
#	- Rollback with Debug, Failure			-r -e -d
#
# #

use strict;
use warnings;
use lib '/home/smisel';
use SM::Client;
use Getopt::Std;

use SM::DB;
my $db = SM::DB->new(dsn => 'dbi:mysql:pbxtra', user => 'fonality', pass =>'iNOcallU');


my $client = SM::Client->new();
my %options=();
getopts('red', \%options);

rollback($client, \%options) if (defined($options{'r'}));

my ($input)  = $client->initialize();
my ($output, $error, $status) = execute($client, $input, \%options);

(($status == 1) ? $client->displaysuccess($output) : $client->displayfailure($error));
$client->displaysuccess($output) ;


# Execute:  This is where we actually do something.   This is a demo, so we'll
# just reverse the values we were given... or fail with a meaningful message.
sub execute {
	my ($client) = shift;
	my ($input) = shift;
	my ($options) = shift;
	my ($output);
	my ($error);
	#$db->table('TransactionJob')->find(3233)->update({ familyname => 'RICK' });


	$client->display(*STDERR, "A meaningless debug message on STDERR which should be logged and traceable to this instance.") if ($options->{'d'});
	return(undef, "A meaningful failure message that should be logged.", -1) if ($options->{'e'});

	$output=$input;

	$output->{'INFO'}->{'JUST_RAN'} = $0;
	$output->{'INFO'}->{'PID'} = $$;
	return($output, $error, 1);
}

sub rollback {
	my ($client) = shift;
	my ($options) = shift;
	# Example has nothing to rollback... but if it did, it would be here.

	$client->display(*STDERR, "Asked to Roll Back") if ($options->{'d'});
	$client->display(*STDERR, "Roll Back Failure!") if ($options->{'e'});
	(($options->{'e'}) ? $client->failure() : $client->success());
}
