#!/usr/bin/perl
#
# Notify provisioner to connect phones BU
#
#  Notes:
#
#       Notify provisioner to connect phones to download phone configuration
#
#  Options:
#
#       -r      Rollback.
#       -t      Flag as in test mode.
#
##

use strict;
use Fap::StateMachine::Unit;
use Fap::Order;
use Fap::Global;
use Fap::Bundle;
use Fap::Net::Email;

my $client = Fap::StateMachine::Unit->new()->run();

sub execute
{
    my ( $package, $client, $input ) = @_;

    my $order = Fap::Order->new( 'order_id' => $input->{'order_id'} );
    my $order_data = $order->get_details();
    if ( !$order_data )
    {
        $client->displayfailure("ERR: Invalid order: $@");
    }

    my $groups  = $order_data->{'order'}->{'order_groups'};
    my $details = {};
    my $todo    = {};

    # cycle through the order groups and gather all the phones
    foreach my $group (@$groups)
    {

        # check if they have what we are looking for
        foreach my $bundle ( @{ $group->{'order_bundles'} } )
        {

            # create bundle object
            my $bundle_obj = Fap::Bundle->new( bundle_id => $bundle->{'bundle_id'} );
            next if !defined $bundle_obj;

            # gather the phone info if its a phone bundle
            my $data = $bundle_obj->get_phone_info();
            next if !defined $data;

            # gather all the phones that needs to be connected
            foreach my $order_bundle_detail ( @{ $bundle->{'order_bundle_details'} } )
            {
                my $bootfile = Fap::Global::kNFS_MOUNT() . "/" . $group->{'server_id'} . Fap::Global::kPHONE_CONFIG_DIRECTORY();
                $bootfile .= "/" . $order_bundle_detail->{'mac_address'} . "-boot.log";
                next if !has_file_expired($bootfile);

                push( @{ $details->{ $group->{'server_id'} }->{ $data->{'description'} } }, $order_bundle_detail->{'mac_address'} );
            }
        }
    }

    # check if we have something to process
    return $input if scalar( keys %$details ) < 1;

    # notify the provisioning team that the following phones needs to be connected
    my $to = $client->options->{t} ? Fap::Global::kPROVISIONING_EMAIL_TEST() : Fap::Global::kPROVISIONING_EMAIL();
    my $ret = send_notify_email( $to, $order_data->{'order'}->{'order_id'}, $details );
    if ( !$ret )
    {
        $client->displayfailure("ERR: Cannot send notify email: $@");
    }

    # halt all process until the provisioning team has all phones connected
    $client->displaysuccessHalt($input);
}

sub has_file_expired
{
    my $file = shift;

    # does the file even exists
    return 1 if not -e $file;

    # get the files timestamp
    my $file_ts = ( stat($file) )[9];

    # get the systems timestamp
    my $sys_ts = time();

    return ( $sys_ts - $file_ts ) > Fap::Global::kFILE_EXPIRE_AGE() ? 1 : 0;
}

sub send_notify_email
{
    my ( $to, $order_id, $details ) = @_;

    # compose the email content
    my $vars = {
        'ORDER_ID' => $order_id,
        'ORDER'    => $details
    };

    # mail the letter
    return Fap::Net::Email->send_template(
        smtp     => 'mail-relay.fonality.com',
        from     => Fap::Global::kFAILED_EMAIL_FROM(),
        to       => $to,
        template => 'email/Provision/connect_phones.tt',
        type     => 'html',
        vars     => $vars,
        subject  => 'Connect the following phones',
    );
}

sub rollback
{
    my ( $package, $client, $input ) = @_;

    return $input;
}
