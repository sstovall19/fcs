#!/usr/bin/perl
#
# Add user licenses BU
#
#  Notes:
#
# 	Adds user licenses to a server based on the order
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
use Fap::ServerLicense;
use Fap::Order;

my $client = Fap::StateMachine::Unit->new()->run();

sub execute {
	my ($package, $client, $input) = @_;
	
	my $fcs_schema = Fap::Model::Fcs->new();

	if (!Fap::Order::validate_prov_order($fcs_schema, $input->{'order_id'})) {
		$client->displayfailure("ERR: Invalid order: $@");
	}

    my $order = Fap::Order->new('order_id' => $input->{'order_id'})->get_details;
	my @lic_ids = ();
	
	# Find and add user licenses
	foreach my $order_group (@{$order->{'order'}->{'order_groups'}}) {
		my $obj = Fap::ServerLicense->new($order_group->{'server_id'});
		
		foreach my $order_bundle (@{$order_group->{'order_bundles'}}) {
			my $bundle_licenses = Fap::ServerLicense::get_bundle_licenses($order_bundle->{'bundle_id'});
			foreach my $lic (@{$bundle_licenses}) {
				my $license_id = $obj->update_server_license($lic->{'license_type_id'}, $order_bundle->{'quantity'});
				if (!defined($license_id)) {
					$client->displayfailure('ERR: Cannot add server license in order group ' . $order_group->{'order_group_id'} . ": $@");
				} else {
					push @lic_ids, $license_id;
				}
			}
		}
	}
	
	if (@lic_ids) {
		$input->{'created_server_license_ids'} = \@lic_ids;
	}
	
	return $input;
}

sub rollback {
	my ($package, $client, $input) = @_;
	
	my $fcs_schema = Fap::Model::Fcs->new();

	if (!Fap::Order::validate_prov_order($fcs_schema, $input->{'order_id'})) {
		$client->displayfailure("ERR: Invalid order: $@");
	}

	Fap::ServerLicense::remove_server_licenses($input->{'created_server_license_ids'});
	
	return $input;
}
