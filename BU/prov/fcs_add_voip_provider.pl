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

use Fap::StateMachine::Unit;
use Fap::Order;
use Fap::Bundle;
use Fap::Server;
use Fap::Provider;
use Fap::Country;

my $client = Fap::StateMachine::Unit->new()->run();

sub execute {
    my ($package, $client, $input) = @_;

    my $order = Fap::Order->new('order_id' => $input->{'order_id'});
    my $order_data = $order->get_details();
    unless ($order_data)
    {
        $client->displayfailure("ERR: Invalid order: $@");
    }
    
    foreach my $group (@{$order_data->{'order'}->{'order_groups'}}) 
    {
        my $serv = Fap::Server->new('server_id' => $group->{'server_id'});
        
        # does this server already have a voip provider
        next if $serv->{'details'}->{'provider_type'};
        
        # what VoIP provider are we looking for base on the shipping address
        my $provider = undef;
        my $country = Fap::Country->new('alpha_code' => $group->{'shipping_address'}->[0]->{'country'});
        my $providers = $country->get_voip_provider();
        if (not $providers)
        {
            # oopss... unable to determine any provider
            $client->displayfailure("ERR: No VoIP Provider for choosen country: $@");
        }
        # here are the possible provider candidate on this country
        foreach my $voip (@{$providers})
        {
            my $voip_bundle = Fap::Bundle::get_bundle_with_name($voip);
            # is there a VoIP bundle of this provider in this group
            if (grep {$_->{'bundle_id'} == $voip_bundle->{'bundle_id'}} @{$group->{'order_bundles'}})
            {
                $provider = $voip;
                # time to exits this providers loop
                last;
            }
        }    
        
        # skip and proceed to next order group since this doesn't need VoIP 
        next unless $provider;
                
        # start processing
        my $prov = Fap::Provider->new(
            'is_test'       => $client->options->{t} ? 1 : undef,
            'provider_type' => $provider
        );
        $client->displayfailure("ERR: Cannot instantiate Fap::Provider: $@") if !defined($prov);
        
        my $inserts = {'server_id' => $group->{'server_id'}, 'added_voip_provider' => $provider};
        
        $inserts->{'added_voip_sip'} = $prov->create_account($group->{'server_id'});
        
        # attached this data to our json
        $input->{'added_provider'}->{$group->{'order_group_id'}} = $inserts;
        $client->displayfailure("ERR: Cannot register with provider: $@") if !defined($inserts->{'added_voip_sip'});
    }
    
    return $input;
}


sub rollback {
    my ($package, $client, $input) = @_;
    
    return $input if not $input->{'added_provider'};

    my $order = Fap::Order->new('order_id' => $input->{'order_id'});
    my $order_data = $order->get_details();
    unless ($order_data)
    {
        $client->displayfailure("ERR: Invalid order: $@");
    }
    
    # Safety measure, make sure that the items being rolled back are valid ones
    foreach my $group (@{$order_data->{'order'}->{'order_groups'}}) 
    {
        next if not $input->{'added_provider'}->{$group->{'order_group_id'}};
        my $rb_data = $input->{'added_provider'}->{$group->{'order_group_id'}};
        next if !$rb_data->{'added_voip_sip'};
        
        my $prov = Fap::Provider->new(
            'is_test'       => $client->options->{t} ? 1 : undef,
            'provider_type' => $rb_data->{'added_voip_provider'}
        );
        
	my $success = $prov->delete_account($group->{'server_id'});
	$client->displayfailure("ERR: Cannot purge account: $@") if not $success;
		
        delete($input->{'added_provider'}->{$group->{'order_group_id'}});
    }
    delete($input->{'added_provider'});

    return $input;
}
