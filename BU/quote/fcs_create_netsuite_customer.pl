#!/usr/bin/perl
use strict;

use Fap::StateMachine::Unit();
use Fap::External::NetSuite();
use Fap::External::NetSuite::Config();
use Fap::Model::Fcs();
use Fap::Order();
use Fap::Data::Countries;
use Data::Dumper();
use DateTime();
use Try::Tiny();

my $client = Fap::StateMachine::Unit->new();
$client->run();

sub execute {
	my ($class,$client,$input) = @_;

	my $order_id = $input->{order_id};
	if (!$order_id) {
                $client->displayfailure("Missing Quote ID");
        }
	my $db = Fap::Model::Fcs->new();
	my $order = Fap::Order->get(id=>$order_id,db=>$db);
	if (!$order) {
		$client->displayfailure("Invalid Quote Id");
	}

	if (!$order) {
		$client->displayfailure("Invalid Quote Id");
	}


	my $netsuite_id;
	my $ns;
	if ($order->netsuite_lead_id) {
		$netsuite_id=$order->netsuite_lead_id;
	} else {
		$ns = Fap::External::NetSuite->new(mode=>"sandbox");
		  if ($ns->hasError()) {
                $client->displayfailure("NetSuite Login failed: ".$ns->errorMsg());
        }

		#Duplicate check temporarily bypassed
		#my $res = $ns->customer->search(email=>$input->{contact}->{company_info_email});
		my $res = {meta=>{records=>0}};
        	if ($ns->hasError()) {
                	$client->displayfailure($ns->errorMsg());
        	}
        	if ($res->{meta}->{records}>0) {
                	$netsuite_id = $res->{records}->[0]->{recordInternalId};
			$input->{netsuite}->{netsuite_id} = $res->{records}->[0]->{recordInternalId};
			$input->{netsuite}->{netsuite_salesrep_id} = $res->{records}->[0]->{salesRepInternalId};
		} else {
			my $book  = [];
			
			foreach my $gadd ($order->order_groups) {
				my $addr = $gadd->shipping_address;
				my $country = $addr->country;
				push(@$book,{
					addr1=>$addr->addr1,
					addr2=>$addr->addr2,
					country=>Fap::Data::Countries->get_netsuite_name($addr->country),
					state=>$addr->state_prov,
					city=>$addr->city,
					zip=>$addr->postal
				});
			}
			my $contact = $order->contact;

			$netsuite_id = $ns->customer->create(
                		reseller_id=>$order->reseller_id,
                		entityId=>sprintf("%s (%d)",$order->company_name,$input->{order_id}),
                		companyName=>$order->company_name,
                		email=>$contact->email,
                		phone=>$contact->phone,
                		addressbook=>$book,
                		url=>$order->website,
				customFields=>[
					$ns->customSelect("custentity1",1),
					$ns->customSelect("custentity_custprod",13),
				],
				shipping=>4033,
        		);
			if ($ns->hasError()) {
				if ($ns->errorCode() eq "UNIQUE_CUST_ID_REQD") {
					my $res = $ns->customer->search(entityId=>sprintf("%s (%d)",$order->company_name,$input->{order_id}));
					if ($res->{meta}->{records}>0) {
						$netsuite_id = $res->{records}->[0]->{recordInternalId};
					}
				}
			}
			$order->netsuite_lead_id($netsuite_id);
		}
	}


	if( $ns && $ns->hasError()) {
		$client->displayfailure($ns->errorCode()." ".$ns->errorMsg());
	} elsif (!$netsuite_id) {
		$client->displayfailure("Unable to create netsuite id: unknown");
	}
	if (!$order->netsuite_salesperson_id) {
		my $nscust = $ns->customer->get($netsuite_id);
		if ($ns->hasError()) {
			$client->displayfailure($ns->errorMsg());
		}
		$order->netsuite_salesperson_id($nscust->{salesRepInternalId});
	}

	my $salesperson = $db->table("NetsuiteSalesperson")->single({netsuite_id=>$order->netsuite_salesperson_id});
	if (!$salesperson) {
		$salesperson = $db->table("NetsuiteSalesperson")->single({netsuite_id=>38});
	}

	$order->updated(DateTime->now(time_zone=>"America/Los_Angeles")->strftime("%F %H:%M:%S"));
        $order->update();

	return $input;
}

sub rollback {
	my ($class,$client,$input) = @_;

	return $input;
}
__DATA__
