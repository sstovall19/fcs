#!/usr/bin/perl
#
# Add HUD
#
#  Notes:
#
#       Add HUD to a server based on an order
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
use Fap::Server;
use Fap::Util;
use Fap::HUD;

my $client = Fap::StateMachine::Unit->new()->run();

sub execute {
    my ($package,$client,$input) = @_;
    $input->{'HUD_added'} = [];

    my $order = Fap::Order->new('order_id' => $input->{'order_id'});
    my $order_data = $order->get_details();
    if (!$order_data)
    {
        $client->displayfailure("ERR: Invalid order: $@");
    }
    
    # cycle through the order groups
    foreach my $group (@{$order_data->{'order'}->{'order_groups'}}) 
    {
        # gather some info about the server
        my $server = Fap::Server->new('server_id' => $group->{'server_id'});
        my $deployment =  $server->{'details'}->{'deployment'};
        
        # oops its already installed next server please
        next if $server->{'details'}->{'has_hud'} && $server->{'details'}->{'has_hud'} !~ /^\s+$/;
        
        # begin installing HUD
        $server->set_hud_pw(Fap::Util::return_random_string(6));
        
        $client->displayfailure("ERR: Cannot set hud password: $@") if $@;
            
        my $version = Fap::HUD::get_current_hud_policy('type' => $deployment->{'is_hosted'} ? 'connect' : 'premise');
        
        if (!$version)
        {
            $client->displayfailure("ERR: Unable to get current HUD policy: $@")
        }    
        
        # mark that this server has HUD enabled
        push(@{$input->{'HUD_added'}}, $group->{'server_id'});
        
        Fap::HUD::set_hud_variable(
            'config_file' => 'server.properties', 
            'server_id'   => $group->{'server_id'}, 
            'type'        => 'instance.serverId', 
            'hostname'    => "s" . $group->{'server_id'} . ".pbxtra.fonality.com"
        );
        
        $client->displayfailure("ERR: Cannot set hud hostname: $@") if $@;
                
        # setting up HUD policy
        Fap::HUD::set_server_policy('server_id' => $group->{'server_id'}, 'policy' => $version);
        
        $client->displayfailure("ERR: Cannot set server policy: $@") if $@;
        
        # set HUD to be enabled for the server
        if (not Fap::HUD::set_hud_enabled('server_id' => $group->{'server_id'}, 'enabled' => 1))
        {
            $client->displayfailure("ERR: Could not enabled HUD on pbxtra " . $group->{'server_id'}. ": $@");
        }                
    }
    
    return $input;
}

sub rollback {
    my ($package,$client,$input) = @_;

    my $order = Fap::Order->new('order_id' => $input->{'order_id'});
    my $order_data = $order->get_details();
    if (!$order_data)
    {
        $client->displayfailure("ERR: Invalid order: $@");
    }
    
    if (exists $input->{'HUD_added'} && $input->{'HUD_added'}) 
    {
        foreach my $server_id (@{$input->{'HUD_added'}}) 
        {
            my $server = Fap::Server->new('server_id' => $server_id);
            
            # remove the has_hud password
            $server->set_hud_pw(undef);
        
            $client->displayfailure("ERR: Cannot remove hud password: $@") if $@;

            Fap::HUD::set_hud_variable(
                'config_file' => 'server.properties', 
                'server_id'   => $server_id, 
                'type'        => 'instance.serverId', 
                'hostname'    => undef
            );

            $client->displayfailure("ERR: Cannot remove hud hostname: $@") if $@;
        
            # revert HUD policy
            Fap::HUD::set_server_policy('server_id' => $server_id, 'policy' => undef);
        
            $client->displayfailure("ERR: Cannot remove server policy: $@") if $@;

            # disable hud on the server
            Fap::HUD::set_hud_enabled('server_id' => $server_id, 'enabled' => 0);
        
            $client->displayfailure("ERR: Could not disable HUD on pbxtra $server_id: $@") if $@;
        }    
    }
    
    return $input;
}
