#!/usr/bin/perl

use strict;
use F::Server;
use F::Customer;

sub process_View_Customer
{
	my $self = shift;
	my ($customer_info, $dbh);

	my $action = $self->valid->param('action');

	if($action eq 'searchable')
	{
		my $q = $self->valid->param('query');

		my @results;

		if(my $res = F::Customer::get_customer_list_by_name($self->_server_dbh(1000), $q, 2))
		{
			push(@results, {
				mode => 'Core.View_Customer',
				params => { customer_id => $_->{customer_id}, action => 'view' },
				label => "View customer $_->{name} - matching",
			}) for @{$res};
		}

		if(my $res = F::Customer::get_customer_list_by_name($self->_server_dbh(100000), $q, 2))
		{
			push(@results, {
				mode => 'Core.View_Customer',
				params => { customer_id => $_->{customer_id}, action => 'view' },
				label => "View customer $_->{name} - matching",
			}) for @{$res};
		}

		$self->write_log(level => 'DEBUG', log => [ "Found these results", \@results ]);

		return $self->json_process({ results => \@results });	
	}

	my $customer_id = $self->valid->param('customer_id', 'numbers');
	my $server_id = $self->valid->param('server_id', 'numbers');

	if($server_id)
	{
		$dbh = $self->_server_dbh($server_id);
		if(!$customer_id)
		{
			if(my $server_info = F::Server::get_server_info($dbh, $server_id))
			{
				$customer_id = $server_info->{'customer_id'};
			}
		}
	}

	if($customer_id)
	{
		if($dbh)
		{
			$customer_info = F::Customer::get_customer_info($dbh, $customer_id);
		}
		else
		{
			if($customer_info = F::Customer::get_customer_info($self->_server_dbh(1000), $customer_id))
			{
				$dbh = $self->_server_dbh(1000);
			}
			elsif($customer_info = F::Customer::get_customer_info($self->_server_dbh(100000), $customer_id))
			{
				$dbh = $self->_server_dbh(100000);
			}
		}

		if(!$customer_info)
		{
			$self->write_log(level => 'ERROR', log => "Invalid customer ID $customer_id");
			$self->display_error("Invalid customer ID $customer_id");
		}
	}


	if($action eq 'view')
	{
		$self->tt_append(var => 'CUSTOMER_INFO', val => $customer_info);
	}

	$self->title('View Customer Information');
	return $self->tt_process('Core/View_Customer.tt');
}

sub Core_View_Customer_init_permissions
{
	my $perm = {
		DESC => 'Customer information application',
		PERMISSIONS => # Application Permissoins
		{
			'change_customer_name' =>
			{
				LEVELS => 'w',
				NAME => 'Edit customer name',
				DESC => 'The ability to edit a customer\'s name'
			},
		},
		LEVELS => 'r',
		VERSION => 3
	};


	return $perm;
}

sub Core_View_Customer_init_searchable
{
	my $self = shift;

	$self->add_searchable_application('Core.View_Customer', '^\w+');
}

1;
