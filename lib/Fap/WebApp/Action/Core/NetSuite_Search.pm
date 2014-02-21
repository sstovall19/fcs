#!/usr/bin/perl

use strict;
use F::Order;
use F::Customer;

sub process_NetSuite_Search
{
	my $self = shift;

	my $action = $self->valid->param('action');
	
	if($action eq 'searchable')
	{
		my $so = $self->valid->param('query');

		if($so)
		{
			my $order;
			my $dbh;
			my $field;
			
			if($so =~ /^(?:SO\-|\d{10,})/)
			{
				$field = 'ticket_id';
			}
			else
			{
				$self->write_log(level => 'WARN', log => "Invalid search string");
				return $self->json_process({ no_results => 1 });
			}


			if($order = F::Order::get_order_from_field($self->_server_dbh(1000), $field, $so, 1))
			{
				$dbh = $self->_server_dbh(1000);
			}
			elsif($order = F::Order::get_order_from_field($self->_server_dbh(100000), $field, $so, 1))
			{
				$dbh = $self->_server_dbh(100000);
			}

			if($order)
			{
				my $label = "View NetSuite order";

				if($order->{'customer_id'})
				{
					if(my $customer_info = F::Customer::get_customer_info($dbh, $order->{'customer_id'}))
					{
						$label .= " for $customer_info->{'name'}";
					}
				}

				$label .= " ( server ID: $order->{'server_id'} )" if $order->{'server_id'};

				$self->json_process({
					results => 
					[
						{
							mode => 'Core.NetSuite_Search',
							label => $label,
							params => { action => 'view_sales_order', sales_order => $order->{'netsuite_salesorder_id'} },
							target => '_blank'
						}
					]
				});
			}
			else
			{
				$self->write_log(level => 'DEBUG', log => "No orders found for $so ( Field: $field ) $@");
				return $self->json_process({ no_results => 1 });
			}
		}
		else
		{
			$self->write_log(level => 'WARN', log => "Search without a query param");
			return $self->json_process({ no_results => 1 });
		}
	}
	elsif($action eq 'view_sales_order')
	{
		my $so = $self->valid->param('sales_order');

		$self->write_log(level => 'DEBUG', log => "Redirecting to netsuite to view sales order $so");

		if($so)
		{
			return $self->redirect('https://system.netsuite.com/app/accounting/transactions/salesord.nl?id='.$so);
		}
		else
		{
			$self->display_error('Invalid sales order ID');
		}
	}
	elsif($action eq 'view_netsuite_account')
	{
		my $id = $self->valid->param('netsuite_id', 'numbers');
		
		$self->write_log(level => 'DEBUG', log => "Redirecting to netsuite account $id");

		if($id)
		{
			return $self->redirect('https://system.netsuite.com/app/common/entity/custjob.nl?id='.$id);
		}
		else
		{
			$self->display_error("Invalid NetSuite ID");
		}
	}
}

sub Core_NetSuite_Search_init_permissions
{
	my $self = shift;

        my $perm = {
                VERSION => 1,
		DESC => 'Search for NetSuite orders or accounts',
		LEVELS => 'r'
        };

        return $perm;
}

sub Core_NetSuite_Search_init_searchable
{
	my $self = shift;
        $self->add_searchable_application('Core.NetSuite_Search', '^(SO-\w+|\d{10,})');
}

1;
