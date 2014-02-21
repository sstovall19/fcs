#!/usr/bin/perl
use strict;
use warnings;
use Fap::StateMachine::Unit;
use Fap::StateMachine::Client;
use Fap::StateMachine;
use Fap::Order::Convert;

my $client = Fap::StateMachine::Unit->new()->run();

sub execute {
    my ($package, $client, $input) = @_;
    my $fcs_schema = Fap::Model::Fcs->new();
    my $testmode = $client->options->{t} ? 'test' : undef;

    # Before we do anything, validate the order.   Skip this for testing.
    if ( ( !$testmode) && (! Fap::Order::validate_prov_order($fcs_schema, $input->{'order_id'}, { skip_server_id=>1 }))) {
      $client->displayfailure($@);
    }

    my $convert = Fap::Order::Convert->new('fcs_schema' => $fcs_schema, 'order_id' => $input->{'order_id'} );
    if (!$convert) {
        $client->displayfailure($@);
    }

    # Convert to an ORDER.
    if (! $convert->convert_record('ORDER')) {
      $client->displayfailure($@);
    }

    # Copy the relevant information from FCS into the pbxtra.customer table.
    if(! $convert->create_pbxtra($input)) {
        $client->displayfailure($@);
    }

    # Create the PROV SM job.

    if (!$testmode) {
        my $sm = new Fap::StateMachine::Client;
        if(! $sm->submit_and_run_transaction('PROV', $client->serialize($input))->{status}) {
            Fap->trace_error("Could not create PROV state machine job.");
            $client->displayfailure($@);
        }
    }

    return($input);
}

sub rollback {
    my ($package, $client, $input) = @_;
    my $fcs_schema = Fap::Model::Fcs->new();
    my $testmode = $client->options->{t} ? 'test' : undef;

    my $convert = Fap::Order::Convert->new('fcs_schema' => $fcs_schema, 'order_id' => $input->{'order_id'} );
    if (!$convert) {
        $client->displayfailure($@);
    }

    # Per discussion with Luke and Michael, we DO NOT roll out the SM PROV job.

    # Convert the ORDER back to a QUOTE.
    $convert->convert_record('QUOTE');

    # If the pbxtra.customer has no pbxtra.server.server_id associated, this will drop
    #  the pbxtra.customer entry, and remove the fcs.orders.customer_id.
    $convert->drop_abandoned_customer();

    return($input);
}
