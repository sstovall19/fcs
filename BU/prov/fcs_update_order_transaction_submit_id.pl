#!/usr/bin/perl

use strict;
use Fap::StateMachine::Unit;
use Fap::Model::Fcs();
use Try::Tiny;
my $client = Fap::StateMachine::Unit->new();
$client->run();
sub execute {
    my ( $class, $client, $input ) = @_;


    if (!$client->{transaction_submit_id}) {
	$client->displayfailure("Missing transaction_submit_id");
    }

    my $order_id = $input->{order_id};
    if ($order_id) { 
	 my $db = Fap::Model::Fcs->new();
	 try {
	 	my $res = $db->table("Order")->search({order_id=>$input->{order_id}})->update({transaction_submit_id=>$client->{transaction_submit_id}});
	 	if (!$res) {
			$client->displayfailure("Unable to update order.");
		}
	} catch {
		$client->displayfailure("$_");
	};
    } else {
	$client->displayfailure("Invalid Order ID");
    }
    return $input;
}

sub rollback {
    my ( $class, $client, $input ) = @_;

    return $input;
}
