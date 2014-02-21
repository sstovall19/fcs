package Fap::Order::Discounts;
use strict;
use Fap;
use Fap::Model::Fcs;
use Fap::Model::Cache;
use Data::Dumper;
use Time::HiRes qw(time);


sub calculate_all {
	my ($class,%args) = @_;

	my $db = $args{db};
	my $order = $args{order_details};
	$order->{term_in_months}||=12;
	my $pricing_models = $db->options("PriceModel");
	my $total_onetime=0;
	my $total_mrc = 0;
	my $discounts=>{};
	my $users = 0;
	my @ul = grep {$_->{id}=~/^81|83/} @{$order->{order_group}->[0]->{bundle}};
	if ($ul[0]) {
		$users = $ul[0]->{value}+$args{additional_user};
	}
	my $discount_key = join ("-","order-discount",$order->{reseller_id},$order->{discount_percent},$order->{prepay_percent},$order->{promo_code},$users,map {"$_->{id}=$_->{value}=".(($_->{is_rented}?1:0))} sort {$a->{id}<=>$b->{id}} @{$order->{order_group}->[0]->{bundle}});
	if (my $ret = $db->cache->get($discount_key) && 0 && !$args{additional_user}) {
		$ret->{contact} = $order->{contact};
		return $ret;
	}
	my $bundle_key = join ("-","order-discount",$order->{reseller_id},$order->{discount_percent},$order->{prepay_percent},$order->{promo_code},$users,map {"$_->{id}=".(($_->{is_rented}?1:0))} sort {$a->{id}<=>$b->{id}} @{$order->{order_group}->[0]->{bundle}});
	
	foreach my $group (@{$order->{order_group}}) {
		my $s = time;
		my $group_mrc;
		my $bundles = $db->cache->get($bundle_key);
		if (!$bundles) {
			$bundles = {map {("$_->{_column_data}->{bundle_id}"=>$_->strip)} $db->table("Bundle")->search(
				{"me.bundle_id"=>[map {$_->{id}} @{$group->{bundle}}]},
				{prefetch=>["category","bundle_price_models",{"bundle_discounts"=>{"discount"=>"category"}}]}
			)->all};
			$db->cache->set($bundle_key,$bundles,60);
		}
		my $group_onetime=0;
		my $group_mrc=0;
		my $group_ot_base = 0;
		my $group_mrc_base = 0;
		my $savings={
			monthly=>0,	
			onetime=>0,
		};

		foreach my $order_bundle (@{$group->{bundle}}) {
			my $bundle = $bundles->{$order_bundle->{id}};
			my $available_models = {map {("$_->{price_model_id}"=>$_)} @{$bundle->{bundle_price_models}}};

			my $bh={};
                        foreach my $bundle_discount (@{$bundle->{bundle_discounts}}) {
                                if ($bh->{$bundle_discount->{discount}->{name}}) {
                                        push(@{$bh->{$bundle_discount->{discount}->{name}}},$bundle_discount->{discount});
                                } else {
                                        $bh->{$bundle_discount->{discount}->{name}} = [$bundle_discount->{discount}];
                                }
                        }

 			my $apply_discount=0;
                        foreach my $discount (keys %$bh) {
                                my $tiers = [sort {$a->{max_value}<=>$b->{max_value}} @{$bh->{$discount}}];
                                if (scalar(@$tiers)) {
                                        if ($discount eq "volume") {
                                                my ($tier) = grep {($users>=$_->{min_value} && $users<=$_->{max_value})} @$tiers;
                                                if ($tier) {
                                                        $apply_discount+=($tier->{percent}/100);
                                                }
                                        } elsif ($discount eq "prepay") {
                                                if ($group->{details} && $order->{prepay_percent}) {
                                                        my ($tier) = grep {$order->{prepay_percent}>=$_->{min_value} && $order->{prepay_percent}<=$_->{max_value}} @$tiers;
                                                        if ($tier) {
                                                                $apply_discount+=($tier->{percent}/100);
								
                                                        }
							
                                                }
                                        }
                                }
                        }
                        $order_bundle->{discount} = $apply_discount;

			my $model;
			if (scalar($bundle->{bundle_price_models})==1) {
				$model = $bundle->{bundle_price_models}->[0];
			} elsif ($order_bundle->{is_rented}) {
				if ($available_models->{$pricing_models->{rent}}) {
					$model = $available_models->{$pricing_models->{rent}};
				} elsif ($available_models->{$pricing_models->{monthly}}) {
					 $model = $available_models->{$pricing_models->{monthly}};
				} elsif ($available_models->{$pricing_models->{annually}}) {
					$model = $available_models->{$pricing_models->{annually}};
				} else {
					if ($bundle->{mrc_price}<=0) {
						$model={price_model_id=>$pricing_models->{buy}};
					} else {
						$model = {price_model_id=>$pricing_models->{monthly}};
					}
				}
			} else {
				$model = $available_models->{$pricing_models->{buy}};
			}
			if ($model->{price_model_id}=~/^$pricing_models->{rent}|$pricing_models->{monthly}$/) {
				$order_bundle->{base_price} = $bundle->{mrc_price};
				$order_bundle->{list_price}=$order_bundle->{base_price}*$order_bundle->{value};
				$order_bundle->{final_price} = $order_bundle->{list_price}*(1-$apply_discount);
				$group_mrc+=$order_bundle->{final_price};
				$group_mrc_base+=$order_bundle->{list_price};

			} elsif ($model->{price_model_id}=~/^$pricing_models->{buy}|$pricing_models->{one_time}$/) {
				$order_bundle->{base_price} = $bundle->{base_price};
				$order_bundle->{list_price}=$order_bundle->{base_price}*$order_bundle->{value};
                                $order_bundle->{final_price} = $order_bundle->{list_price}*(1-$apply_discount);
				$group_onetime+=$order_bundle->{final_price};
				$group_ot_base+=$order_bundle->{list_price};
			}
		}
		my $details = {
			discounted=>{
				one_time=>$group_onetime,
				monthly=>$group_mrc,
				prepay_percent=>$order->{prepay_percent},
			},
			base=>{
				one_time=>$group_ot_base,
				monthly=>$group_mrc_base,
				prepay_percent=>0,
			}
		};
		foreach my $type (qw(discounted base)) {
			my $dt = $details->{$type};
			my $perc = $dt->{prepay_percent}/100;
			$dt->{required_prepay} = ($dt->{monthly}*($order->{term_in_months}-1))*$perc;
			$dt->{monthly}*=1-$perc;
			$dt->{monthly_over_contract} = ($dt->{monthly}*($order->{term_in_months}-1));

			$dt->{total_cost} = $dt->{required_prepay}+$dt->{monthly_over_contract}+$dt->{one_time}+$dt->{monthly};
			$dt->{total_cost_per_user} = sprintf("%0.2f",$dt->{total_cost}/$users);
			$dt->{monthly_cost_per_user} = $dt->{monthly}/$users;

		}
		$group->{details} = $details;
		$total_onetime+=$group_onetime;
		$total_mrc+=$group_mrc;

	}
	$order->{term_in_months}||=12;
	$order->{users} = $users;
	$db->cache->set($discount_key,$order,60);
	return $order;
	
	
}
	
	
	

sub license_discount {
	my ($class,%args) = @_;

	my $bundles=>[];
	my $db = $args{db}||Fap::Model::Fcs->new();
	
	my $conf = Fap->load_conf("order/license_discounts");
	my $ret = {
		volume_discount=>0,
		prepay_discount=>0,
		total_discount=>0,
	};
	my $bh={};
	my $prepay;
	my $input;
	if ($args{order_id}||$args{order}) {
		$input={};
		my $order = $args{order}||$db->table("Order")->find(
                        {order_id=>$args{order_id},"order_bundle.bundle_id"=>[keys %{$conf->{apply_to}}]},
                        {prefetch=>{order_groups=>"order_bundles"}}
                );
		if ($order) {
			foreach my $group ($order->order_groups) {
				foreach ($group->order_bundles) {
					foreach my $bundle ($group->order_bundles) {
						if (discountable_license($conf,$bundle->bundle_id)) {
							
							if ($bh->{$bundle->{$bundle->bundle_id}}) {
								$bh->{$bundle->bundle_id}->{quantity}+=$bundle->quantity;
							} else {
								$bh->{$bundle->bundle_id}={quantity=>$_->quantity,discount=>0};
							}
						}
					}
				}
			}
		}
		$prepay = $order->prepay_amount;
	} else {
		$input = $args{input};
		$prepay = $input->{prepay_amount};
		foreach my $group (@{$input->{order_group}}) {
			foreach my $bundle (@{$group->{bundle}}) {
				if (discountable_license($conf,$bundle->{id})) {
					if ($bh->{$bundle->{bundle_id}}) {
						$bh->{$bundle->{id}}->{quantity}+=$bundle->{value};
					} else {
						$bh->{$bundle->{id}} = {quantity=>$bundle->{value},discount=>0};
					}	
				}
			}
		}
	}
	# calculate seats
	my $seats=0;
	foreach my $id (keys %$bh) {
		if ($conf->{volume}->{apply_to}->{$id}) {
			$seats+=$bh->{$id}->{quantity};
		}
	}
	
	$ret->{volume_discount} = calculate($seats,$conf->{volume},\&check_upper_volume);
	$ret->{prepay_discount} = calculate($prepay/100,$conf->{prepay},\&check_upper_prepay);
	$ret->{total_discount} =  $ret->{volume_discount}+$ret->{prepay_discount};
	$ret->{apply_to} = {map {$_=>1} keys %$bh};
	return $ret;
}

sub calculate {
	my ($amount,$conf) = @_;

	my $discount=0;
	if ($amount>=$conf->{lower_bound}) {
                if ($amount>$conf->{upper_bound}) {
                        $amount=$conf->{upper_bound};
                }
                $discount =$amount*$conf->{coeficient};
                #check upper bound
		if ($discount) {
			my $max_u = (1/(2*$conf->{coeficient}))-10;
			$max_u=$amount if ($max_u<0);
			if ($amount>$max_u) {
				$amount = $max_u;
				$discount = $amount*$conf->{coeficient};
			}
                }
		if ($amount>0) {
			my $max_a = 1/(2*$amount);
			if ($conf->{coeficient}>$max_a) { 
				$discount = $amount*$max_a;
			}
		}
				
        }
	return $discount;
}
sub discountable_license {
	my ($conf,$bundle_id) = @_;

	foreach my $type (keys %$conf) {
		return 1 if ($conf->{$type}->{apply_to}->{$bundle_id});
	}
	return 0;
}
1;
