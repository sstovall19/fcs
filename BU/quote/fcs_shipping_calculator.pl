#!/usr/bin/perl

use strict;
use warnings;
use Fap::StateMachine::Unit;
use Fap::Order::Shipping;

my $client = Fap::StateMachine::Unit->new()->run();

sub execute
{
	my ($package, $client, $input) = @_;


	if ($input->{order_id} !~ /(\d+)/)
        {
		$client->displayfailure("order_id is missing or invalid!");
		exit;
        }

	my $shipping = Fap::Order::Shipping->new();
	my ($status) = $shipping->calculate($input->{order_id});
	if ($status != 1) {
		$client->displayfailure("Failure: ". $@);
	}
	return($input);
}

sub rollback
{
	my ($package, $client, $input) = @_;

	if ($input->{order_id} !~ /(\d+)/)
        {
		$client->displayfailure("order_id is missing or invalid!");
		exit;
        }

	my $shipping = Fap::Order::Shipping->new();
	$shipping->zap_order_shipping($input->{order_id});
	$input->{output} = {message=>"Rolled back."};
	return $input;
}
