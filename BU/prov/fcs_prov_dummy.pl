#!/usr/bin/perl

use strict;
use Fap::StateMachine::Unit;
use Fap::Order;

my $client = Fap::StateMachine::Unit->new()->run();

sub execute {
	my ($package, $client, $input) = @_;
	
	my $fcs_schema = Fap::Model::Fcs->new();

	if (!Fap::Order::validate_prov_order($fcs_schema, $input->{'order_id'})) {
		$client->displayfailure("ERR: Invalid order: $@");
	}

	return $input;
}

sub rollback {
	my ($package, $client, $input) = @_;
	
	my $fcs_schema = Fap::Model::Fcs->new();

	if (!Fap::Order::validate_prov_order($fcs_schema, $input->{'order_id'})) {
		$client->displayfailure("ERR: Invalid order: $@");
	}

	return $input;
}
