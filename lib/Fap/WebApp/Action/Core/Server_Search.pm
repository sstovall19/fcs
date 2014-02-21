#!/usr/bin/perl

use strict;

use F::Server;
use F::Customer;

sub process_Server_Search
{
	my $self = shift;

	my $action = $self->valid->param('action');

	if($action eq 'searchable')
	{
		my $server_id = $self->valid->param('query');

		if($server_id =~ /^\d{4,6}$/)
		{
			$self->write_log(level => 'DEBUG', log => "User searching for server ID for login: $server_id");

			if(my $server_info = F::Server::get_server_info($self->_server_dbh($server_id), $server_id))
			{
				$self->write_log(level => 'DEBUG', log => "Found valid server info");

				# Load customer info
				my $customer_info = F::Customer::get_customer_info($self->_server_dbh($server_id), $server_info->{'customer_id'});

				my $label;

				if($customer_info)
				{
					$self->write_log(level => 'DEBUG', log => "Found customer info for server: $server_id");
					$label = $customer_info->{'name'};
				}
				else
				{
					$self->write_log(level => 'WARN', log => "Could not load customer info for server: $server_id: $@");
				}

				my @results = ( 
					{
						mode => 'Core.Server_Search',
						label => "Login to $label server",
						params => { action => 'login', server_id => $server_id },
						target => '_blank'
					}
				);

				if($customer_info)
				{
					push(@results,
						{
							mode => 'Core.View_Customer',
							label => "View customer $label - Server ID",
							params => { action => 'view', customer_id => $customer_info->{'customer_id'}, server_id => $server_id }
						},
						{
							mode => 'Core.NetSuite_Search',
							label => "View NetSuite account for customer $label - Server ID",
							params => { action => 'view_netsuite_account', netsuite_id => $customer_info->{'netsuite_id'} },
							target => '_blank'
						}
					);
				}

				return $self->json_process({
					results => \@results
				});
			}
			else
			{
				$self->write_log(level => 'DEBUG', log => "Invalid server ID $server_id: $@");
				return $self->json_process({no_results => 1});
			}
		}
		else
		{
			$self->write_log(level => 'WARN', log => "Search for server ID with invalid server ID: $server_id ( PLEASE fix the search format for this app ).");
			return $self->json_process({no_results => 1});
		}
	}
	elsif($action eq 'login')
	{
		my $server_id = $self->valid->param('server_id');

		if(!$server_id)
		{
			$self->display_error('No server ID provided to log in to');
		}

		my $server_info = F::Server::get_server_info($self->_server_dbh($server_id), $server_id);

		if(!$server_info)
		{
			$self->display_error("Invalid server ID: $server_id");
		}

		# Fonality servers are off-limits to the Intranet login
		if($server_info->{'customer_id'} == 1)
		{
			$self->write_log(level => 'WARN', log => "Attempt to log into a Fonality server $server_id");
			$self->display_error("Server ID $server_id does not allow this method of log in.  Please contact helpdesk or your manager to make administrative changes to this server.");
		}

		if(F::Server::is_unbound_host($self->_server_dbh($server_id), $server_id))
		{
			$self->write_log(level => 'WARN', log => "Attempt to log into a mosted server $server_id");
			$self->display_error("You cannot log into a host server admin panel");
		}


		my $admin = F::User::get_admin_list_for_server($self->_server_dbh($server_id), $server_id);

		if (ref($admin) eq "ARRAY" && ref($admin->[0]) eq "HASH")
		{
			my $sinfo = F::Server::get_server_info($self->_server_dbh($server_id), $server_id);
			my $host  = $self->valid->param('host') || F::CPBase::get_cp_url($self->_server_dbh($server_id), $server_id);

			my $username = $admin->[0]{username};
			my $password = $admin->[0]{password};
			$username =~ s/(\W)/"%" . unpack("H2", $1)/eg;
			$password =~ s/(\W)/"%" . unpack("H2", $1)/eg;

			my $domain = ($server_id < 100000) ? 'fonality.com' : 'trixbox.com';
			# Don't base host off of 5.0/not; fix it if it needs it! CONSISTENCY!
			$host =~ s/\.$//;
			$host .= ".$domain" if $host !~ /\.\Q$domain\E$/i;

			# Felix Nilam - 11/30/2009
			# if server is cp version 5.0 or later, do not pass in the password
			my $login = "username=$username" . ($sinfo->{'cp_version'} < '5.0' ? "&password=$password" : "&login_from_intranet=1");
			$self->write_log(level => 'DEBUG', log => "Going to redirect to: $host/cpa.cgi?main_tab=1&do=authenticate&$login");
			return $self->redirect("$host/cpa.cgi?main_tab=1&do=authenticate&$login");
		}

	}
	elsif($action eq 'populate_search_box')
	{
		my $server_id = $self->valid->param('server_id', 'server_id');

		my @results;

		my $dbh = $self->_pbxtra_dbh;
		
		return $self->json_process({ results => [ 
				{ label => 'Some Server ID ' . $server_id, value => $server_id }, 
				{ label => 'Other Server ID '. $server_id.'3', value => $server_id.'3' } ] 
		});
	
	}
}

sub Core_Server_Search_init_permissions
{
	my $self = shift;

	my $perm = {
		GLOBAL => 1,
	};

	return $perm;
}

sub Core_Server_Search_init_searchable
{
	my $self = shift;

	$self->add_searchable_application('Core.Server_Search', '^\d{4,6}$');
}

1;
