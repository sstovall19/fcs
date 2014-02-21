#!/usr/bin/perl

use strict;

sub process_Server_Rapsheet
{
	my $self = shift;

	my $server_id = $self->valid->param('server_id', 'numbers');

	if($server_id)
	{
		my($customer_id, $tickets);

		my $dbh = $self->server_dbh($server_id);

		if($dbh)
		{
			my $server_info = F::Customer::get_server_info($dbh, $server_id);

			if($server_info && ref($server_info) eq 'HASH')
			{
				$customer_id = $server_info->{'customer_id'};

				
			}
			else
			{
				$self->write_log(level => 'ERROR', log => "Could not get customer info for server ID $server_id: $@");
				$self->alert('Invalid server ID');
			}
		}
		else
		{
			$self->write_log(level => 'ERROR', log => "Could not connect to server database: $@");
			$self->alert('Could not connect to server database');
		}	
	}

	return $self->tt_process('Support/Server_Rapsheet.tt');
}

sub Support_Server_Rapsheet_init_permissions
{
	my $perm = {
		GLOBAL => 1
	};
}

1;
