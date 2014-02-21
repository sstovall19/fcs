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

# Hard-coding these for now. ugggh.
my %collectorMap = (
    'web-dev2' => 'http://localhost:5000/order/quote',
    'ec2-dev'  => 'http://localhost/collector/order/quote',
);

my $hostname = hostname();
my $collectorUrl;
if ( !defined $hostname || $hostname ne 'ec2-dev' )
{
    $hostname = 'web-dev2';
}

$collectorUrl = $collectorMap{$hostname};

diag("Running the collector found at: '$collectorUrl'.\n");

my $json=<<__JSON__;
{
    "discount_percent" : 0,
    "order_id" : "",
    "order_group" : [
      {
        "bundle" : [
          {
            "value" : "10",
            "id" : "42"
          },
          {
            "value" : "10",
            "id" : "81"
          },
          {
            "value" : 1,
            "id" : "63"
          },
          {
            "value" : "4",
            "id" : "43"
          },
          {
            "value" : "65",
            "id" : "55"
          },
	 { 
            "value" : "4",
            "id" : "54"
          }

        ],
        "product_id" : "8",
        "shipping" : {
           "country" : "US",
           "addr2" : "Suite 300",
           "city" : "Culver City",
           "postal" : "90230",
           "addr1" : "200 Corporate Pointe",
           "state_prov" : "CA"
        }
      }
    ],
    "contact" : {
      "website" : "http://fonality.com",
      "company_name" : "Fonality",
      "industry" : "Aerospace & Defense",
      "phone" : "3102223433",
      "last_name" : "User",
      "email" : "dev-email\@fonality.com",
      "email_confirm" : "dev-email\@fonality.com",
      "first_name" : "FCS"
    },
    "max_discount_percent" : 20,
    "term_in_months" : 24,
    "prepay_amount" : 0
}
__JSON__

my $user = 'dev',
my $apiKey = '0bce4abc80a807e1ef63ac2c05b04af1';

if ($ENV{FCS_TEST}) {
	system(Fap->path_to("bin/statemachinectl restart"));
	sleep(2);
}

my $client = Fap::StateMachine::Client->new();
my $res = $client->submit_transaction("QUOTE",$json,Fap->path_to(""));
print STDERR Dumper($res);
my $gotGuid = ok((defined $res && defined $res->{guid}),'Collector returned a guid for the created quote?');
if ( !$gotGuid || (defined $res && $res->{status}!=1) )
{
    fail("\@RESPONSE FROM COLLECTOR\@\n".Dumper($res)."\n\n");
}
my $trueStatus = ok((defined $res && defined $res->{status} && $res->{status} == 1),'Collector returned a true status for the created quote?');
if( !$trueStatus )
{
    fail("\@RESPONSE FROM COLLECTOR\@\n".Dumper($res)."\n\n");
}

unlink("quote_guid");

# Write the guid to file for later tests.
if ( defined $res && defined $res->{guid} )
{
    open GUID,">/dev/shm/quote_guid" or die "Can't write the guid to file: $!\n";
    print GUID $res->{guid};
    close GUID;
    chmod(0666,"/dev/shm/quote_guid");
}

__END__
