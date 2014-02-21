#!/usr/bin/perl
#
# Business Unit example
#
#  Notes:
#
#       A sample Business Unit using Fap::StateMachine::Unit.
#
#  Options:
#
#       -r      Rollback.
#
#  Testing:
#
#       Make sure the SM can handle the following
#
#       - Success                                       (no options)
#       - Rollback Success                              -r
#
######
use strict;
use warnings;
use Fap::StateMachine::Unit;
use JSON;
use Fap::Net::Email;
use Fap::Order;
use Fap::Global;

my $client = Fap::StateMachine::Unit->new()->run();

sub execute {

    my ( $package, $client, $input ) = @_;
    my $order_id      = $input->{'order_id'};
    my $order         = Fap::Order->new( 'order_id' => $order_id );
    my $order_details = $order->{'details'};
    my $status_list = Fap::Order->get_status_list();
    #Verify if status of order is not yet PROVISIONED
    if (
        lc( $order_details->{'order'}->{'order_status'}->{'order_status_id'} ) eq $status_list->{'provisioned'} )
    {
        $client->displayfailure( "ERR: Order "
              . $order_details->{'order'}->{'order_id'}
              . " already marked as provisioned: $@" );
    }

    # Mark order as complete
    if ( !$order->set_status('PROVISIONED') ) {
        $client->displayfailure("ERR: Cannot change status for the order: $@");
    }

    # Update netsuite status
    # Send email to provisioning
    if ( !$client->options->{t} ) {
        my $subject = "Complete Order Notification";
        my $msg =
            "Order ID "
          . $input->{'order_id'}
          . " has successfully completed Provisioning Stage";
        Fap::Net::Email->send(
            smtp    => 'mail-relay.fonality.com',
            from    => Fap::Global::kFAILED_EMAIL_FROM(),
            to      => Fap::Global::kPROVISIONING_EMAIL(),
            subject => $subject,
            msg     => $msg,
        );
    }

    return $input;
}

sub rollback {
    my ( $package, $client, $input ) = @_;

    # Reverting order.status
    my $order = Fap::Order->new( order_id => $input->{'order_id'} );
    $order->set_status('PARTIALLY_PROVISIONED');

    #update Netsuite opportunity to have status='in provisioning'

    return $order;
}
