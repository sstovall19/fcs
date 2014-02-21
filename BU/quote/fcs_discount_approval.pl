#!/usr/bin/perl

use strict;
use Fap::StateMachine::Unit;
use Fap::Model::Fcs;
use Fap::Order;
use DateTime;
use Digest::MD5;

my $client = Fap::StateMachine::Unit->new();
$client->run();
sub execute {
	my ($class,$client,$input) = @_;

	my $db = Fap::Model::Fcs->new;
	my $order_id=$input->{order_id};
	my $approval_opt=$db->options("OrderStatus");


	if ($order_id) { #this is a modification of an earlier quote

		my $order = Fap::Order->get(db=>$db,id=>$input->{order_id});
		if (!$order) {
			$client->displayfailure("Invalid Order ID");
		}

		my $discount_percent = 0;# $order->discount_percent;
		if ($discount_percent<=0) {
			return $input;
		}
		if ($order->manager_approval_status_id eq $approval_opt->{rejected}) {
			$order->discount_percent(0);
			$order->update();
			return $input;
		}
		if ($discount_percent>$input->{max_discount_percent} && $order->manager_approval_status_id!=$approval_opt->{approved}) {
			$client->displaysuccessHalt($input);
		}
	} else {
		$client->displayfailure("missing Order ID");
	}
	return $input;
}

sub rollback {
	my ($class,$client,$input) = @_;

	return $input;
}
