#!/usr/bin/perl

use strict;
use warnings;

use Test::More qw( no_plan );
use Cwd qw( getcwd abs_path );
use File::Basename;
use SM::Client;
use SM::Test qw(
    spawnUnit
);

my $bu = abs_path('../fcs_create_netsuite_customer.pl');

my $cwd;
BEGIN {
    $cwd = getcwd;
    chdir((fileparse($0))[1]);
}

END {
    chdir($cwd);
}

use_ok('SM::Client');
use_ok('Getopt::Std');
use_ok('Fap::NetSuite::Engine');
use_ok('Fap::Db::Pbxtra');
use_ok('Data::Dumper');

my $client = new SM::Client();

ok((-x $bu),"Does the unit exist and is it executable?");

# CORRECTLY FORMATTED JSON INPUT
my $jsonInput = <<JSON_IN;
       {
         "quote": {
                 "quote_header_id" : "242074"
          },
          "contact_info":{
                 "zip":"44423",
                 "city":"Anywhere",
                 "name":"Jim Bob",
                 "address1":"123 Street Blvd.",
                 "state":"CA",
                 "address2":"Suite 300"
          },
          "server_id":12345,
          "product_id":10,
          "items":[
                 {
                        "id":23,
                        "qty":8
                 }
          ]
       }
JSON_IN

# CORRECT FORMATTED JSON OUTPUT
my $jsonOutput = <<JSON_OUT;
       {
          "lead_id" : "1234"
       }
JSON_OUT

my $inputStruct = $client->json->decode($jsonInput);
$jsonInput = $client->json->encode($inputStruct);
my $outputStruct = $client->json->decode($jsonOutput);
$jsonOutput = $client->json->encode($outputStruct);

###########################
# PUT TESTS BENEATH HERE. #
###########################
my ($out, $err, $retval);

# Failure test... fails if no input is submitted?
($out, $err, $retval) = spawnUnit($bu,{});
ok(!$out,"Empty output for empty json.");
like($err,qr/Invalid or empty JSON input./,"Error returned for empty json input?");
is($retval,-1,"Returned -1 for for empty input?");

# Takes input and supplies output?
#($out, $err, $retval) = spawnUnit($bu,$jsonInput);
#print "out:$out,$err,$retval\n";

__END__
