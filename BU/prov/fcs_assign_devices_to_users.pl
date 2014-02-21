#!/usr/bin/perl
#
# Assign Devices to users BU
#
#  Notes:
#
# 	Assigns Phones to users based on the order.
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
use Fap::Devices;
use Fap::Provision;
use Fap::Server;
use Fap::User;
use Fap::Extensions;

my $client = Fap::StateMachine::Unit->new()->run();

sub execute
{
	my ($package, $client, $input) = @_;

	# initiate db handler
	my $fcs_dbh = Fap::Model::Fcs->new();

	# validate order information	
	my $order_id = $input->{'order_id'};
	if (!Fap::Order::validate_prov_order($fcs_dbh, $order_id)) {
		$client->displayfailure("ERR: Invalid order: $@");
	}

	my $order = Fap::Order->new('order_id'=>$order_id)->get_details();

	# check if all phones have been scanned and added from the order
	foreach my $order_group ( @{ $order->{'order'}->{'order_groups'} } ) {
		my $server_id = $order_group->{'server_id'};
		foreach my $order_bundle (@{$order_group->{'order_bundles'}}) {
			my $bundle = Fap::Bundle->new(
				bundle_id => $order_bundle->{'bundle_id'},
				fcs_schema => $fcs_dbh,
			);
			if (!defined($bundle)) {
				$client->displayfailure('ERR: bundle id is invalid in order group ' . $order_group->{'order_group_id'} .
							' order bundle ' . $order_bundle->{'order_bundle_id'} . ": $@");
			}
			# skip non phone bundle
			next if $order_bundle->{'bundle'}->{'category'}->{'name'} ne 'phone';

			if (!defined($order_bundle->{'order_bundle_details'}) || scalar(@{$order_bundle->{'order_bundle_details'}}) == 0) {
				$client->displayfailure("ERR: Missing order bundle details from bundle: ". $order_bundle->{'order_bundle_id'} . ": $@");
			}

			foreach my $order_bundle_detail (@{$order_bundle->{'order_bundle_details'}}) {
				my $mac = $order_bundle_detail->{'mac_address'};
				if (!$mac) {
					$client->displayfailure("ERR: Missing mac address detail from phone bundle: " . $order_bundle_detail->{'order_bundle_detail_id'} . ": $@");
				}
			}
		}
	}
	
	# get the phones from order
	my $phones = Fap::Provision::get_scanned_phones($fcs_dbh, $order_id);
        if (!defined($phones)) {
		# if there are no phones in this order, treat as success
		return $input;
        }

	my $devices = {};
	my $server_infos = {};
	my $users = {};
	my $nophones = {};
	my $devices_to_assign = {};
	my $free_exts = {};

	# check that all the phones in the order exist in devices table
	foreach my $server_id (keys %{$phones}) {
		$devices->{$server_id} = Fap::Devices::get_devices($fcs_dbh, $server_id);
		# find out if server is hosted
		# hosted server will have device sip name with appended -$server_id
		$server_infos->{$server_id} = Fap::Server->new('server_id' => $server_id);

		# get users and primary extensions
		$users->{$server_id} = Fap::User::get_user_list_for_server($fcs_dbh, $server_id);
		# find device_id /dev/null for this server
		$nophones->{$server_id} = Fap::Devices::get_nophone_for_server($fcs_dbh, $server_id);

		# get the extensions with no device assigned yet
		$free_exts->{$server_id} = [];
		foreach my $u (@{$users->{$server_id}}) {
			my $primary_ext = $u->{'extension'};
			my $ext_info = Fap::Extensions::get($fcs_dbh, $server_id, $primary_ext);
			# skip if extension info is not found
			if (!$ext_info) {
				next;
			}
			# skip virtual only or voicemail only ext
			if ($ext_info && $ext_info->{'free_ext'} != 1 && $ext_info->{'device_id'} eq $nophones->{$server_id}->{'device_id'}) {
				push (@{$free_exts->{$server_id}}, $primary_ext);
			}
		}

		$devices_to_assign->{$server_id} = [];

		foreach my $model (keys %{$phones->{$server_id}}) {
			foreach my $mac (@{$phones->{$server_id}->{$model}}) {
				my $device_name = "SIP/$mac";
				if ($server_infos->{$server_id}->{'details'}->{'mosted'}) {
					$device_name .= "-$server_id";
				}
				# if device in order is not found in devices table, return error
				if (!grep { $_->{'name'} eq $device_name } @{$devices->{$server_id}}) {
					$client->displayfailure("ERR: Found mac address without existing device: $mac: $@");
				}

				# get the device id
				foreach my $dev (@{$devices->{$server_id}}) {
					if ($dev->{'name'} eq $device_name) {
						push(@{$devices_to_assign->{$server_id}}, $dev->{'device_id'});
						last;
					}
				}
			}
		}
	}

	# do the device assignment
	foreach my $server_id (keys %{$devices_to_assign}) {
		# if there are no users primary ext with no device, just skip
		if (scalar(@{$free_exts->{$server_id}}) == 0) {
			next;
		}
		foreach my $dev (@{$devices_to_assign->{$server_id}}) {
			# if there is no more free exts, just skip
			if (scalar(@{$free_exts->{$server_id}}) == 0) {
				next;
			}

			# get one extension from the free_exts
			my $ext = shift(@{$free_exts->{$server_id}});
			# assign the device to this ext
			if (Fap::Devices::assign_device($fcs_dbh, $server_id, $dev, $ext)) {
				# add to assigned_device_to_exts
				if (!defined($input->{'assigned_device_to_exts'})) {
					$input->{'assigned_device_to_exts'} = [];
				}
				push (@{$input->{'assigned_device_to_exts'}}, $dev);
			} else {
				$client->displayfailure("ERR: cannot assign device $dev to ext $ext for server $server_id: $@");
			}
		}
		
		# copy the generated phone config files to prov servers
		if (!_push_tftpd_to_prov($server_id, $server_infos->{$server_id}->{'details'}->{'country'})) {
			$client->displayfailure("ERR: cannot copy phone config files to provisioning server: $@");
		}
	}

	return $input;
}

sub rollback {
	my ($package, $client, $input) = @_;
	
	my $fcs_dbh = Fap::Model::Fcs->new();

	# validate order information	
	my $order_id = $input->{'order_id'};
	if (!Fap::Order::validate_prov_order($fcs_dbh, $order_id)) {
		$client->displayfailure("ERR: Invalid order: $@");
	}

	# look for the device ids
	if (defined($input->{'assigned_device_to_exts'}) && scalar(@{$input->{'assigned_device_to_exts'}}) > 0) {
		# unassign the device
		foreach my $dev (@{$input->{'assigned_device_to_exts'}}) {
			if (!Fap::Devices::unassign_device($fcs_dbh, $dev)) {
				$client->displayfailure("ERR: cannot unassign device $dev: $@");
			}
		}
	}

	return $input;
}

sub _push_tftpd_to_prov
{
	my $server_id = shift;
	my $country = shift;

	my $host = 'prov';
	if ($country =~ /Australia/i) {
		$host = 'prov-au';
	}

	# grab all phone config files generated in /etc/fonality/sid/tftpd
	my $sys_cmd = qq{ls /etc/fonality/$server_id/tftpd/};
	my @files = grep { $_ && !/.(?:lck|tmp)/i } `$sys_cmd`;
	chomp(@files);

	my ($user, $group) = ('nobody', 'nobody');
	if ($host eq 'prov-au') {
		$group = 'nogroup';
	}

	foreach my $f (@files) {
		my @args = ("scp", "-C", "/etc/fonality/$server_id/tftpd/$f", "$host:/tftpboot/");
		#system(@args);
	}

	return 1;
}

