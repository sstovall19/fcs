#!/usr/bin/perl

use strict;
use warnings;
use Fap::Model::Fcs;
use Fap::Order;
use Fap::StateMachine::Unit;
use JSON;
use F::Conference;

use constant VIRT_CONFERENCE => "virtual_conference_bridge";
my $client = Fap::StateMachine::Unit->new()->run();

sub execute {

    my ( $package, $client, $input ) = @_;
    my $output = $input;
    my @error;
    my $fcs_schema    = Fap::Model::Fcs->new();        

    #Get bundle_id of additional conference bridge
    my $conference_bundle =
      $fcs_schema->table('bundle')
      ->single( { 'lower(name)' => VIRT_CONFERENCE } );

    if ( not defined($conference_bundle) ) {
        $client->displayfailure(
            "Conference Bundle " . VIRT_CONFERENCE . " not found: $@" );
    }

    #Get details of the order
    my $order_id = $input->{'order_id'};
    my $order = Fap::Order->new('order_id'=>$order_id)->get_details();

    if (!Fap::Order::validate_prov_order($fcs_schema, $order_id)) {
        $client->displayfailure("ERR: Invalid order: $@");
    }

#Proceed with adding conference bridge.  Iterate through order_group
    foreach my $order_group ( @{ $order->{'order'}->{'order_groups'} } ) {

        #Iterate and process order bundles for this order_group/ server_id
        foreach my $order_bundle ( @{ $order_group->{'order_bundles'} } ) {
            if ( $order_bundle->{'bundle_id'} == $conference_bundle->bundle_id )
            {
                my $server_id = $order_group->{'server_id'};
                my $conf_obj = F::Conference->new(
                    { server => $server_id } );
                my @array_conf;
                for ( my $i = 0 ; $i < $order_bundle->{'quantity'} ; $i++ ) {
                    my ( $index, $extension ) = $conf_obj->add_conf();
                    if ($@) {
                        $client->displayfailure("ERR: Cannot add conference bridge: $@");
                    }
                    else {
                        my %hash_conf =
                          ( index => $index, extension => $extension );
                        push( @array_conf, \%hash_conf );
                    }
                }
                $conf_obj->commit();
                if ($@) {
                    $client->displayfailure("ERR: Cannot commit changes to conference bridges: $@");
                }
                else {
                    $output->{'fcs_add_conference_bridge'}->{$server_id}->{'added_conference_bridges'} = \@array_conf;
                }
            }
        }
    }
    return $output;
}

sub rollback {
    my ( $package, $client, $input ) = @_;

    foreach my $server_id (keys %{$input->{'fcs_add_conference_bridge'}}) {
         my $conf_obj =
              F::Conference->new( { server => $server_id } );
         if ( $input->{'fcs_add_conference_bridge'}->{$server_id}->{'added_conference_bridges'} ) {
                foreach ( @{ $input->{'fcs_add_conference_bridge'}->{$server_id}->{'added_conference_bridges'} } ) {
                    $conf_obj->remove_conf( $_->{'index'} );
                    if ($@) {
                        $client->displayfailure("ERR: Cannot remove conference bridge: $@");
                    }
                }
                $conf_obj->commit();
                if ($@) {
                    $client->displayfailure("ERR: Cannot commit changes to conference bridges: $@");
                }
         }
    }
    return $input;
}
