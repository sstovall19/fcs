#!/usr/bin/perl
#
# Create NetSuite lead Business Unit
#
#  Notes:
#
# 	Creates a lead in NetSuite.
#
#  Options:
#
#	-r	Rollback.
#	-e	Return error.
#	-d	Add debug messages.
#
#  Input:
#
#	{
#	   "contact_info":{
#		  "zip":"44423",
#		  "city":"Anywhere",
#		  "name":"Jim Bob",
#		  "address1":"123 Street Blvd.",
#		  "state":"CA",
#		  "address2":"Suite 300"
#	   },
#	   "server_id":12345,
#	   "product_id":10,
#	   "items":[
#		  {
#			 "id":23,
#			 "qty":8
#		  },
#		  ...
#	}
#
#  Output:
#
#	{
#	   "lead_id" : "1234"
#	}
#
# #

use strict;

use SM::Client;
use Getopt::Std;
use Fap::NetSuite::Engine;
use Fap::Db::Fcs;
use Data::Dumper;
use DateTime;

my $client = SM::Client->new();
my %options = ();
getopts('red', \%options);
my ($input) = $client->initialize();
if (defined($options{'r'})) {
	rollback($client, $input, \%options);
}
execute($client, $input, \%options);
sub execute {
	my ($client) = shift;
	my ($input) = shift;
	my ($options) = shift;
	
	# this should already be done by the collector
	$input->{servers} = [map {defined $_->{Shipping}->{shipping_country} ? $_ : ()} @{$input->{servers}}];
	foreach my $server (@{$input->{servers}}) { $server->{Items} = [map {defined $_->{value} && $_->{id} ne '' ? $_ : () } @{$server->{Items}}]; }
	my $address_list=[];
	foreach my $add (values %{$input->{Shipping}->{Info}}) {
		push(@$address_list,$add->{Address});
	}
	$input->{INFO}->{JUST_RAN} = $0;
        $input->{INFO}->{PID} = $$;

	my $ns = Fap::NetSuite::Engine->new(mode=>"sandbox");
	if ($ns->hasError()) {
		$client->displayfailure("NetSuite Login failed: ".$ns->errorMsg());
	}
	
	if (!$input->{quote}->{quote_header_id}) {
		$client->displayfailure("Missing Quote ID");
	}

	my $db = Fap::Db::Fcs->new();
	my $quote = $db->table("Order")->single({order_id=>$input->{quote}->{quote_header_id}});
	if (!$quote) {
		$client->displayfailure("Invalid Quote Id");
	}

	my $netsuite_id;
	$input->{netsuite} = {};

	if ($input->{netsuite_id}) {
		$netsuite_id=$input->{quote}->{netsuite}->{netsuite_id}=$input->{quote}->{netsuite_id};
	} else {
		#my $res = $ns->customer->search(email=>$input->{contact}->{company_info_email});
		my $res = {meta=>{records=>0}};
        	if ($ns->hasError()) {
                	$client->displayfailure($ns->errorMsg());
        	}
        	if ($res->{meta}->{records}>0) {
                	$netsuite_id = $input->{netsuite}->{netsuite_id} = $res->{records}->[0]->{recordInternalId};
			$input->{netsuite}->{netsuite_id} = $res->{records}->[0]->{recordInternalId};
			$input->{netsuite}->{netsuite_salesrep_id} = $res->{records}->[0]->{salesRepInternalId};
		} else {
			my $book  = [];
			foreach my $addr (@$address_list) {
				push(@$book,{addr1=>$addr->{shipping_street},country=>Fap::NetSuite::Config->map_country($addr->{shipping_country}),state=>$addr->{shipping_state},city=>$addr->{shipping_city},zip=>$addr->{shipping_zip}});
			}
			$netsuite_id = $input->{netsuite}->{netsuite_id} = $ns->customer->create(
                		reseller_id=>$quote->reseller_id,
                		entityId=>sprintf("%s (%d)",$input->{contact}->{company_info_name},$input->{quote}->{quote_header_id}),
                		companyName=>$input->{contact}->{company_info_name},
                		email=>$input->{contact}->{company_info_email},
                		phone=>$input->{contact}->{company_info_cust_phone},
                		addressbook=>$book,
                		url=>$input->{contact}->{company_info_website},
                		salesRep=>$ns->employeeRef(18),
				customFields=>[
					$ns->customSelect("custentity1",1),
					$ns->customSelect("custentity_custprod",13),
				],
				shipping=>4033,
        		);
			if ($ns->hasError()) {
				if ($ns->errorCode() eq "UNIQUE_CUST_ID_REQD") {
					my $res = $ns->customer->search(entityId=>sprintf("%s (%d)",$input->{contact}->{company_info_name},$input->{quote}->{quote_header_id}));
					if ($res->{meta}->{records}>0) {
						 $netsuite_id = $input->{netsuite}->{netsuite_id} = $res->{records}->[0]->{recordInternalId};
                        			$input->{netsuite}->{netsuite_salesrep_id} = $res->{records}->[0]->{salesRepInternalId};
					}
				}
			}
		}
	}

	if($ns->hasError()) {
		$client->displayfailure($ns->errorCode()." ".$ns->errorMsg());
	} elsif (!$netsuite_id) {
		$client->displayfailure("Unable to create netsuite id: unknown");
	}

	if (!defined $input->{netsuite}->{netsuite_salesrep_id}) {
		my $nscust = $ns->customer->get($netsuite_id);
		if ($ns->hasError()) {
			$client->displayfailure($ns->errorMsg());
		}
		$input->{netsuite}->{netsuite_salesrep_id} = $nscust->{salesRepInternalId};
	}

	my $salesperson = $db->table("NetsuiteSalesperson")->search({netsuite_id=>$input->{netsuite}->{netsuite_salesrep_id}})->first;
	if (!$salesperson) {
		$salesperson = $db->table("NetsuiteSalesperson")->single({netsuite_id=>38});
		#$client->displayfailure("Unable to assign salesperson");
	}

	#$quote->netsuite_lead_id($netsuite_id);
	$quote->netsuite_lead_id($netsuite_id);
        $quote->netsuite_salesperson_id($salesperson->netsuite_id);
	$quote->updated(DateTime->now(time_zone=>"America/Los_Angeles")->strftime("%F %H:%M:%S"));
        $quote->update();

	$input->{netsuite}->{netsuite_salesrep_name} = $salesperson->name;
	$input->{netsuite}->{netsuite_salesrep_phone} = $salesperson->phone;
	$input->{netsuite}->{netsuite_salesrep_email} = $salesperson->email;

	$client->displaysuccess($input);
	
}

sub rollback {
	my ($client) = shift;
	my ($input) = shift;
	my ($options) = shift;

	$client->displaysuccess({status=>"rollback"});
}
__DATA__
