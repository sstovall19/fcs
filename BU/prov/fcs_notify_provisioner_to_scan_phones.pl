#!/usr/bin/perl
#
# Notify provisioner to scan phones BU
#
#  Notes:
#
# 	Notifies provisioner to scan phones
#
#  Options:
#
#	-r	Rollback
#	-t	Test mode
#
# #

use strict;
use Fap::StateMachine::Unit;
use Fap::Order;
use Fap::Model::Fcs;
use Fap::Provision;

my $client = Fap::StateMachine::Unit->new()->run();

sub execute
{
    my ( $package, $client, $input ) = @_;

    my $fcs_schema = Fap::Model::Fcs->new();

    if ( !Fap::Order::validate_prov_order( $fcs_schema, $input->{'order_id'} ) )
    {
        $client->displayfailure("ERR: Invalid order: $@");
    }

    my $phone_details = Fap::Provision::get_phone_details( $fcs_schema, $input->{'order_id'} );
    if ( !defined($phone_details) )
    {
        $client->displayfailure("ERR: Cannot get phone details: $@");
    }

    # check if we have something to process
    return $input unless scalar( keys %$phone_details ) > 0;

    my $scanned_phones = Fap::Provision::get_scanned_phones( $fcs_schema, $input->{'order_id'} );
    if ( !defined($scanned_phones) )
    {
        $client->displayfailure("ERR: Cannot get scanned phones: $@");
    }

    # Check if all phones have been scanned
    my $scanned_phones_total = Fap::Provision::get_phones_total($scanned_phones);
    if ( !defined($scanned_phones_total) )
    {
        $client->displayfailure("ERR: Cannot get phones total for scanned phones: $@");
    }

    my $ordered_phones_total = Fap::Provision::get_phones_total($phone_details);
    if ( !defined($ordered_phones_total) )
    {
        $client->displayfailure("ERR: Cannot get phones total for phone details: $@");
    }

    if ( $scanned_phones_total > $ordered_phones_total )
    {
        $client->displayfailure("ERR: the number of scanned phones is bigger than ordered: $@");
    } elsif ( $scanned_phones_total < $ordered_phones_total )
    {

        # notify the provisioning team that the following phones needs to be scanned
        my $leftover_phones = Fap::Provision::get_phones_to_scan( $phone_details, $scanned_phones );
        if ( !defined($leftover_phones) )
        {
            $client->displayfailure("ERR: Cannot get leftover phones: $@");
        }

        my $to = $client->options->{t} ? Fap::Global::kPROVISIONING_EMAIL_TEST() : Fap::Global::kPROVISIONING_EMAIL();
        my $ret = send_notify_email( $to, $input->{'order_id'}, $leftover_phones, $client->transaction_id );
        if ( !$ret )
        {
            $client->displayfailure("ERR: Cannot send notify email: $@");
        }

        # halt all process until the provisioning team has all phones scanned
        $client->displaysuccessHalt($input);
    }

    return $input;
}

sub send_notify_email
{
    my ( $to, $order_id, $details, $transaction_submit_id ) = @_;

    my $conf = Fap->load_conf("provisioning");

    # compose the email content
    my $vars = {
        'ORDER_ID' => $order_id,
        'ORDER'    => $details,
        'URL'      => $conf->{scan_phones_url} . "&action=get_order_id&order_id=$order_id&$transaction_submit_id"
    };

    # mail the letter
    return Fap::Net::Email->send_template(
        smtp     => 'mail-relay.fonality.com',
        from     => Fap::Global::kFAILED_EMAIL_FROM(),
        to       => $to,
        template => 'email/Provision/scan_phones.tt',
        type     => 'html',
        vars     => $vars,
        subject  => 'Connect the following phones',
    );
}

sub rollback
{
    my ( $package, $client, $input ) = @_;

    my $fcs_schema = Fap::Model::Fcs->new();

    if ( !Fap::Order::validate_prov_order( $fcs_schema, $input->{'order_id'} ) )
    {
        $client->displayfailure("ERR: Invalid order: $@");
    }

    return $input;
}

