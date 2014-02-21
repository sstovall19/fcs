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
use warnings;
use Fap::Model::Fcs;
use Fap::StateMachine::Unit;
use Fap::Order;
use Fap::Bundle;
use Fap::PhoneNumbers;
use Fap::CallerID;
use Fap::Devices;
use JSON;
# for optmal search of phone_numbers
use List::Util qw(first);

my $client = Fap::StateMachine::Unit->new()->run();

sub execute {
	my ($package, $client, $input) = @_;
	
	my $fcs_schema = Fap::Model::Fcs->new();

    my $order_id = $input->{'order_id'};
    my $order = Fap::Order->new('order_id'=>$order_id)->get_details();
    if (!Fap::Order::validate_prov_order($fcs_schema, $order_id)) {
        $client->displayfailure("ERR: Invalid order: $order_id");
    }

    foreach my $order_group ( @{ $order->{'order'}->{'order_groups'} } ) {
		my $server_id = $order_group->{'server_id'};
		my @phone_numbers = Fap::PhoneNumbers::get_phone_numbers($fcs_schema, $server_id);	
		my $primary_exts = Fap::User::get_user_list_for_server($fcs_schema, $server_id);	
		foreach my $order_bundle (@{$order_group->{'order_bundles'}}) {
			#next unless $bundle->is_phone_bundle();
			next unless ($order_bundle->{'bundle'}->{'category'}->{'name'} eq 'phone_number');
			my @dids;
			foreach my $order_bundle_detail (@{$order_bundle->{'order_bundle_details'}}) {
				# extract the DID list from the order bundle
				push(@dids, $order_bundle_detail->{'did_number'});
			}
			foreach my $did (@dids) {
				# search for DID in @phone_numbers
				my $number = first { $_->{number} eq $did } @phone_numbers;
				unless ($number)
				{
					$client->displayfailure("ERR: DID $did does not match SERVER $server_id in phone_numbers table: $@");
				}	
				# validate, don't verify, DID	
				unless ($did =~ m/^(?:9?1)?(\d{10})/)
				{
					$client->displayfailure("ERR: DIDs not purchased yet: $@");
				}
				# get primary extensions
				my $exten = undef;
				for my $primary (@$primary_exts) {
					# search for primary extension in @phone_numbers
					if (!defined(my $extension = first {defined($_->{extension}) && $_->{extension} eq $primary->{extension}} @phone_numbers)) {
						# if this primary extension is unassigned, assign it
						$exten = $primary->{extension};
						last;
					}
				}
				my $u_info = Fap::User::get_user_info_by_ext_and_server($fcs_schema, $exten, $server_id); 
				if (!defined($u_info)) {
					$client->displayfailure("ERR: could not get user info for $server_id extension $exten: $@");
				}
				my $name = join(" ", $u_info->{'first_name'}, $u_info->{'last_name'});
				if (!defined(Fap::CallerID::set_caller_id($server_id, $did, $name, $exten, 1))) {
					$client->displayfailure("ERR: failed to set caller id for server $server_id extension $exten DID $did name $name: $@");
				}
				if (!defined(Fap::PhoneNumbers::update_phone_number($server_id, $did, $exten))) {
					$client->displayfailure("ERR: failed to update phone number for server $server_id extension $exten DID $did: $@");
				}
				push (@{$input->{'did_assigned_users'}}, $u_info->{'user_id'});
			}
		}
	}
	return $input;
}

sub rollback {
	my ($package, $client, $input) = @_;
	
	my $fcs_schema = Fap::Model::Fcs->new();

	# make sure an array was deserialized
	return $input unless ref($input->{'did_assigned_users'}) eq 'ARRAY';
	foreach my $did_assigned_user (@{$input->{'did_assigned_users'}}) {
		my $user = Fap::User::get_user_info_by_id($fcs_schema, $did_assigned_user);
		if (!defined($user)) {
				$client->displayfailure("ERR: userid maps to no serverid: $did_assigned_user: $@");
		}
		my $server_id = $user->{'default_server_id'};
		my $exten = $user->{'extension'};
		my $rci = Fap::CallerID::remove_caller_id($server_id, $exten);
		if (!defined($rci)) {
			$client->displayfailure("ERR: failed to remove caller id for server $server_id  extension $exten: $@");
		}
		my @phone_numbers = Fap::PhoneNumbers::get_phone_numbers($fcs_schema, $server_id, $exten);
		foreach my $did (@phone_numbers) {
			if (!defined($did)) {
				$client->displayfailure("ERR: failed to update phone number for server $server_id extension $exten DID $did: $@");
			}
			my $upn = Fap::PhoneNumbers::update_phone_number($server_id, $did->{number}, undef);
			if (!defined($upn)) {
				$client->displayfailure("ERR: failed to update phone number for server $server_id extension $exten DID $did->{number}: $@");
			}
		}
	}
	if (defined($input->{'did_assigned_users'})) {	
		delete $input->{'did_assigned_users'};			
	}
	return $input;
}
