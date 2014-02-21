#!/usr/bin/perl

use strict;

sub process_Quote_Discounts
{
	my $self = shift;

	my $action = $self->valid->param('action');

	my $api_user = $self->config('collector.API_USER') || 'dev';
	my $api_key = $self->config('collector.API_KEY') || '0bce4abc80a807e1ef63ac2c05b04af1';

	if($action eq 'load_quote')
	{
	
	}
	elsif($action eq 'update_quote')
	{
	
	}	
}

sub Sales_Quote_Discounts_init_permissions
{
	my $perm = { GLOBAL => 1 };
	return $perm;
}

1;
