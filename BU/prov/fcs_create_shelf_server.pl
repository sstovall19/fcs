#!/usr/bin/perl
#
# Add Fonality VoIP provider
#
#  Notes:
#
#        Adds Fonality VoIP provider based on an order
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
use Fap::User;
use Fap::Server;
use Fap::Provision::Server;

my $client = Fap::StateMachine::Unit->new()->run();

sub execute {
    my ($package, $client, $input) = @_;

    my $order = Fap::Order->new('order_id' => $input->{'order_id'});
    my $order_data = $order->get_details();
    unless ($order_data->{order}->{order_id})
    {
        $client->displayfailure('ERR: Invalid order id');
    }
    
    # return if this is not a new server order
    return $input if lc($order_data->{'order'}->{'order_type'}) ne 'new';
    
    foreach my $group (@{$order_data->{'order'}->{'order_groups'}}) 
    {
        # make sure that the server id is not yet defined
        if ($group->{'server_id'}) 
        {
            $client->displayfailure('ERR: Server ID already defined');
        }
        
        # make sure that the product id is defined
        if (not $group->{'product_id'}) 
        {
            $client->displayfailure('ERR: Product ID is not defined');
        }
        
        # skip the product deployment is not software
        next if lc($group->{'product'}->{'deployment'}->{'name'}) eq 'software';
        
        my $server = Fap::Provision::Server->new(
            'product'  => $group->{'product'},
            'dest_add' => shift(@{$group->{'shipping_address'}}),
            'cust_id'  => $order_data->{'order'}->{'customer_id'},
            'host'     => $client->options->{t} ? '5559' : undef,
            'mode'     => $client->options->{t} ? 'test' : undef
        );
	print STDERR $@;
        
        # create the entry for the server info in the database
        if ($server->insert_basic_details())
        {
            Fap::Order::associate_server_id_to_order_group_id($group->{'order_group_id'},$server->{'serv_info'}->{'server_id'});
        }
        else        
        {
            $client->displayfailure("ERR: Cannot insert basic details: $@");
        }
        
        # setup the v-tunnels
        if (not $server->setup_tunnel())
        {
            $client->displayfailure("ERR: Cannot setup virtual tunnel: $@");
        }
        
        # setup asterisk
        if (not $server->install_asterisk())
        {
            $client->displayfailure("ERR: Cannot install asterisk: $@");
        }
        
        # setup the necessary conf files
        if (not $server->create_conf())
        {
            $client->displayfailure("ERR: Cannot create necessary conf files: $@");
        }
        
        # setup the audio such as moh and the likes
        if (not $server->add_audio_group('initial'))
        {
            $client->displayfailure("ERR: Cannot add default audio: $@");
        }
        
        # time to sync up before we proceed any futher
        if (not $server->sync_files_to_server())
        {
            $client->displayfailure("ERR: Cannot sync files to server: $@");
        }
        
        # define the basic roles
        if (not $server->add_basic_roles())
        {
            Fap->trace_error($@);
            $client->displayfailure("ERR: Cannot add basic roles: $@");
        }
        
        # setup the CDR
        if (not $server->create_cdr())
        {
            $client->displayfailure("ERR: Cannot create CDR table: $@");
        }

	# create /dev/null device
	if (not $server->create_virt_device())
	{
	    $client->displayfailure("ERR: Cannot create virtual device: $@");
	}

        # lastly create the server admin 
        if (not Fap::User::create_admin($server->{'serv_info'}->{'server_id'}))
        {
            $client->displayfailure("ERR: Cannot create admin user: $@");
        }
    }
    
    return $input;
}

sub rollback {
    my ($package, $client, $input) = @_;
    
    my $order = Fap::Order->new('order_id' => $input->{'order_id'});
    my $order_data = $order->get_details();
    unless ($order_data)
    {
        $client->displayfailure("ERR: Invalid order id");
    }

    foreach my $group (@{$order_data->{'order'}->{'order_groups'}}) 
    {
        # was there a server defined
        next unless $group->{'server_id'};
        
        # skip the product deployment is not software
        next if lc($group->{'product'}->{'deployment'}->{'name'}) eq 'software';
            
        my $serv = Fap::Server->new('server_id' => $group->{'server_id'});
        
        next if not $serv->{'details'}->{'server_id'};
        
        # lets deprovision this server
        my $server = Fap::Provision::Server->new(
            'server_id' => $serv->{'details'}->{'server_id'},
            'product'  => $group->{'product'},
            'dest_add' => shift(@{$group->{'shipping_address'}}),
            'cust_id'  => $order_data->{'order'}->{'customer_id'},
        );
        
        # remove the server_admin
        Fap::User::purge_admin($serv->{'details'}->{'server_id'});
        
        # strip the role
        if (not $server->delete_roles())
        {
            $client->displayfailure("ERR: Cannot delete roles: $@");
        }
        
        # purge all audio
        if ( not $server->remove_audio())
        {
            $client->displayfailure("ERR: Cannot remove all audio: $@");
        }
        
        # purge all conf files both local and remote
        if (not $server->purge_conf())
        {
            $client->displayfailure("ERR: Cannot purge all conf files: $@");
        }
        
        # close the tunnel
        if (not $server->close_tunnel())
        {
            $client->displayfailure("ERR: Cannot close the tunnels: $@");
        }

	# remove devices
	if (not $server->remove_virt_device())
	{
	    $client->displayfailure("ERR: Cannot remove devices: $@");
	}
        
        # remove this server from existance
        if ($server->drop_server())
        {
            Fap::Order::reset_server_id_of_order_group_id($group->{'order_group_id'});
        }
        else
        {
            $client->displayfailure("ERR: Cannot drop server: $@");
        }
    }
    
    return $input;    
}
