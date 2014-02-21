#!/usr/bin/perl
#
# Add devices BU
#
#  Notes:
#
# 	Adds phones to a server based on the order
#
#  Options:
#
#	-r	Rollback.
#
#  Input:
#
#	See Requirements Document
#
#  Output:
#
#	See Requirements Document
#
# #

use strict;
use Fap::StateMachine::Unit;
use Fap::Order;
use Fap::Util;
use Fap::Bundle;
use Fap::Model::Fcs;
use Fap::Devices;

my $client = Fap::StateMachine::Unit->new()->run();

sub execute {
	my ($package, $client, $input) = @_;
	
	my $fcs_schema = Fap::Model::Fcs->new();

	if (!Fap::Order::validate_prov_order($fcs_schema, $input->{'order_id'})) {
		$client->displayfailure("ERR: Invalid order: $@");
	}
	
    my $order = Fap::Order->new('order_id' => $input->{'order_id'})->get_details;
	
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
			if (!$bundle->is_phone_bundle()) {
				next;
			}
			
			my $phone_info = $bundle->get_phone_info();
			
			foreach my $order_bundle_detail (@{$order_bundle->{'order_bundle_details'}}) {
				if (!defined($order_bundle_detail->{'mac_address'}) || $order_bundle_detail->{'mac_address'} eq '') {
					$client->displayfailure('ERR: Incomplete phone information in order group ' . $order_group->{'order_group_id'} .
					' order bundle ' . $order_bundle->{'order_bundle_id'} .
					' order bundle detail ' . $order_bundle_detail->{'order_bundle_detail_id'} . ": $@");
				}

				my $info = {
					name => 'SIP/' . $order_bundle_detail->{'mac_address'},
					description => $phone_info->{'description'},
					type => $phone_info->{'type'}
				};
				my $device_id = Fap::Devices::add_device($order_group->{'server_id'}, $info);
				if (!defined($device_id)) {
					$client->displayfailure("ERR: Cannot add new device in order group " . $order_group->{'order_group_id'} .
					' order bundle ' . $order_bundle->{'order_bundle_id'} .
					' order bundle detail ' . $order_bundle_detail->{'order_bundle_detail_id'} . ": $@");
				} else {
					if (defined($input->{'added_device_ids'})) {
						push @{$input->{'added_device_ids'}}, $device_id;
					} else {
						$input->{'added_device_ids'} = [ $device_id ];
					}
				}
			}
		}
	}
	
	return $input;
}

sub rollback {
	my ($package, $client, $input) = @_;
	
	my $fcs_schema = Fap::Model::Fcs->new();

	if (!Fap::Order::validate_prov_order($fcs_schema, $input->{'order_id'})) {
		$client->displayfailure("ERR: Invalid order: $@");
	}
	
	foreach my $added_device_id (@{$input->{'added_device_ids'}}) {
		# Check that we have a device to remove
		if (!Fap::Util::is_valid_device_id($added_device_id)) {
			$client->displayfailure("ERR: Invalid device id ($added_device_id): $@");
		}
	
		# Remove the device
		my $ret = Fap::Devices::remove_device($added_device_id);
		if (!defined($ret)) {
			$client->displayfailure("ERR: Cannot remove device with device id $added_device_id: $@");
		}
	}
	
	return $input;
}

