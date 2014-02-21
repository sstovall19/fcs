#!/usr/bin/perl

use strict;

use F::LiveBackupServer;
use F::Server;
use F::Customer;
use F::Util;

sub process_Server_Details
{
	my $self = shift;
	
	my $action = $self->valid->param('action');

	my $server_id = $self->valid->param('server_id', 'server_id');

	my $dbh;

	if($server_id)
	{
		$dbh = $self->_server_dbh($server_id);
	}

	if($action eq 'change_customer_id')
	{
		if($self->has_permission('change_customer_id', 'w'))
		{
			my $server_id = $self->valid->param('server_id', 'server_id');
			my $customer_id = $self->valid->param('customer_id', 'numbers');
			my $new_customer_id = $self->valid->param('new_customer_id', 'numbers');

			my $res = $self->change_customer_id($server_id, $customer_id, $new_customer_id);

			if($res)
			{
				$self->tt_append(var => 'success', val => "Moved server ID $server_id to customer ID $new_customer_id");
			}
			else
			{
				$self->tt_append(var => 'error_msg', val => "Could not move server ID $server_id to customer ID $new_customer_id - Reason: $@");
			}
		}
		else
		{
			$self->tt_append(var => 'error_msg', val => "You do not have permission to change a server's customer ID");
		}

		return $self->json_process;
	}
	elsif($action eq 'change_nfr_status')
	{
		if($self->has_permission('change_nfr_status', 'w'))
		{
			my $server_id = $self->valid->param('server_id', 'server_id');
			my $nfr_status = $self->valid->param('nfr_status', 'numbers');

			my $res = $self->change_nfr_status($server_id, $nfr_status);

			if($res)
			{
				$self->tt_append(var => 'success', val => "Updated NFR status for server");
			}
			else
			{
				$self->tt_append(var => 'error_msg', val => "Could not update NFR status $@");
			}
		}
		else
		{
			$self->tt_append(var => 'error_msg', val => "You do not have permission to change a server's NFR status");
		}

		return $self->json_process;
	}
	elsif($action eq 'change_can_link')
	{

	}
	elsif($action eq 'change_cancel_status')
	{

	}
	elsif($action eq 'change_server_features')
	{

	}
	elsif($action eq 'change_production_status')
	{

	}
	elsif($action eq 'change_installed_status')
	{

	}
	elsif($action eq 'change_tracking_number')
	{

	}
	elsif($action eq 'change_demo_status')
	{

	}
	elsif($action eq 'change_cp_location')
	{

	}
	elsif($action eq 'change_cp_version')
	{

	}
	elsif($action eq 'change_asterisk_version')
	{

	}

	$self->title('Server Details');

	if($server_id)
	{
		my $server_info = F::Server::get_server_info($dbh, $server_id);

		if($server_info)
		{
			my $server_list = F::Server::get_server_list_by_customer_id($dbh, $server_info->{'customer_id'});

			foreach my $s ( @{$server_list} )
			{
				$s = F::Server::get_server_info($dbh, $s->{'server_id'});
				$self->write_log(level => 'DEBUG', log => [ "SERVER INFO", $s ] );
			}

			# Add LBS, Connect and Recordall info
			map {

				$_->{'lbs_info'} = F::LiveBackupServer::get_backup_status( $dbh, $_->{'server_id'} );
				$_->{'unbound'}  = F::Server::is_unbound($dbh, $_->{'server_id'});
				$_->{'inphonex_cuid'} = F::Customer::get_inphonex_customer_id( $_->{'server_id'}, $dbh );
				#$_->{'rserver_info'} = F::Util::get_recordall_info($dbh, $_->{'server_id'});

			} @{$server_list};

			$self->write_log(level => 'DEBUG', log => ["Found server list", $server_list ]);
			$self->tt_append(var => 'SERVER_LIST', val => $server_list);		
		}
		else
		{
			$self->alert('Invalid server ID');
		}
	}
	
	return $self->tt_process('Core/Server_Details.tt');
}

sub change_nfr_status
{
	my $self = shift;
	my($server_id, $nfr_status) = @_;

	if(!$server_id)
	{
		$@ = "Server ID is required";
		return undef;
	}

	if(!defined($nfr_status))
	{
		$@ = "NFR status is required";
		return undef;
	}

	my $dbh = $self->_server_dbh($server_id);

	if($dbh)
	{
		if(F::Server::change_nfr_status($dbh, $server_id, $nfr_status))
		{
			return 1;
		}
		else
		{
			return undef;
		}
	}
	else
	{
		$@ = "Invalid server ID";
		return undef;
	}
}

sub change_customer_id
{
	my $self = shift;
	my($server_id, $customer_id, $new_customer_id) = @_;

	if(!$server_id)
	{
		$@ = "Server ID is required";
		return undef;
	}

	if(!$customer_id)
	{
		$@ = "Current customer ID is required";
		return undef;
	}

	if(!$new_customer_id)
	{
		$@ = "New customer ID is required";
		return undef;
	}

	my $dbh = $self->_server_dbh($server_id);

	if(!$dbh)
	{
		$@ = "Invalid server ID";
		return undef;
	}

	my $customer_info = F::Customer::get_customer_info($dbh, $customer_id);
	my $new_customer_info = F::Customer::get_customer_info($dbh, $new_customer_id);

	if(!$customer_info)
	{
		$@ = "Invalid customer ID";
		return undef;
	}

	if(!$new_customer_info)
	{
		$@ = "New customer ID is invalid";
		return undef;
	}

	# Servers that are trixbox must have the same billing cycle day	
	my (undef,undef,$old_day) = $customer_info->{billing_cycle} =~ m/^(....)-(..)-(..)$/;
	my (undef,undef,$new_day) = $new_customer_info->{billing_cycle} =~ m/^(....)-(..)-(..)$/;

	if($self->is_trixbox($server_id) && $old_day != $new_day)
	{
		$@ = "Billing cycle does not match";
		return undef;
	}

	if(F::Server::move_server_to_customer($dbh, $server_id, $new_customer_id))
	{
		return 1;
	}
	else
	{
		return undef;
	}	
}

sub Core_Server_Details_init_permissions
{
	my $perm = {
		VERSION => 1,
		DESC => "View Server Details",
		LEVELS => 'r',
		PERMISSIONS => {
			'change_customer_id' => {
				DESC => 'Ability to change a server\'s customer ID',
				LEVELS => 'w'
			},
			'can_link' => {
				DESC => 'Change can link status of servers',
				LEVELS => 'w',
			},
			'cancel_status' => {
				DESC => 'Change whether or not a server is cancelled',
				LEVELS => 'w',
			},
			'add_new_cancel_reasons' => {
				DESC => 'Add new cancellation reasons',
				LEVELS => 'w',
			},
			'server_features' => {
				DESC => 'Change server features',
				LEVELS => 'w',
			},
			'production_status' => {
				DESC => 'Change production status - BETA / Dev',
				LEVELS => 'w',
			},
			'installed_status' => {
				DESC => 'Change server installed status',
				LEVELS => 'w',
			},
			'tracking_number' => {
				DESC => 'Change server tracking number',
				LEVELS => 'w',
			},
			'change_demo_status' => {
				DESC => 'Change whether a server is a demo server',
				LEVELS => 'w',
			},
			'change_cp_version' => {
				DESC => 'Change CP Version',
				LEVELS => 'w',
			},
			'change_cp_location' => {
				DESC => 'Change CP location',
				LEVELS => 'w',
			},
			'change_nfr_status' => {
				DESC => 'Change Not For Resale Status',
				LEVELS => 'w',
			}
		}
	};
}

sub Core_Server_Details_init_searchable
{

}

1;
