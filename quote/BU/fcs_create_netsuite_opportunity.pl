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
use Fap::Db::Pbxtra;
use Fap::Db::Fcs;
use Data::Dumper;

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
	
	my $ns = Fap::NetSuite::Engine->new(mode=>"sandbox");
	if ($ns->hasError()) {
		$client->displayfailure("NetSuite Login failed: ".$ns->errorMsg());
	}
	if (!$input->{quote}->{quote_header_id}) {
		$client->displayfailure("Missing Quote ID");
	}
	$input->{INFO}->{JUST_RAN} = $0;
	$input->{INFO}->{PID} = $$;

	my $db = Fap::Db::Fcs->new();
	my $quote = $db->table("Order")->search({"me.order_id"=>$input->{quote}->{quote_header_id}})->first;

	if (!$quote) {
		$client->displayfailure("Invalid Quote Id");
	}
	if ($input->{quote}->{previous_opportunity_id}) {
		$ns->delete_opportunity($input->{quote}->{previous_opportunity_id});
		if ($ns->hasError) {
			if ($ns->errorCode() ne "RCRD_DSNT_EXIST") {
				$client->displayfailure($ns->errorMsg());
			}
		}
	}
	my $op = {
	
        	customer=>$input->{netsuite}->{netsuite_id},
        	items=>[],
		class=>25,
	};

	my $quote_items = [];
	$input->{quote}->{shipping} = 0;
	$input->{quote}->{subtotal} = 0;
	if (0) {
		foreach my $trans ($quote->trans) {
        		if ($trans->item) {
				push(@$quote_items,{price=>$trans->item_price,quantity=>$trans->quantity,base_price=>$trans->item_price,description=>$trans->item->name});
				$input->{quote}->{subtotal}+=$trans->item_price;
				my $item_rec = {
					item=>$trans->item->netsuite_id,
					quantity=>$trans->quantity,
					amount=>$trans->item_price,
					description=>$trans->item->name,
				};
                		push(@{$op->{items}},$item_rec);
        		}
		}
	} else {
		foreach my $server (@{$input->{servers}}) {
			foreach my $item (@{$server->{Items}}) {
				my $trans = $db->table("Bundle")->single({bundle_id=>$item->{id}});
				push(@$quote_items,{price=>$trans->price*$item->{value},quantity=>$item->{value},base_price=>$trans->price,description=>$trans->name||$trans->description});
                        	my $item_rec = {
                                	item=>$trans->netsuite_id,
                                	quantity=>$item->{value},
                                	amount=>$trans->price,
                                	description=>$trans->name||$trans->description,
                        	};
                        	push(@{$op->{items}},$item_rec);
			}
		}
	}
	#push(@{$op->{items}},{item=>596,quantity=>1,amount=>22.45});
	foreach my $ad (values %{$input->{Shipping}->{Info}}) {
		push(@{$op->{items}},{
			item=>3553,
			quantity=>1,
			amount=>$ad->{Rates}->[0]->{rate},
			#rate=>$ad->{Rates}->[0]->{rate},
			description=>"UPS Ground Shipping"
		});
		$input->{quote}->{shipping}+=$ad->{Rates}->[0]->{rate};
	}
	$input->{quote}->{items} = $quote_items;
	my $id = $ns->opportunity->create(%$op);
	if ($ns->hasError()) {
		$client->displayfailure($ns->errorCode()." : ".$ns->errorMsg());
	}
	$input->{netsuite}->{opportunity_id} = $id;
	
	$client->displaysuccess($input);
	
}

sub rollback {
	my ($client) = shift;
	my ($input) = shift;
	my ($options) = shift;

        $client->displaysuccess({status=>"rollback"});

	
}
__DATA__
