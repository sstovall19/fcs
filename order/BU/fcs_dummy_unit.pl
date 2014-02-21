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
use SM::Client;
use Getopt::Std;
use SM::DB;

my $client = SM::Client->new();
my %options=();
getopts('red', \%options);

rollback($client, \%options) if (defined($options{'r'}));

my ($input)  = $client->initialize();
my ($output, $error, $status) = execute($client, $input, \%options);

(($status == 1) ? $client->displaysuccess($output) : $client->displayfailure($error));
$client->displaysuccess($output) ;

sub execute {
    my ($client) = shift;
    my ($input) = shift;
    my ($options) = shift;
    return(undef,undef, 1);
}

sub rollback {
    my ($client) = shift;
    my ($input) = shift;
    my ($options) = shift;
    $client->displaysuccess({status=>"rollback"});
}

__END__
