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
# #
use strict;
use warnings;
use JSON;
use F::ConfIO;
use F::Server;
use Fap::Customer;
use Fap::Server;
use Fap::Bundle;
use Fap::Order;
use Fap::Provider;
use Fap::Model::Fcs;
use Fap::StateMachine::Unit;
use Data::Dumper;
my $client = Fap::StateMachine::Unit->new()->run();

sub execute
{
    my ( $package, $client, $input ) = @_;
    my $output;
    my @error;

    #Get details of the order
    my $fcs_schema = Fap::Model::Fcs->new();
    my $order_id   = $input->{'order_id'};
    my $order      = Fap::Order->new( 'order_id' => $order_id )->get_details();

    if ( !Fap::Order::validate_prov_order( $fcs_schema, $order_id ) )
    {
        $client->displayfailure($@);
    } else
    {

        #Since there are no errors, we proceed
        my $server;
        my $provider;
        my $voip_flag   = 0;
        my $customer_id = $order->{'order'}->{'customer_id'};
        foreach my $order_group ( @{ $order->{'order'}->{'order_groups'} } )
        {

            #If this has server_id then proceed with updates else this is a new one
            if ( my $server_id = $order_group->{'server_id'} )
            {
                foreach my $order_bundle ( @{ $order_group->{'order_bundles'} } )
                {

                    #Determine the did related orders
                    #Bundle_category.bundle_category_id=8 phonenumber
                    if ( $order_bundle->{'bundle'}->{'category'}->{'bundle_category_id'} == 8 )
                    {
                        if ( !$voip_flag )
                        {

                            #If there are did orders, read sip.conf and check for [FonalityVoIP-xxxx] context
                            my $ioh = F::ConfIO->new( { 'server' => $server_id, 'file' => 'sip.conf' } );
                            my @content = $ioh->read();
                            foreach (@content)
                            {
                                if ( $_ =~ m/\[\s*FonalityVoIP-\d+\s*\]/ )
                                {
                                    $voip_flag = 1;

                                    $server = Fap::Server->new( server_id => $server_id );
                                    my $provider_type = $server->get_attribute('provider_type');

                                    $provider = Fap::Provider->new(
                                        'provider_type' => $provider_type,
                                        'is_test'       => $client->options->{t} ? 1 : undef
                                    );
                                    last;
                                }
                            }

                            if ( !$voip_flag )
                            {
                                $client->displayfailure("ERR: Fonality VoIP Provider not found for server $server_id");
                            }
                        }

                        my @desired_dids;
                        my @desired_lnps;
                        foreach my $order_bundle_detail ( @{ $order_bundle->{'order_bundle_details'} } )
                        {
                            if ( $order_bundle_detail->{is_lnp} == 1 )
                            {
                                push @desired_lnps, $order_bundle_detail->{'desired_did_number'};
                            } else
                            {
                                push @desired_dids, $order_bundle_detail->{'desired_did_number'};
                            }
                        }

                        my $item_id  = $order_bundle->{'bundle_id'};
                        my $item     = Fap::Bundle->new( 'bundle_id' => $item_id );
                        my $did_type = $item->{'details'}->{'name'};

                        if (@desired_dids)
                        {

                            #Purchase the order_bundle
                            my $purchased_dids = $provider->purchase_dids( $server_id, \@desired_dids, $did_type );
                            if ( !$purchased_dids )
                            {
                                $client->displayfailure($@);
                            }
                            
                            #Update database with the new purchased DIDs
                            my $rs = $fcs_schema->table('OrderBundleDetail')->search(
                                {
                                    "order_bundle_id" => $order_bundle->{'order_bundle_id'},
                                    "is_lnp"          => 0
                                }
                            );
                            my $updated_id = {};
                            foreach my $did ( @{$purchased_dids} )
                            {
                                while ( my $order_bundle_detail = $rs->next )
                                {
                                    my $desired_did            = $order_bundle_detail->get_column('desired_did_number');
                                    my $order_bundle_detail_id = $order_bundle_detail->get_column('order_bundle_detail_id');
                                    
                                    next if not defined $desired_did;

                                    #Compose the DID pattern based on the desired DID input
                                    my $desired_did_pattern = $desired_did =~ /^0(\d+)/ ? "^\\d{0,3}$1" : "^\\d{0,1}$desired_did";

                                    if ( defined $desired_did && $did =~ /^$desired_did_pattern/ && ( !( $updated_id->{$order_bundle_detail_id} ) ) )
                                    {
                                        $order_bundle_detail->update( { 'did_number' => $did } );
                                        $updated_id->{$order_bundle_detail_id} = 1;
                                        last;
                                    }
                                }
                            }
                            #Verify if # of updated id = # of orders
                            if (scalar(keys %{$updated_id}) < scalar(@desired_dids))
                            {
                                #Check and update possible temporary numbers
                                
                                $client->displayfailure("Err: Unable to updates order bundle detail for DIDs");
                            }
                        }

                        if (@desired_lnps)
                        {

                            #Purchase the lnp order_bundle
                            my $purchased_lnps = $provider->process_lnps( $server_id, \@desired_lnps, $did_type );
                            if ( !$purchased_lnps )
                            {
                                $client->displayfailure($@);
                            }

                            #Update database with the new LNPs
                            my $rs = $fcs_schema->table('OrderBundleDetail')->search(
                                {
                                    "order_bundle_id" => $order_bundle->{'order_bundle_id'},
                                    "is_lnp"          => 1
                                }
                            );
                            my $updated_id = {};
                            foreach my $did ( @{$purchased_lnps} )
                            {
                                while ( my $order_bundle_detail = $rs->next )
                                {
                                    my $desired_did            = $order_bundle_detail->get_column('desired_did_number');
                                    my $order_bundle_detail_id = $order_bundle_detail->get_column('order_bundle_detail_id');
                                    
                                    next if not defined $desired_did;

                                    #Compose the DID pattern based on the desired DID input
                                    $desired_did = $desired_did =~ /^0(\d+)/ ? "^\\d{0,3}$1" : "^$desired_did";
                                    
                                    if ( defined $desired_did && $did =~ /$desired_did/ && ( !( $updated_id->{$order_bundle_detail_id} ) ) )
                                    {
                                        $order_bundle_detail->update( { 'did_number' => $did } );
                                        $updated_id->{$order_bundle_detail_id} = 1;
                                        last;
                                    }
                                }
                            }
                            if (scalar(keys %{$updated_id}) < 1)
                            {
                                $client->displayfailure("Err: Unable to updates order bundle detail for LNPs");
                            }
                        }
                    }
                }
            }
        }
        return $input;
    }
}

sub rollback
{
    my ( $package, $client, $input ) = @_;
    my $order_id   = $input->{'order_id'};
    my $fcs_schema = Fap::Model::Fcs->new();
    my $order      = Fap::Order->new( order_id => $order_id )->get_details();

    #Iterate through order bundles with did numbers
    foreach my $order_group ( @{ $order->{order}->{order_groups} } )
    {
        my $server_id     = $order_group->{server_id};
        my $server        = Fap::Server->new( server_id => $server_id );
        my $provider_type = $server->get_attribute('provider_type');

        my $provider = Fap::Provider->new(
            'provider_type' => $provider_type,
            'is_test'       => $client->options->{t} ? 1 : undef
        );

        foreach my $order_bundle ( @{ $order_group->{order_bundles} } )
        {
            my @dids_to_delete;
            my @lnps_to_delete;

            foreach my $order_bundle_detail ( @{ $order_bundle->{order_bundle_details} } )
            {
                my $did = $order_bundle_detail->{'did_number'};
                if ($did)
                {
                    $fcs_schema->table('OrderBundleDetail')->single( { order_bundle_id => $order_bundle->{order_bundle_id}, did_number => $did } )->update( { 'did_number' => undef } );

                    if ( $order_bundle_detail->{is_lnp} == 1 )
                    {
                        push @lnps_to_delete, $order_bundle_detail->{'did_number'};
                    } else
                    {
                        push @dids_to_delete, $order_bundle_detail->{'did_number'};
                    }
                }
            }

            if (@dids_to_delete)
            {
                my $deleted_dids = $provider->delete_dids( $server_id, \@dids_to_delete );
                if ( !$deleted_dids )
                {
                    $client->displayfailure($@);
                }
            }

            if (@lnps_to_delete)
            {
                my $deleted_lnps = $provider->cancel_lnps( $server_id, \@lnps_to_delete );
                if ( !$deleted_lnps )
                {
                    $client->displayfailure($@);
                }
            }
        }
    }
    return $input;
}

1;
