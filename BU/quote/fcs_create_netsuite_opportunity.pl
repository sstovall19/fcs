#!/usr/bin/perl
use strict;
use Fap::StateMachine::Unit;
use Fap::External::NetSuite();
use Fap::Model::Fcs();
use Data::Dumper qw/Dumper/;

my $client = Fap::StateMachine::Unit->new();
$client->run();
sub execute {
	my ($class,$client,$input) = @_;

	my $db = Fap::Model::Fcs->new();
	my $order_id = $input->{order_id};
	if (!$input->{order_id}) {
                $client->displayfailure("Missing Order ID");
        }

        my $order = $db->table("Order")->search({"me.order_id"=>$order_id},{prefetch=>{"order_groups"=>{"order_bundles"=>{"bundle"=>"category"}}}})->first;
	if (!$order) {
                $client->displayfailure("Invalid Order Id");
        }

	my $ns = Fap::External::NetSuite->new(mode=>"sandbox");

	
	if ($ns->hasError()) {
		$client->displayfailure("NetSuite Login failed: ".$ns->errorMsg());
	}

	my $item_rec=[];
	foreach my $group ($order->order_groups) {
		my $op = {
               		customer=>$order->netsuite_lead_id,
               		items=>[],
               		class=>25,
			#customFields=>[
                                        #$ns->customSelect("custcol_terminmonths",$order->term_in_months),
                                        #$ns->customSelect("custentity_custprod",13),
                                #],

        	};
		foreach my $item ($group->order_bundles) {
			my $trans = $item->bundle;
			next if (!$trans->netsuite_order_id && !$trans->netsuite_mrc_id);
			my ($amount,$nsid);
			if ($item->is_rented &&  $trans->netsuite_mrc_id) {
				$nsid = $trans->netsuite_order_id;
				$amount = $item->list_price;
			} else {
				$nsid = $trans->netsuite_order_id;
				$amount = $item->list_price;
			}
			my $fields;
               		my $item_rec = {
                        	item=>$nsid,
                               	quantity=>$item->quantity,
                               	amount=>$amount*$item->quantity,
                               	description=>$trans->name||$trans->description,
				#customFieldList=>[
					#$ns->customFloat("custcol_terminmonths",$order->term_in_months)
				#],
                       	};
                       	push(@{$op->{items}},$item_rec);
		}
		#if ($group->{shipping}->{rates}) {
			#push(@{$op->{items}},{
				#item=>3553,
				#quantity=>1,
				#amount=>$group->{shipping}->{rates}->[0]->{rate},
				#description=>"UPS Ground Shipping"
			#});
		#}

		my $nsid = $ns->opportunity->create(%$op);
		if ($ns->hasError()) {
                	$client->displayfailure($ns->errorCode()." : ".$ns->errorMsg());
        	}
	}
	return $input;
}

sub rollback {
	my ($class,$client,$input) = @_;

        return {status=>"rollback"};
}
__DATA__
