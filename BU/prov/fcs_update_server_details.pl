#!/usr/bin/perl

use strict;
use warnings;
use Fap::StateMachine::Unit;
use Fap::Server;
use Fap::Customer;
use Fap::Bundle;
use Fap::Order;
use Data::Dumper;

my $client = Fap::StateMachine::Unit->new()->run();

sub execute {
    my ( $package, $client, $input ) = @_;
    my $output = $input;
    my @error;

    #Get details of the order
    my $order_id = $input->{'order_id'};
    my $order = Fap::Order->new('order_id'=>$order_id)->get_details();  
    my $customer_id = $order->{'order'}->{'customer_id'};
    my $customer = Fap::Customer->new( customer_id => $customer_id );
    my @created_server_bundle_id;
    my @added_can_link;

    #Check for server_id validity
    my $customer_server_id = $customer->get_servers();

    if (!Fap::Order::validate_prov_order($customer->{fcs_schema}, $order_id)) {
        $client->displayfailure("ERR: Invalid order: $@");
    }

    #Since there are no errors, we proceed with the server updates
    #Add to server_bundle table
    foreach my $order_group ( @{ $order->{'order'}->{'order_groups'} } ) {

        #If this has server_id then proceed with updates else this is a new one
        if ( my $server_id = $order_group->{'server_id'} ) {
            my $server = Fap::Server->new( server_id => $server_id );
            foreach my $order_bundle ( @{ $order_group->{'order_bundles'} } ) {

                my $bundle_id            = $order_bundle->{'bundle_id'};
                my $new_server_bundle_id = $server->add_bundle($bundle_id);
                if ($new_server_bundle_id) {       
                    my %tmp = ($server_id => $new_server_bundle_id);     
		    if (!defined($output->{'fcs_update_server_details'}->{$server_id}->{'new_server_bundle_ids'})) {
			$output->{'fcs_update_server_details'}->{$server_id}->{'new_server_bundle_ids'} = [];
		    }
                    push (@{$output->{'fcs_update_server_details'}->{$server_id}->{'new_server_bundle_ids'}}, $new_server_bundle_id);
                    #Update Linked Servers
                    my $bundle = Fap::Bundle->new( bundle_id => $bundle_id );
                    if ( $bundle->has_feature_with_name('link') ) {
                        if ( $server->set_can_link_server(1) ) {
                            $output->{'fcs_update_server_details'}->{$server_id}->{'can_link_server'} = 1;
                        }
                    }
                }
            }
            if ( uc( $order->{'order'}->{'order_type'} ) eq 'NEW' ) {
                $output->{'fcs_update_server_details'}->{$server_id}->{'order_type'} = 'NEW';
                #Set timezone and locale
                #Get the right country (using coutry code)
                my $country_code = $order_group->{'shipping_address'}[0]->{'country'};
                my $state_code   = $order_group->{'shipping_address'}[0]->{'state_prov'};
                $server->set_locale( $country_code, $state_code );
            }
        }
    }
    return ($output);
}

sub rollback {
    my ( $package, $client, $input ) = @_;

    foreach my $server_id (keys %{$input->{'fcs_update_server_details'}}) {
         my $server = Fap::Server->new(server_id=>$server_id);
         if (my $server_bundle_ids = $input->{'fcs_update_server_details'}->{$server_id}->{'new_server_bundle_ids'}) {
	     foreach my $sb (@{$server_bundle_ids}) {
             	$server->remove_bundle($sb);
	     }
         }
         if ($input->{'fcs_update_server_details'}->{$server_id}->{'can_link_server'}) {
             $server->set_can_link_server(0);
         }
         if (uc($input->{'fcs_update_server_details'}->{$server_id}->{'order_type'}) eq 'NEW') {
             $server->reset_locale();
         }        
    }
    return ($input);
}

