#!/usr/bin/perl
#
# Create users and extensions BU
#
#  Notes:
#
# 	Creates users and extensions based on the order.
#
#  Options:
#
#	-r	Rollback.
#
# #

use strict;
use Fap::StateMachine::Unit;
use Fap::Order;
use Fap::Bundle;
use Fap::Util;
use Fap::User;
use Fap::Net::RPC;
use Fap::Model::Fcs;

my $client = Fap::StateMachine::Unit->new()->run();

sub execute {
	my ($package, $client, $input) = @_;
	
	my $fcs_schema = Fap::Model::Fcs->new();
	my $legacy_dbh = Fap::Model::Fcs->new();
	my $pbxtra_dbh = $legacy_dbh->dbh('pbxtra');

	if (!Fap::Order::validate_prov_order($fcs_schema, $input->{'order_id'})) {
		$client->displayfailure("ERR: Invalid order: $@");
	}
	
	my $order = Fap::Order->new('order_id' => $input->{'order_id'})->get_details;
	my @created_user_ids;
	
	foreach my $order_group (@{$order->{'order'}->{'order_groups'}}) {
		
		foreach my $order_bundle (@{$order_group->{'order_bundles'}}) {
			my $bundle = Fap::Bundle->new(
				bundle_id => $order_bundle->{'bundle_id'},
				fcs_schema => $fcs_schema,
			);
			if (!defined($bundle)) {
				$client->displayfailure('ERR: bundle id is invalid in order group ' . $order_group->{'order_group_id'} .
				' order bundle ' . $order_bundle->{'order_bundle_id'} . ": $@");
			}
			if (!$bundle->is_user_license_bundle('is_basic')) {
				next;
			}
			
			my $lic = $bundle->get_license_name();
			if (!defined($lic) || $lic eq '') {
				$client->displayfailure('ERR: failed to get bundle license in order group ' . $order_group->{'order_group_id'} .
				' order bundle ' . $order_bundle->{'order_bundle_id'} . ": $@");
			}
			
			my $user_qty = $order_bundle->{'quantity'};
			for(my $i = 0; $i < $user_qty; $i++) {
				my $u_info = Fap::User::create_user($order_group->{'server_id'}, $lic);
				if (!defined($u_info)) {
					$client->displayfailure('ERR: failed to create user in order group ' . $order_group->{'order_group_id'} .
					' order bundle ' . $order_bundle->{'order_bundle_id'} . ": $@");
				} else {
					push @created_user_ids, $u_info;
				}
			}
		}
		
		my $rpc = Fap::Net::RPC::rpc_connect($order_group->{'server_id'}, $pbxtra_dbh);
		if ($rpc)
		{
			Fap::Net::RPC::rsend_request($rpc, 'reload_ast');
		} else {
			$client->displayfailure('ERR: failed to reload asterisk for server ' . $order_group->{'server_id'} . ": $@");
		}
	}
		
	if (@created_user_ids) {
		$input->{'created_user_ids'} = \@created_user_ids;
	}
	
	return $input;
}

sub rollback {
	my ($package, $client, $input) = @_;
	
	my $fcs_schema = Fap::Model::Fcs->new();
	
	if (!Fap::Order::validate_prov_order($fcs_schema, $input->{'order_id'})) {
		$client->displayfailure("ERR: Invalid order: $@");
	}
	
	foreach my $created_user_id (@{$input->{'created_user_ids'}}) {
		my $ret = Fap::User::delete_user($created_user_id->{'user_id'});
		if (!defined($ret)) {
			$client->displayfailure('ERR: failed to delete user ' . $created_user_id->{'user_id'} . ": $@");
		}
	}
	
	return $input;
}

