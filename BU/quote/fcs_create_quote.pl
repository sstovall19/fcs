#!/usr/bin/perl

use strict;
#use Fap::StateMachine::Unit();
use Fap::StateMachine::Unit;
use Fap::Model::Fcs();
use Fap::Order::Discounts;
use DateTime();
use Digest::MD5();

#my $client = Fap::StateMachine::Unit->new();
my $client = Fap::StateMachine::Unit->new();
$client->run();

sub execute 
{
    my ( $class, $client, $input ) = @_;


    my $db = Fap::Model::Fcs->new();
    my ( $contact, $order );

    if (!$input || ref $input ne 'HASH') 
    {
        $client->displayfailure("Missing or invalid input.");
    }

    my $order_id = $input->{order_id};
    $input = Fap::Order::Discounts->calculate_all(db=>$db,order_json=>$input);

    if ($order_id) {    # this is a modification of an earlier quote
        $order = $db->table("Order")->search( { "me.order_id" => $input->{order_id} }, { prefetch => "order_groups" } )->first;
        $contact = $db->table("EntityContact")->single( { entity_contact_id => $order->contact_id } );
        $contact->set_columns( {
            first_name => $input->{contact}->{first_name},
            last_name  => $input->{contact}->{last_name},
            email      => $input->{contact}->{email},
            phone      => $input->{contact}->{phone},
        } );
        $contact->update();
        $order->set_columns( {
            updated                 => DateTime->now( time_zone => "America/Los_Angeles" )->strftime("%F %H:%M:%S"),
            company_name            => $input->{contact}->{company_name},
            industry                => $input->{contact}->{industry},
            website                 => $input->{contact}->{website},
            transaction_submit_id   => $client->{transaction_submit_id},
        } );
        my $nlids = [];
        foreach my $group ( $order->order_groups ) 
        {
            push( @$nlids, $group->netsuite_id ) if ( $group->netsuite_id );
            $group->delete;
        }
        $input->{netsuite_lead_ids} = $nlids if ( scalar(@$nlids) );
    } 
    else 
    {
        $contact = $db->table("EntityContact")->find_or_create( {
            role        => "admin",
            first_name  => $input->{contact}->{first_name},
            last_name   => $input->{contact}->{last_name},
            email       => $input->{contact}->{email},
            phone       => $input->{contact}->{phone},
        } );
        $order = $db->table("Order")->create( {
            reseller_id                 => $input->{reseller_id},
            record_type                 => "QUOTE",
            contact_id                  => $contact->entity_contact_id,
            company_name                => $input->{contact}->{company_name},
            industry                    => $input->{contact}->{industry},
            website                     => $input->{contact}->{website},
            #discount_percent           => abs($input->{discount_percent} + 0),
            #manager_approval_status_id =>($input->{discount_percent}>0)?$db->options("OrderStatus")->{pending}:$db->options("OrderStatus")->{not_required},
            netsuite_lead_id            => $input->{netsuite_lead_id}||0,
            prepay_amount               => $input->{prepay_amount}||0,
            term_in_months              => $input->{term_in_months}||0,
            order_creator_id            => $input->{user_id},
            order_status_id             => $db->options("OrderStatus")->{new},
            transaction_submit_id       => $client->{transaction_submit_id},
        } );
        $order_id = $order->order_id;
    }

    my $addressbook = {};
    my $order_price = 0;
    my $order_mrc=0;

    my $has_primary=0;
    foreach my $group ( @{ $input->{order_group} } ) 
    {
        my $address_id = process_address( $addressbook, $group->{shipping}, $db );
        my $ordergroup = $db->table("OrderGroup")->create( {
            order_id            => $order->order_id,
            shipping_address_id => $address_id,
            product_id          => $group->{product_id},
            is_primary          => (!$has_primary) ? 1 : 0,
        } );

        $has_primary=1;
        my $group_price=0;
	my $group_mrc=0;
	my $order_bundles =[];
	my $bundle_hash = {map {("$_->{_column_data}->{bundle_id}"=>$_)} $db->table("Bundle")->search({"me.bundle_id"=>{-in=>[map {$_->{id}} @{$group->{bundle}}]}},{prefetch=>["category","bundle_price_models"]})->all };
        foreach my $item ( @{ $group->{bundle} } ) {
            next if ( !$item->{id} || !$item->{value} );

            my $b = $bundle_hash->{$item->{id}};# $db->table("Bundle")->find({ bundle_id => $item->{id} },{prefetch=>"category"});

            next if (!$b);

            # Additional Price Handling HERE

            my ($model,$netsuite_id);
	    my $models = $db->options("PriceModel");
	    if ($b->bundle_price_models->count()==1) {
		$model = $b->bundle_price_models->first;
	    } else {
		my $available_models = {map {("$_->{_column_data}->{price_model_id}"=>$_)} $b->bundle_price_models}; 
		if ($item->{is_rented} && $available_models->{$models->{rent}}) {
			$model = $available_models->{$models->{rent}};
		} elsif (!$item->{is_rented}) {
			($model) = grep {$_->price_model_id!=$models->{rent}} values %$available_models;
		} else {
			$model = shift(@{$b->bundle_price_models});
		}
	    }
	    my ($ob_mrc,$ob_total,$annual) = (0,0,0);
	    my $list_price=0;
	    if ($model) {
	    	if ($model->price_model_id=~/^$models->{monthly}|$models->{rent}$/) {
			$ob_mrc = $item->{final_price};
			$list_price = $b->mrc_price;
			$netsuite_id = $b->netsuite_mrc_id;
	    	} else {
			$list_price = $b->base_price;
			if ($model->price_model_id=~/^$models->{buy}|$models->{one_time}$/) {
				$ob_total = $item->{final_price};#/$item->{value};
			} elsif ($model->price_model_id==$models->{annually}) {
				$annual = $item->{final_price};#*$item->{value};
			}
			$netsuite_id=$b->netsuite_order_id;
		}
	    } else {
		$client->displayfailure("No pricing model for bundle $item->{id}\n");
	    }
	    push(@{$order_bundles},{
                    order_group_id => $ordergroup->order_group_id,
                    bundle_id      => $b->bundle_id,
                    quantity       => $item->{value},
                    list_price     => $list_price,
                    one_time_total    => $ob_total+$annual+$order->{prepay_amount},
		    mrc_total => $ob_mrc,#*(($discounts->{apply_to}->{$b->{bundle_id}})?($ob_mrc*(1-$discounts->{total_discount})):1),
		    is_rented => $item->{is_rented}+0,
		    tax_mapping_id=>$model->tax_mapping_id,
	            discounted_price=>$item->{final_price}+0,
		    
                } );
            $group_price += $ob_total;

            $group_mrc+=$ob_mrc;
        }

        $db->table("OrderBundle")->populate($order_bundles);
        $ordergroup->one_time_total($group_price);
        $ordergroup->mrc_total($group_mrc);
        $ordergroup->update();
        $order_price += $group_price;
        $order_mrc += $group_mrc;
    }
    $order->one_time_total($order_price);
    $order->mrc_total($order_mrc);
    $order->update();

    return { order_id => $order_id };
}

sub rollback 
{
    my ( $class, $client, $input ) = @_;

    return $input;
}

sub process_address 
{
    my ( $book, $sd, $db ) = @_;

    my $digest = Digest::MD5::md5_hex( join( "", map { $sd->{$_} } sort keys %$sd ) );
    if ( $book->{$digest} ) 
    {
        return $book->{$digest};
    } 
    else 
    {
        my $h = {
            addr1      => $sd->{addr1},
            addr2      => $sd->{addr2},
            city       => $sd->{city},
            state_prov => $sd->{state_prov},
            postal     => $sd->{postal},
            country    => $sd->{country},
            type       => "shipping",
        };
        my $addr = $db->table("EntityAddress")->search($h)->first;
        if ( !$addr ) 
        {
            $addr = $db->table("EntityAddress")->find_or_create($h);
        }
        $book->{$digest} = $addr->entity_address_id;

        return $addr->entity_address_id;
    }
}
