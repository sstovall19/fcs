#!/usr/bin/perl
#
# Assign DIDs to users BU
#
#  Notes:
#
# 	Assigns DIDs to users based on the order.
#
#  Options:
#
#	-r	Rollback.
#
# #

use strict;
use Fap::Model::Fcs;
use Fap::StateMachine::Unit;
use Fap::Order;
use Fap::Bundle;
use Fap::PhoneNumbers;
use Fap::CallerID;
use Fap::Devices;
use JSON;
use F::Conference;
# for optmal search of phone_numbers
use List::Util qw(first);

my $client = Fap::StateMachine::Unit->new()->run();

sub execute {
	my ($package, $client, $input) = @_;
	
	my $fcs_schema = Fap::Model::Fcs->new();

    my $order_id = $input->{'order_id'};
    my $order = Fap::Order->new('order_id'=>$order_id)->get_details();
    if (!Fap::Order::validate_prov_order($fcs_schema, $order_id)) {
        $client->displayfailure($@);
    }

    foreach my $order_group ( @{ $order->{'order'}->{'order_groups'} } ) {
		my $server_id = $order_group->{'server_id'};
		my @phone_numbers = F::PhoneNumbers::get_phone_numbers($F::Globals::dbh, $server_id);	
		foreach my $order_bundle (@{$order_group->{'order_bundles'}}) {
			my $bundle = Fap::Bundle->new(
				bundle_id => $order_bundle->{'bundle_id'},
				fcs_schema => $fcs_schema,
			);
			if (!defined($bundle)) {
				$client->displayfailure('ERR: bundle id is invalid in order group ' . $order_group->{'order_group_id'} .
				' order bundle ' . $order_bundle->{'order_bundle_id'});
			}
			next if $order_bundle->{'bundle'}->{'category'}->{'name'} ne 'phone_number';
			
			foreach my $order_bundle_detail (@{$order_bundle->{'order_bundle_details'}}) {
				my $did = $order_bundle_detail->{'did_number'};
				my $exten = $order_bundle_detail->{'extension'};
				# optimal search for the first undefined extension
				my $numbers = first { $_->{number} eq $did } @phone_numbers;
				unless ($numbers)
				{
					$client->displayfailure("ERR: $did: DIDs do not match in phone_numbers table");
				}	
				# validate the DID	
				unless ($did =~ m/^(?:9?1)?(\d{10})/)
				{
					$client->displayfailure("ERR: DIDs not purchased yet");
				}
				my $ret = set_caller_id($server_id, $exten, $did, $input);
				if (!defined($ret)) {
					$client->displayfailure("ERR: failed to set caller id for server $server_id extension $exten DID $did");
				}
				
				$ret = F::PhoneNumbers::update_phone_number($server_id, $did, $exten);
				if (!defined($ret)) {
					$client->displayfailure("ERR: failed to update phone number for server $server_id extension $exten DID $did");
				}
				my $user_id = get_user_id_by_ext_and_server($server_id, $exten);
				push (@{$input->{'did_assigned_users'}}, $user_id);
			}
		}
	}
	return $input;
}

sub rollback {
	my ($package, $client, $input) = @_;
	
	my $fcs_schema = Fap::Model::Fcs->new();

    my $order_id = $input->{'order_id'};
    my $order = Fap::Order->new('order_id'=>$order_id)->get_details();

    if (!Fap::Order::validate_prov_order($fcs_schema, $order_id)) {
        $client->displayfailure($@);
    }
	foreach my $order_group (@{$order->{'order'}->{'order_groups'}}) {
		foreach my $order_bundle (@{$order_group->{'order_bundles'}}) {
			my $bundle = Fap::Bundle->new(
				bundle_id => $order_bundle->{'bundle_id'},
				fcs_schema => $fcs_schema,
			);
			if (!defined($bundle)) {
				$client->displayfailure('ERR: bundle id is invalid in order group ' . $order_group->{'order_group_id'} .
				' order bundle ' . $order_bundle->{'order_bundle_id'});
			}
			
			foreach my $order_bundle_detail (@{$order_bundle->{'order_bundle_details'}}) {
				if (!defined($order_bundle_detail->{'did_number'})) {
					next;
				}
				my $ret = Fap::CallerID::remove_caller_id($order_group->{'server_id'}, $order_bundle_detail->{'extension_number'});
				if (!defined($ret)) {
					$client->displayfailure('ERR: failed to remove caller id for server ' . $order_group->{'server_id'} .
						' extension ' . $order_bundle_detail->{'extension_number'});
				}
				
				$ret = F::PhoneNumbers::remove_phone_number($order_group->{'server_id'}, $order_bundle_detail->{'did_number'});
				if (!defined($ret)) {
					$client->displayfailure('ERR: failed to remove phone number for server ' . $order_group->{'server_id'} .
						' DID ' . $order_bundle_detail->{'did_number'});
				}
			}
		}
	}
	if (defined($input->{'did_assigned_users'})) {	
		delete $input->{'did_assigned_users'};			
	}
	return $input;
}

sub set_caller_id {
	my $server_id = shift;
	my $exten = shift;
	my $did = shift;
	my $input =shift;
	
	my ($cid, $name) = Fap::CallerID::get_caller_id($server_id, $exten);
	return if !defined($cid) || !defined($name);
	# append $cid to output
	push (@{$input->{'did_assigned_users'}}, $cid);
	return Fap::CallerID::set_caller_id($server_id, $did, $name, $exten);
}
