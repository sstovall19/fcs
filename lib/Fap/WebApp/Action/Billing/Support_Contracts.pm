#!/usr/bin/perl

use strict;

use F::Support;
use F::Server;
use F::Customer;
use F::PBXtraAnnualSupport;
$Data::Dumper::Pair = '=>'; # Stupid, but necessary hack to handle the definition in F::PBXtraAnnualSupport

sub process_Support_Contracts
{
	my $self = shift;

	my $action = $self->valid->param('action');
	my $to_json = $self->valid->param('to_json');

	$self->write_log(level => 'DEBUG', log => "Access application - Action: $action");

	if($action eq 'searchable')
	{
		my $server_id = $self->valid->param('query', 'numbers');

		$self->write_log(level => 'DEBUG', log => "Search for support contracts for server ID $server_id");

		if($server_id)
		{
			if(my $dbh = $self->_server_dbh($server_id))
			{
				if(my $support_contracts = F::Support::get_contracts($dbh, $server_id))
				{
					return $self->json_process({
						results => 
						[
							{
								mode => 'Billing.Support_Contracts',
								label => "View support contracts for server ID",
								params => { action => 'display_support_contracts', server_id => $server_id },
							}
						]
					});
				}
			}
		}
		
		return $self->json_process({ no_results => 1 });

	}
	elsif($action eq 'display_support_contracts')
	{
		my $server_id = $self->valid->param('server_id', 'server_id');
		
		if($server_id)
		{
			my $dbh = $self->_server_dbh($server_id);

			my $server_info = F::Server::get_server_info($dbh, $server_id);
			my $customer_info;

			if($server_info && ( $customer_info = F::Customer::get_customer_info($dbh, $server_info->{'customer_id'})))
			{
				my @contracts;

				# Annual Support Payment Method
				my $pas = F::PBXtraAnnualSupport->new(dbh => $dbh);

				foreach my $server ( @{$customer_info->{'servers'}} )
				{
					my $contract = F::Support::get_support_quick($dbh, $server) || F::Customer::get_support_info($dbh, $server);

					if($contract)
					{
						map {
							if(!$contract->{$_})
							{
								$contract->{$_} = ($_ eq 'creation_date') ? $contract->{last_paid_date} : $contract->{last_expire_date};
							}
							$contract->{$_} = $self->reverse_date($contract->{$_});
						} qw/expire_date creation_date/;

						# Change paid status to Expired if the contract is expired
						$contract->{'paid_status'} = 'Expired' if $self->is_date_past($contract->{'expire_date'});
							
						$contract->{'payment_method'} = $pas->payment_method($server_info->{'customer_id'}, $server) || 'None';
						$self->write_log(level => 'DEBUG', log => [ "CONTRACT - $@", $contract ]);
						push(@contracts, $contract);
					}
				}

				if(@contracts)
				{
					$self->tt_append(var => 'SUPPORT_CONTRACTS', val => \@contracts);
					$self->write_log(level => 'DEBUG', log => \@contracts);
				}
				else
				{
					$self->write_log(level => 'DEBUG', log => "No support contracts found for server ID $server_id");
					$self->alert("No support contracts found for server ID $server_id");
				}

			}
			else
			{	
				$self->write_log(level => 'DEBUG', log => "Could not find server ID $server_id");
				$self->alert("Could not find server ID $server_id");
			}
		}
		else
		{
			$self->write_log(level => 'ERROR', log => "No server ID provided to search support contracts");
			$self->alert('No server ID to search for contracts');
		}
	}
	elsif($action eq 'remove_support_contract')
	{

	}
	elsif($action eq 'update_support_contract')
	{
		if(!$self->has_permission('edit_support_contracts', 'w'))
		{
			$self->alert('You do not have permission to edit support contracts.');
			return $self->json_process;
		}

		my $server_id = $self->valid->param('server_id', 'server_id');
		my $id = $self->valid->param('support_contract_id');
		my $creation_date = $self->valid->param('creation_date');
		my $expire_date = $self->valid->param('expire_date');
		my $paid_status = $self->valid->param('paid_status', 'text');
		my $support_level = $self->valid->param('support_level');

		# Reverse the date format
		$creation_date = $self->reverse_date($creation_date);
		$expire_date = $self->reverse_date($expire_date);

		if(!$server_id)
		{
			$self->write_log(level => 'WARN', log => "Update support contract without server id");
			$self->alert('Invalid server id');
			return $self->json_process;
		}

		if(!$creation_date)
		{
			$self->write_log(level => 'WARN', log => "Update support contract without creation date");
			$self->alert('Invalid last paid date');
			return $self->json_process;
		}

		if(!$expire_date)
		{
			$self->write_log(level => 'WARN', log => "Update support contract without expire date");
			$self->alert('Invalid expire date');
			return $self->json_process;
		}

		if(!$paid_status)
		{
			$self->write_log(level => 'WARN', log => "Update support contract without paid status");
			$self->alert('Invalid status');
			return $self->json_process;
		}

		if(!$support_level)
		{
			$self->write_log(level => 'WARN', log => "Update support contract without support level");
			$self->alert('Invalid support level');
			return $self->json_process;
		}

		my $dbh = $self->_server_dbh($server_id);

		$self->write_log(level => 'DEBUG', log => [
			'UPDATE SUPPORT CONTRACT FORM DATA',
			$server_id,
			$creation_date,
			$expire_date,
			$paid_status,
			$support_level,
			'DBH:'.ref($dbh)
		]);

	        if(F::Customer::update_support_info($dbh, $server_id, $creation_date, $expire_date, $paid_status, $support_level))
		{
			$self->audit(server_id => $server_id, log => "Updated support contract id $id");
			$self->write_log(level => 'VERBOSE', log => "Updated support contract id $id for server $server_id");
			$self->tt_append(var => 'success', val => 1);
		}
		else
		{
			$self->write_log(level => 'ERROR', log => "Could not update support contract for server_id $server_id - $@");
			$self->alert('Could not update support contract');
		}

		return $self->json_process;
	}

	if($to_json)
	{
		return $self->json_process;
	}
	else
	{
		$self->title('Support Contracts');
		return $self->tt_process('Billing/Support_Contracts.tt');
	}
}

sub is_date_past
{
	my $self = shift;
        my $date = shift;

	my ($year, $month, $day);

	
        my @date_parts = split(/-/,$date);

	if($date_parts[0] < 100)
	{
		$year = $date_parts[2];
		$month = $date_parts[0];
		$day = $date_parts[1];
	}
	else
	{
		$year = $date_parts[0];
		$month = $date_parts[1];
		$day = $date_parts[2];
	}

        my $this_year  = (localtime(time))[5] + 1900;
        my $this_month = (localtime(time))[4] + 1;
        my $this_day   = (localtime(time))[3];

        if ($year < $this_year or ($year == $this_year and $month < $this_month) or
                ($year == $this_year and $month == $this_month and $day < $this_day))
        {
		$self->write_log(level => 'DEBUG', log => "$year-$month-$day is less than $this_year-$this_month-$this_day");	
                return 1;
        }
        else
        {
                return undef;
        }
}


sub Billing_Support_Contracts_init_permissions
{
	my $self = shift;

	my $perm = {
		DESC => 'Support Contract Application',
		PERMISSIONS => # Application Permissoins
		{
			'edit_support_contracts' =>
			{
				LEVELS => 'w',
				NAME => 'Edit and remove support contracts',
				DESC => 'Edit and remove support contracts'
			},
		},
		LEVELS => 'r',
		VERSION => 2
	};


	return $perm;
}

sub Billing_Support_Contracts_init_searchable
{
	my $self = shift;
	$self->add_searchable_application('Billing.Support_Contracts', '^\d{4,6}$');
}



1;
