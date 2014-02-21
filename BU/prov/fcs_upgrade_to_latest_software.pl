#!/usr/bin/perl
#
# Upgrade to latest software BU
#
#  Notes:
#
#       Upgrade specified server to the latest software version
#
#  Options:
#
#       -r      Rollback.
#       -t      Flag as in test mode.
#
# #

use strict;
use Fap::StateMachine::Unit;
use Fap::Order;
use Fap::Global;
use Fap::Server;
use Fap::Util;
use Fap::Upgrade;
use Fap::Net::Email;

my $client = Fap::StateMachine::Unit->new()->run();

sub execute
{
    my ( $package, $client, $input ) = @_;

    my $order = Fap::Order->new( 'order_id' => $input->{'order_id'} );
    my $order_data = $order->get_details();
    unless ($order_data)
    {
        $client->displayfailure("ERR: Invalid order: $@");
    }

    # if its an addon no need to upgrade the server
    if ( lc( $order_data->{'order'}->{'order_type'} ) eq 'addon' )
    {
        return $input;
    }

    my $done = {};
    my $todo = {};

    # Get all the servers for the order
    foreach my $group ( @{ $order_data->{'order'}->{'order_groups'} } )
    {
        if ( defined( $group->{'server_id'} ) && $group->{'server_id'} =~ /^\d+$/ )
        {
            $todo->{ $group->{'server_id'} } = 1;
        }
    }

    foreach my $server_id ( keys %$todo )
    {

        # skip if we have already done this server
        next if exists( $done->{$server_id} );

        # gather some info about the server
        my $server = Fap::Server->new( 'server_id' => $server_id );

        # start upgrading this server
        if ( $server->{'details'}->{'deployment'}->{'is_hosted'} )
        {

            # have we checked this host before
            if ( !exists( $done->{ $server->{'details'}->{'mosted'} } ) )
            {

                # get the server info of the host server
                my $host = Fap::Server->new( 'server_id' => $server->{'details'}->{'mosted'} );

                # is this host already updated
                if ( Fap::Util::version_compare( $host->{'details'}->{'cp_version'}, '<', Fap::Global::kCP_VERSION() ) )
                {
                    $done->{ $server->{'details'}->{'mosted'} } = 0;

                    # oooppss! send an email to systeam for them upgrade
                    # this server but please don't spam them.
                    my $to = $client->options->{t} ? Fap::Global::kSYSTEAMS_EMAIL_TEST() : Fap::Global::kSYSTEAMS_EMAIL();
                    send_email(
                        'recipient' => $to,
                        'server_id' => $server_id,
                    );

                    # halt all process until systeam has decided to upgrade the
                    # host server or take another course of action on the problem
                    $client->displaysuccessHalt($input);
                }

                # host server is up to date
                else
                {
                    $done->{ $server->{'details'}->{'mosted'} } = 1;
                }
            }

            # do we have an up to date host
            if ( $done->{ $server->{'details'}->{'mosted'} } )
            {
                if ( Fap::Util::version_compare( $server->{'details'}->{'cp_version'}, '<', Fap::Global::kCP_VERSION() ) )
                {

                    # guest is not updated, so we update it
                    Fap::Upgrade::upgrade_guest_batch( 'server_id' => $server_id );
                }
            }
        } else
        {
            if ( Fap::Util::version_compare( $server->{'details'}->{'cp_version'}, '<', Fap::Global::kCP_VERSION() ) )
            {
                Fap::Upgrade::insert_upgrade_batch( 'server_id' => $server_id, 'version' => Fap::Global::kCP_VERSION() );

                # notify provisioning that they can now run the upgrades through cp
                my $to = $client->options->{t} ? Fap::Global::kPROVISIONING_EMAIL_TEST() : Fap::Global::kPROVISIONING_EMAIL();
                send_email(
                    'recipient' => $to,
                    'server_id' => $server_id,
                    'success'   => 1
                );

                # halt all process until the provisioning team is done updating the server via the CP
                $client->displaysuccessHalt($input);
            }
        }

        # mark that we've already done this server
        $done->{$server_id} = 1;

        # stop if any errors are found
        $client->displayfailure("ERR: Cannot upgrade to latest software: $@") if $@;
    }

    return $input;
}

=head2 send_email

=over 4

Sends out an email

   Args: sent_to, server id, success

=back

=cut

##############################################################################
# send_email
##############################################################################
sub send_email
{
    my %params = @_;
    my $time   = CORE::localtime();

    # compose the email content
    my $subject = "Server " . $params{'server_id'} . " is now ready be upgraded since ";

    if ( not $params{'success'} )
    {
        $subject = 'Failed Upgrade for server ' . $params{'server_id'} . ' at ';
    }

    $subject .= "$time";

    # compose the email content
    my $vars = {
        'SERVER_ID' => $params{'server_id'},
        'SUCCESS'   => $params{'success'} ? 1 : 0
    };

    # mail the letter
    return Fap::Net::Email->send_template(
        smtp     => 'mail-relay.fonality.com',
        from     => Fap::Global::kFAILED_EMAIL_FROM(),
        to       => $params{'recipient'},
        template => 'email/Provision/upgrade_to_latest_software.tt',
        type     => 'html',
        vars     => $vars,
        subject  => $subject,
    );
}

sub rollback
{
    my ( $package, $client, $input ) = @_;

    return $input;
}
