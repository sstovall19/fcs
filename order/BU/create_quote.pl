#!/usr/bin/perl

use strict;
use F::Order;
use JSON::XS;

my $input = <STDIN>;
my $q = JSON::XS->new->utf8->decode($input); 
main();

sub main
{
	# GLOBAL VARIABLES
	my $referrer_site   = 'referringsite';
	my $reseller_id     = undef;
	my $reseller_state  = undef;
	my $valid_reseller  = 0;
	my $referral_site   = undef;
	my $vars = {};

	my $schema = F::DBIx->connect('dbi:mysql:pbxtra', 'fonality', 'iNOcallU');
	
	$reseller_id    = $href->{'reseller_id'};
	my $dynamic_item_IDs = get_dynamic_items($schema);
	my $proposal_id = create_quote($schema,$q,$vars,$referrer_site,$reseller_id,$dynamic_item_IDs);
	$q->{quote} = $proposal_id;
	my $json = JSON::XS->new->utf8->encode($q);
	print $json;
}

sub create_quote 
{
	my $schema = shift(@_);
	my $q              = shift(@_);
	my $vars           = shift(@_);
	my $referrer_site  = shift(@_);
	my $reseller_id    = shift(@_);
	my $dynamic_item_IDs = shift(@_);

	my $proposal_id;
	foreach my $server (@{$q->{servers}})
	{
		my ($price_total,$qty_phones,$qty_phone_ports,$item_hash,$price_hash) = get_invoice_totals($schema,$server,$q,$vars,$reseller_id,$dynamic_item_IDs);

		$proposal_id = create_new_quote($schema,$price_total,$reseller_id,$referrer_site);

		# create the quote_trans
		while ( my ($item_id, $quantity) = each(%$item_hash) )
		{
			next if ($item_id !~ /\d/);
			add_item_to_quote($schema,$proposal_id,$item_id,$quantity,$price_hash->{$item_id});
		}
		my $proposal_href = get_quote($schema,$proposal_id);
	}
	return $proposal_id;
}

sub create_new_quote
{
	my $schema		   = shift(@_);
	my $price_total    = shift(@_);
	my $reseller_id    = shift(@_);
	my $referrer_site  = shift(@_);

	# get the referring site from a cookie
	my $referringsite        = '';
	my ($ref_date,$ref_site) = split(/\r/,$referringsite);

	# If this is an intranet user creating the quote put that in the first_requesturl. We don't care about employees
	# browser cookies. -mstofko
	my $request_url = '';

	# create the quote_header
	my $proposal_id = add_quote($schema,$price_total,$ref_site,$ref_date,$reseller_id);
	return $proposal_id;
}

sub get_invoice_totals
{
	my $schema		   = shift(@_);
	my $server		   = shift(@_);
	my $q              = shift(@_);
	my $vars           = shift(@_);
	my $valid_reseller = shift(@_) || undef;
	my $reseller_id    = shift(@_) || undef;
	my $intranet_name  = shift(@_) || undef;
	my $dynamic_item_IDs = shift(@_);
	my %quantities = ();

	my $valid_reseller = (defined($reseller_id) ? 1 : 0);
	my %quantities = ();
	my %prices = ();
	my %process = ();
	my %prorated = ();
	my $price_phones = 0;
	my $price_support = 0;
	my $price_support_per  = 0;
	my $price_items = 0;
	my $qty_phones = 0;
	my $qty_phone_ports = 0;
	my $price_phone_config = 0;
	my $sangoma_ports = 0;
	my $reprovisioned_phones = 0;
	my $sangoma_echo_selected = 0;
	my $sangoma_fxo_qty = 0;
	my $sangoma_fxs_qty = 0;
	my $selected_server_id = '';
	my $num_digital_cards = 0;
	my $unbound_software_id = '';
	my $regulatory_recovery_total = 0;	# this is the total we will use to calculate the Regulatory Recovery Fee
	my @user_license_upgrades = ();

	my $unique = 0;

	# foreach through the params looking for items that ^item_ or ^phone_ or ^accessory or etc.
	foreach my $item (@{$server->{Items}})
	{
		# get the item info from the db
		my $param_id = $item->{id};
		my $param = $item->{name};
		my $quantity = $item->{quantity};
		my $quantity2 = $item->{quantity2};
		my $category = $item->{category};
		my $item_ref = get_reseller_item($schema,$param_id,$reseller_id);

		# We should count each item we come across of a particular type
		$quantities{$param_id}++;
		$prices{$param_id} = $item_ref->{'price'};
		$price_items += $item_ref->{'price'};

		# used to determine whether we need to add a VoIP Timing card
		$num_digital_cards++ if($item_ref->{'group_name'} eq 'Cards - Digital');

		#  We need to account for T1 setup fees for T1 items - ignore for resellers
		if( !$valid_reseller and $item_ref->{'group_name'} eq 'Cards - Digital')
		{
			$quantities{ $dynamic_item_IDs->{'T1_SETUP'} }++;	# T1 setup fee
			my $t1setup = get_reseller_item($schema,$dynamic_item_IDs->{'T1_SETUP'},$reseller_id);
			$price_items += $t1setup->{'price'};
			$prices{ $dynamic_item_IDs->{'T1_SETUP'} } = $t1setup->{'price'};
		}

		if ($param eq 'item_server_hardware')
		{
			# save the server ID for looking up the Sangoma analog card type if necessary
			$selected_server_id = $param_id;
		}
		if ($category eq 'Phones')
		{
			my $item_id = $param_id;
			my $param = $param;
			my $qty = $quantity;
			if ($qty)
			{
				my $item_ref = {};
				if ($item_id == $dynamic_item_IDs->{'REPROVISIONED_PHONE'} or $item_id == $dynamic_item_IDs->{'REMOTE_REPROVISIONED_PHONE'})
				{
					# DON'T DISCOUNT THE RE-PROVISIONED PHONES
					$item_ref = get_reseller_item($schema,$item_id,$reseller_id);
					$reprovisioned_phones += $qty;	# use this below to charge remote provisioning if necessary
					if ($valid_reseller)
					{
						# skip for Resellers -- we charge them fees for their own phones
						$qty_phones += $qty;
						next;
					}
				}
				elsif ($item_id == $dynamic_item_IDs->{'UNBOUND_REPROVISIONING'})
				{
					$item_ref = get_reseller_item($schema, $item_id, $reseller_id);
					$reprovisioned_phones = $qty;
				}
				else
				{
					$item_ref = get_reseller_item($schema,$item_id,$reseller_id) || return undef;
				}

				# add the price to the total
				$price_phones += ($item_ref->{'price'} * $qty);
				# do not increment phone fees for: Kirk base, 650 sidecar
				unless ($param =~ $dynamic_item_IDs->{'KIRK_KWS300_BASE'} or $param =~ $dynamic_item_IDs->{'POLYCOM_650_SIDECAR'})
				{
					$qty_phones += $qty;
				}

				# put the phone into the item hash
				$quantities{$item_id} = $qty;
				$prices{$item_id} = $item_ref->{'price'};
			}
		}
		if ($category eq 'Rhino')
		{
			my $cntFXS = $quantity;
			my $cntFXO = $quantity2;
			# get the item info from the db
			my $rhino_base = get_reseller_item($schema, $dynamic_item_IDs->{'RHINO_BASE'}, $reseller_id);
			my $rhino_FXS  = get_reseller_item($schema, $dynamic_item_IDs->{'RHINO_FXS'}, $reseller_id);
			my $rhino_FXO  = get_reseller_item($schema, $dynamic_item_IDs->{'RHINO_FXO'}, $reseller_id);

			$quantities{ $dynamic_item_IDs->{'RHINO_BASE'} } += 1;
			$prices{ $dynamic_item_IDs->{'RHINO_BASE'} } = $rhino_base->{'price'};

			# add the prices to the totals
			$price_items += $rhino_base->{'price'};
			if ($cntFXS)
			{
				$quantities{ $dynamic_item_IDs->{'RHINO_FXS'} } += $cntFXS;
				$prices{ $dynamic_item_IDs->{'RHINO_FXS'} } = $rhino_FXS->{'price'};
				$price_items += $rhino_FXS->{'price'} * $cntFXS;
			}
			if ($cntFXO)
			{
				$quantities{ $dynamic_item_IDs->{'RHINO_FXO'} } += $cntFXO;
				$prices{ $dynamic_item_IDs->{'RHINO_FXO'} } = $rhino_FXO->{'price'};
				$price_items += $rhino_FXO->{'price'} * $cntFXO;
			}
		}
		if ($category eq 'Accesories')	
		{
			# the SANGOMA FXO PORTS param
			if ($param eq 'accessory_fxo_card')
			{
				$sangoma_fxo_qty = $quantity;
				if ($sangoma_fxo_qty ne '')
				{
					$sangoma_ports += $sangoma_fxo_qty;
				}
			}
			# the FAX TIMING CABLE param
			if ($param eq 'accessory_fax_timing_cable')
			{
				my $fax_timing_cable = get_reseller_item($schema, $dynamic_item_IDs->{'FAX_TIMING_CABLE'}, $reseller_id);
				$quantities{ $dynamic_item_IDs->{'FAX_TIMING_CABLE'} } = 1;
				$prices{ $dynamic_item_IDs->{'FAX_TIMING_CABLE'} } = $fax_timing_cable->{'price'};
			}
			# the SANGOMA FXS PORTS param
			if ($param eq 'accessory_fxs_card')
			{
				$sangoma_fxs_qty = $quantity;
				if ($sangoma_fxs_qty ne '')
				{
					$sangoma_ports += $sangoma_fxs_qty;
					if ($selected_server_id == $dynamic_item_IDs->{'PBXTRA_DELL_R310'})
					{
						# 1U's only -- add a power adapter when an FXS analog card is present
						my $PCIe_power_adapter = get_reseller_item($schema, $dynamic_item_IDs->{'PCIe_POWER_ADAPTER'}, $reseller_id);
						$quantities{ $dynamic_item_IDs->{'PCIe_POWER_ADAPTER'} } = 1;
						$prices{ $dynamic_item_IDs->{'PCIe_POWER_ADAPTER'} } = $PCIe_power_adapter->{'price'};
					}
				}
			}
			# the SANGOMA ECHO CANCELLATION param
			elsif ($param eq 'accessory_analog_echo')
			{
				$sangoma_echo_selected = 1;
			}
			# Aastra 560 Sidecars are phones but don't count for support or config fees
			elsif ($param eq 'sidecar_650')
			{
				my $item_ref = get_reseller_item($schema, $dynamic_item_IDs->{'POLYCOM_650_SIDECAR'}, $reseller_id);
				$quantities{ $dynamic_item_IDs->{'POLYCOM_650_SIDECAR'} } = $quantity;
				$prices{ $dynamic_item_IDs->{'POLYCOM_650_SIDECAR'} } = $item_ref->{'price'};
				$price_items += ($item_ref->{'price'} * $quantity);
			}
			# Aastra 480i Handsets are phones but don't count for support or config fees
			elsif ($param eq 'a480i_handset')
			{
				my $item_ref = get_reseller_item($schema, $dynamic_item_IDs->{'AASTRA_CT_HANDSET'}, $reseller_id);
				$quantities{ $dynamic_item_IDs->{'AASTRA_CT_HANDSET'} } = $quantity;
				$prices{ $dynamic_item_IDs->{'AASTRA_CT_HANDSET'} } = $item_ref->{'price'};
				$price_items += ($item_ref->{'price'} * $quantity);
			}
		}
		if ($category eq "Editions")
		{
			# software option for PBXtra UNBOUND
			if ($param eq 'unbound_software_edition')
			{
				# Cache the netsuite ids by edition for easy lookup later
				my %ed = (
					se  => $dynamic_item_IDs->{'UNBOUND_SOFTWARE_STANDARD'},
					pe  => $dynamic_item_IDs->{'UNBOUND_SOFTWARE_PRO'},
					cce => $dynamic_item_IDs->{'UNBOUND_SOFTWARE_CALLCENTER'},
					old_cce => $dynamic_item_IDs->{'UNBOUND_SOFTWARE_OLD_CCE'}
				);
				# get the item info from the db
				my $item_ref = get_reseller_item($schema, $param_id, $reseller_id);

				# We should count each item we come across of a particular type
				$quantities{$param_id} = 1;
				$prices{$param_id} = $item_ref->{'price'};
				$price_items += $item_ref->{'price'};
				# save the software ID -- we'll add the quantity after we've tallied all the phones
				$unbound_software_id = $param_id;
			}
		}
		if ($category eq "Unbound")
		{
			# all other PBXtra UNBOUND items that start with 'unbound_'
			my $unbound_item_id;
			if ($param eq 'unbound_router')
			{
				$unbound_item_id = $dynamic_item_IDs->{'UNBOUND_QoS_ROUTER'}
			}
			elsif ($param eq 'unbound_additional_dids')
			{
				$unbound_item_id = $dynamic_item_IDs->{'UNBOUND_SETUP_DID'};

				# while we're here, add the first-time recurring charge
				my $itm = get_reseller_item($schema, $dynamic_item_IDs->{'UNBOUND_ADDITIONAL_DID'}, $reseller_id);
				$quantities{ $dynamic_item_IDs->{'UNBOUND_ADDITIONAL_DID'} } = $quantity;
				$prices{ $dynamic_item_IDs->{'UNBOUND_ADDITIONAL_DID'} } = $itm->{'price'};
				$price_items += $itm->{'price'};
			}
			elsif ($param eq 'unbound_toll_free_numbers')
			{
				$unbound_item_id = $dynamic_item_IDs->{'UNBOUND_SETUP_TOLLFREE'};

				# while we're here, add the first-time recurring charge
				my $itm = get_reseller_item($schema, $dynamic_item_IDs->{'UNBOUND_TOLLFREE'}, $reseller_id);
				$quantities{$dynamic_item_IDs->{'UNBOUND_TOLLFREE'}} = $quantity;
				$prices{$dynamic_item_IDs->{'UNBOUND_TOLLFREE'}} = $itm->{'price'};
				$price_items += $itm->{'price'};
			}
			elsif ($param eq 'unbound_fax_dids')
			{
				$unbound_item_id = $dynamic_item_IDs->{'UNBOUND_SETUP_FAX'};

				# while we're here, add the first-time recurring charge
				my $itm = get_reseller_item($schema, $dynamic_item_IDs->{'UNBOUND_FAX'}, $reseller_id);
				$quantities{ $dynamic_item_IDs->{'UNBOUND_FAX'} } = $quantity;
				$prices{ $dynamic_item_IDs->{'UNBOUND_FAX'} } = $itm->{'price'};
				$price_items += $itm->{'price'};
			}
			my $item_ref = get_reseller_item($schema, $unbound_item_id, $reseller_id) || return undef;

			# put the rack mount into the item hash
			$quantities{$unbound_item_id} = $quantity;
			$prices{$unbound_item_id} = $item_ref->{'price'};
			$price_items += $item_ref->{'price'};

			# add to the Regulatory Recover Fee total - only a few items
			if ($param eq 'unbound_additional_dids' or $param eq 'unbound_toll_free_numbers')
			{
				$regulatory_recovery_total += $item_ref->{'price'} * $quantity;
			}
		}
		if ($category eq "Licenses")
		{
			if ($param eq 'hudmobile_licenses')
			{
				my $item_qty = $quantity;
				if ($item_qty)
				{
					my $item_ref = get_reseller_item($schema, $dynamic_item_IDs->{'HUD_MOBILE'}, $reseller_id);
					$quantities{ $dynamic_item_IDs->{'HUD_MOBILE'} } = $item_qty;
					$prices{ $dynamic_item_IDs->{'HUD_MOBILE'} } = $item_ref->{'price'};
					$price_items += ($item_ref->{'price'} * $item_qty);
				}
			}
			elsif ($param eq 'voicemail_transcription')
			{
				my $item_qty = $quantity;
				if ($item_qty =~ /^\d+$/)
				{
					my $item_ref = get_reseller_item($schema, $dynamic_item_IDs->{'VOICEMAIL_TRANSCRIBE'}, $reseller_id);
					$quantities{ $dynamic_item_IDs->{'VOICEMAIL_TRANSCRIBE'} } = $item_qty;
					$prices{ $dynamic_item_IDs->{'VOICEMAIL_TRANSCRIBE'} } = $item_ref->{'price'};
					$price_items += ($item_ref->{'price'} * $item_qty);
				}
			}
			elsif ($param eq 'voip')
			{
				# get the correct VoIP Only Timing Card
				my $item_ref = get_voip_only_timing_cards($schema, $dynamic_item_IDs, $selected_server_id, $reseller_id);
				$quantities{$item_ref->{'item_id'}} = 1;
				$prices{$item_ref->{'item_id'}}     = $item_ref->{'price'};
				$price_items += ($item_ref->{'price'});
			}
		}
		#
		#	PBXtra UNBOUND - a different per-seat/phone setup fee applies according to each software package
		#
		if ($param eq 'Unbound')
		{
			my $cur_ed;
			# get shortcuts for the item ids and items we'll be using
			my %ed = (se => {}, pe => {}, cce => {});
			$ed{se}{setup_id}   = $dynamic_item_IDs->{'UNBOUND_SETUP_STANDARD'};
			$ed{se}{recur_id}   = $dynamic_item_IDs->{'UNBOUND_SOFTWARE_STANDARD'};
			$ed{se}{setup_item} = get_reseller_item($schema, $ed{se}{setup_id}, $reseller_id);
			$ed{se}{recur_item} = get_reseller_item($schema, $ed{se}{recur_id}, $reseller_id);

			$ed{pe}{setup_id}   = $dynamic_item_IDs->{'UNBOUND_SETUP_PRO'};
			$ed{pe}{recur_id}   = $dynamic_item_IDs->{'UNBOUND_SOFTWARE_PRO'};
			$ed{pe}{setup_item} = get_reseller_item($schema, $ed{pe}{setup_id}, $reseller_id);
			$ed{pe}{recur_item} = get_reseller_item($schema, $ed{pe}{recur_id}, $reseller_id);

			$ed{cce}{setup_id}   = $dynamic_item_IDs->{'UNBOUND_SETUP_CALLCENTER'};
			$ed{cce}{recur_id}   = $dynamic_item_IDs->{'UNBOUND_SOFTWARE_CALLCENTER'};
			$ed{cce}{setup_item} = get_reseller_item($schema, $ed{cce}{setup_id}, $reseller_id);
			$ed{cce}{recur_item} = get_reseller_item($schema, $ed{cce}{recur_id}, $reseller_id);

			# THIS IS FOR ADDON ORDERS ONLY - OLD CCE UNBOUND WAS $69.99 AND SOME CUSTOMERS ARE STILL USING IT
			$ed{old_cce}{setup_id}   = $dynamic_item_IDs->{'UNBOUND_SETUP_OLD_CCE'};
			$ed{old_cce}{recur_id}   = $dynamic_item_IDs->{'UNBOUND_SOFTWARE_OLD_CCE'};
			$ed{old_cce}{setup_item} = get_reseller_item($schema, $ed{old_cce}{setup_id}, $reseller_id);
			$ed{old_cce}{recur_item} = get_reseller_item($schema, $ed{old_cce}{recur_id}, $reseller_id);

			# Not adding special ADDON setup for SE since you can't upgrade to SE and there's no refund for downgrading
			if ($unbound_software_id eq $ed{se}{recur_id})
			{
				$quantities{$ed{se}{setup_id}} = $qty_phones;
				$prices{$ed{se}{setup_id}} = $ed{se}{setup_item}->{'price'};
				$regulatory_recovery_total += $ed{se}{setup_item}->{'price'} * $qty_phones;
			}
			elsif ($unbound_software_id eq $ed{pe}{recur_id})
			{
				$quantities{$ed{pe}{setup_id}} = $qty_phones;
				$prices{$ed{pe}{setup_id}} = $ed{pe}{setup_item}->{'price'};
				$regulatory_recovery_total += $ed{pe}{setup_item}->{'price'} * $qty_phones;

			}
			elsif ($unbound_software_id eq $ed{cce}{recur_id})
			{
				$quantities{$ed{cce}{setup_id}} = $qty_phones;
				$prices{$ed{cce}{setup_id}} = $ed{cce}{setup_item}->{'price'};
				$regulatory_recovery_total += $ed{cce}{setup_item}->{'price'} * $qty_phones;

			}
			$quantities{$unbound_software_id} = $qty_phones unless $unbound_software_id eq '';	# add the qty of software here

			# calculate the Regulatory Recovery Fee
			my $regulatory_recovery_fee = $regulatory_recovery_total * F::Order::kREGULATORY_RECOVERY_RATE;	# heavy lifting
			if ($regulatory_recovery_fee > 0)
			{
				# regulatory_recovery_fee might be zero if this is an add-on order with no recovery total
				$quantities{ $dynamic_item_IDs->{'UNBOUND_REGULATORY_FEE'} } = 1;
				$prices{ $dynamic_item_IDs->{'UNBOUND_REGULATORY_FEE'} } = $regulatory_recovery_fee;
				$price_items += $regulatory_recovery_fee;
			}
		}
	}


	#
	#	SANGOMA CARD RULES - a.k.a. ANALOG PORTS
	#
	if ($sangoma_ports)
	{
		# first - determine card type (PCI or PCIe?)
		my $analog_card_type = '';
		# get the server's analog_card_type (PCI or PCIe)
		my $servers = get_servers($schema);
		foreach my $server (@$servers)
		{
			if ($server->{'item_id'} == $selected_server_id)
			{
				$analog_card_type = $server->{'analog_card_type'};
				last;
			}
		}

		# get the Shark cards
		my $base_cards = undef;
		if ($analog_card_type eq 'PCIe')
		{
			$base_cards = get_reseller_items($schema,$reseller_id,'analog_base_pcie');
		}
		else
		{
			$base_cards = get_reseller_items($schema,$reseller_id,'analog_base_pci');
		}

		# the Sangoma card can support 4 ports, 1 Remora can support another 4 ports, a second Remora supports another 4 to a maximum of 12
		# so here we create an array that lays out a structure of how the ports will be arrayed on the card - FXO ports are installed first
		my @sangoma_ports = ((('fxo') x $sangoma_fxo_qty), (('fxs') x $sangoma_fxs_qty));
		my @sangoma_cards = ();
		while (@sangoma_ports)
		{
			push @sangoma_cards, [splice(@sangoma_ports, 0, 4)];
		}

		# add the base SHARK CARD to the order
		my $base_card_ports = splice(@sangoma_cards, 0, 1);
		my %base_card_ports = (fxo=>0, fxs=>0);
		foreach my $port_type (@$base_card_ports)
		{
			$base_card_ports{$port_type}++;
		}
		my $base_card_search = 'echw' . $sangoma_echo_selected . '|fxo' . $base_card_ports{'fxo'} . '|fxs' . $base_card_ports{'fxs'};
		foreach my $base_card (@$base_cards)
		{
			if ($base_card->{'mnemonic'} eq $base_card_search)
			{
				# found a matching SHARK CARD
				$quantities{$base_card->{'item_id'}} = 1;
				$prices{$base_card->{'item_id'}} = $base_card->{'price'};
				$price_items += $base_card->{'price'};
				last;
			}
		}

		# add the first REMORA CARD if there are ports left
		if (@sangoma_cards)
		{
			my $exp1_ports = splice(@sangoma_cards, 0, 1);
			my %exp1_ports = (fxo=>0, fxs=>0);
			foreach my $port_type (@$exp1_ports)
			{
				$exp1_ports{$port_type}++;
			}
			my $first_remoras = get_reseller_items($schema,$reseller_id,'analog_exp1');
			my $first_remora_search = 'echw' . $sangoma_echo_selected . '|fxo' . $exp1_ports{'fxo'} . '|fxs' . $exp1_ports{'fxs'};
			foreach my $first_remora (@$first_remoras)
			{
				if ($first_remora->{'mnemonic'} eq $first_remora_search)
				{
					$quantities{$first_remora->{'item_id'}} = 1;
					$prices{$first_remora->{'item_id'}} = $first_remora->{'price'};
					$price_items += $first_remora->{'price'};
					last;
				}
			}
		}

		# add the second REMORA CARD if there are ports left
		if (@sangoma_cards)
		{
			my $exp2_ports = splice(@sangoma_cards, 0, 1);
			my %exp2_ports = (fxo=>0, fxs=>0);
			foreach my $port_type (@$exp2_ports)
			{
				$exp2_ports{$port_type}++;
			}
			my $second_remoras = get_reseller_items($schema,$reseller_id,'analog_exp2');
			my $second_remora_search = 'echw' . $sangoma_echo_selected . '|fxo' . $exp2_ports{'fxo'} . '|fxs' . $exp2_ports{'fxs'};
			foreach my $second_remora (@$second_remoras)
			{
				if ($second_remora->{'mnemonic'} eq $second_remora_search)
				{
					$quantities{$second_remora->{'item_id'}} = 1;
					$prices{$second_remora->{'item_id'}} = $second_remora->{'price'};
					$price_items += $second_remora->{'price'};
					last;
				}
			}
		}
	}
	
	# if we have no cards and edition selected is not Standard Edition
	# skip this part for UNBOUND and ADD-ON orders
	if (($num_digital_cards + $sangoma_ports <= 0) and !$vars->{'UNBOUND'} and !$vars->{'ADDON'})
	{
		unless(exists $quantities{ $dynamic_item_IDs->{'PBXTRA_SOFTWARE_STANDARD'} })
		{
			# get the correct VoIP Only Timing Card
			my $item_ref = get_voip_only_timing_cards($schema, $dynamic_item_IDs, $selected_server_id, $reseller_id);
			$quantities{$item_ref->{'item_id'}} = 1;
			$prices{$item_ref->{'item_id'}}     = $item_ref->{'price'};
			$price_items += ($item_ref->{'price'});
		}
	}

	#
	#	PHONE CONFIG FEES
	#
    if ($qty_phones and !$vars->{'UNBOUND'})
    {
		# resellers -- Credits ~or~ Fees
		if ($valid_reseller)
		{
			my $fonality_phones_id = $dynamic_item_IDs->{'RESELLER_FEE_OUR_PHONE'};
			my $reseller_phones_id = $dynamic_item_IDs->{'RESELLER_FEE_THEIR_PHONE'};

			# check for fees on fonality phones
			if (($qty_phones - $reprovisioned_phones) > 0)
			{
				my $item = get_reseller_item($schema,$fonality_phones_id,$reseller_id);
				$price_phone_config += ($qty_phones - $reprovisioned_phones) * $item->{'price'};

				# put the phone fee in the item hash
				$quantities{$fonality_phones_id} = $qty_phones - $reprovisioned_phones;
				$prices{$fonality_phones_id} = $item->{'price'};
			}

			# also -- check for fees on reprovisioned phones
			if ($reprovisioned_phones > 0)
			{
				my $item = get_reseller_item($schema,$reseller_phones_id,$reseller_id);
				$price_phone_config += $reprovisioned_phones * $item->{'price'};

				# put the phone fee in the item hash
				$quantities{$reseller_phones_id} = $reprovisioned_phones;
				$prices{$reseller_phones_id} = $item->{'price'};
			}
		}
		else
		{
        	my $fee_ref = get_reseller_item($schema,$dynamic_item_IDs->{'CONFIG_FEE'},$reseller_id);
        	$price_phone_config = $qty_phones * $fee_ref->{'price'};

        	# put the phone fee in the item hash
        	$quantities{ $dynamic_item_IDs->{'CONFIG_FEE'} } = $qty_phones;
        	$prices{ $dynamic_item_IDs->{'CONFIG_FEE'} } = $fee_ref->{'price'};
		}
    }


    # now figure out how many phone ports they have (cuz we charge support contracts for phone ports also)
    $qty_phone_ports = get_qty_phone_ports(\%quantities,F::Order::kPHONE_PORTS) || 0;
	my $seat_cnt = $qty_phone_ports + $qty_phones;
    my $price_total = $price_items + $price_phones + $price_phone_config + $price_support;
	$price_total = 0 if $price_total < 0;

	return ($price_total,$qty_phones,$qty_phone_ports,\%quantities,\%prices,\%prorated);
}

sub update_quote_header
{
	my $schema = shift(@_);
	my $quote_href = shift(@_);

	my $sql;
	my $update_href;

	# return undef if they didn't pass us a valid quote_id
	unless($quote_href->{quote_id} =~ /^\d+$/) 
	{
		return undef;
	}

	my $schema  = F::DBIx->connect('dbi:mysql:pbxtra', 'fonality', 'iNOcallU');

	# hash key to table column map.  Used to determine what is being fed and what 
	# we should update
	#
	# we do this so that the API controls what is fed  into the SQL statement, not the struct.
	my $args_to_cols = [
		['total', 'total'],
		['name', 'name'],
		['email', 'email'],
		['phone', 'phone'],
		['reseller', 'reseller'],
		['reseller_id', 'reseller_id'],
		['referral_site', 'referral_site'],
		['referral_date', 'referral_date'],
		['first_requesturl', 'first_requesturl'],
		['sugar_opportunity_id', 'sugar_opportunity_id'],
		['website', 'website'],
		['industry', 'industry'],
		['telecommuters', 'telecommuters'],
		['branch_offices', 'branch_offices'],
		['salesperson_id', 'salesperson_id'],
		['random_proposal_string', 'random_proposal_string'],
		['deduction', 'deduction'],
		['deduction_expire_date', 'deduction_expire_date'],
		['sales_tax', 'sales_tax'],
		['promo_code', 'promo_code'],
		['purchase_timeframe', 'purchase_timeframe'],
		['rental_phones', 'rental_phones'],
		['market', 'market'],
	];


	# Organize the list of update columns and their bind params
	# this way the funtion is flexible with what it can receive	
	foreach my $param ( @{$args_to_cols} )
	{
		if ( exists($quote_href->{$param->[0]}) ) 
		{
			$update_href->{$param->[1]} = $quote_href->{$param->[1]};
		}
	}
	my @update_item = $schema->resultset("QuoteHeader")->search(
		{
			'quote_header_id' => $quote_href->{quote_id}
		}
	)->update($update_href);
	my $rv = (scalar(@update_item));	
	unless ($rv)
	{
		return undef;
	}
	else
	{
		return 1; 
	}
}

sub get_sales_tax
{
	my $state = shift(@_);
	my $zipcode = shift(@_);

	# Check the state
	unless ($state =~ /^\w+$/)
	{
		return 0;
	}
	$state = uc($state);

	my %taxes = (
					AZ => 0.078,
					CA => 0.0925,
					CO => 0.0775,
					DC => 0.0575,
					GA => 0.07,
					IL => 0.085,
					FL => 0.06,
					KS => 0.0865,
					MA => 0.05,
					MD => 0.06,
					MN => 0.067,
					NC => 0.068,
					#NY => 0.0825,
					OK => 0.082,
					RI => 0.07,
					TN => 0.07,
					TX => 0.0825,
					WA => 0.085
				);

	my $sales_tax = $taxes{$state} || 0;
	return $sales_tax;
}

sub get_item
{
	my $schema = shift(@_);
	my $item_id = shift(@_);
	my $discount = shift(@_);
	unless($item_id =~ /^\d+$/) {
		return(undef);
	}

	# discount logic - apply to selected item if a discount value was provided
	my $discount_multiplier;
	if(defined($discount))
	{
		if($discount > 1 or $discount < 0)
		{
			# invalid discount value
			return(undef);
		}
		else
		{
			# the number to multiply the item price by
			# if the $discount= 0.20 then $discount_multiplier= 0.80
			$discount_multiplier = 1 - $discount;
		}
	}

	my %item = $schema->resultset("Item")->search(
		{
			'item_id' => $item_id
		},
	)->single->get_columns;
	my $item = \%item;	
	# never apply discount to these item_groups: 
	if ($item->{group_name} =~ /support/i or $item->{group_name} =~ /warranty/i)
	{
		$discount = undef;
	}

	if(defined($discount))
	{
		# apply the discount if appropriate
		$item->{price} *= $discount_multiplier;
		$item->{price} = sprintf("%.0f", $item->{price}); # round price with no decimals
	}

	return($item);
}

sub get_reseller_item
{
	my $schema = shift(@_);
	my $item_id = shift(@_);
	my $reseller_id = shift(@_);
	my $discount_group = shift(@_) || '*';

	unless ($item_id =~ /^\d+$/)
	{
		return(undef);
	}

	unless ($reseller_id =~ /^\d+$/)
	{
		# no reseller ID - just return a regular item
		my $item = get_item($schema,$item_id);
		return $item;
	}

	my %item = $schema->resultset("Item")->search(
		{
			'item_id' => $item_id
		},
	)->single->get_columns;
	my $item = \%item;
	my $reseller = $schema->resultset("Reseller")->search(
		{
			'reseller_id' => $reseller_id,
		},
		{
			columns => [
				'status',
				'certified'
			],
		},
	);

	unless (defined $reseller->status and $reseller->certified =~ /on/i)
	{
		# reseller invalid - no discounts
		return ($item);
	}
	# now look for the reseller's discount
	my $rs = $schema->resultset("ResellerDiscount")->search(
		{
			'reseller_id' => $reseller_id,
			'discount_group' => $item->{discount_group},
		},
		{
			columns => [
				'discount_amt'
			]
		}
	);

	my %discount = $schema->resultset("ResellerDiscount")->search(
		{
			'discount_group' => $item->{discount_group},
			'reseller_status' => $reseller->status,
			'reseller_certified' => $reseller->certified,
		},
		{
			columns => [
				'discount_amt'
			]
		}
	)->single->get_columns;
	my $discount = \%discount;
	# discount logic - apply to selected item
	$item->{'retail_price'} = $item->{'price'};
	if ($discount->{'discount_amt'} < 1 and $discount->{'discount_amt'} > 0)
	{
		# the number to multiply the item price by
		# if the $discount= 0.20 then $discount_multiplier= 0.80
		my $discount_multiplier = 1 - $discount->{'discount_amt'};

		# apply the discount
		$item->{'price'} *= $discount_multiplier;
		$item->{'price'} = sprintf("%.2f", $item->{'price'});
	}
	return($item);
}

sub get_reseller_items
{
	my $schema = shift(@_);
	my $reseller_id = shift(@_);
	my $group_name = shift(@_);
	my $price_order = shift(@_);

	# use this method to get raw item data
	my $items = get_items($schema,$group_name,undef,undef,$price_order);

	# not a valid reseller id, don't even try to look for discounts
	if ($reseller_id !~ /^\d+$/)
	{
		return $items;
	}

	unless (defined $items)
	{
		return(undef);
	}

	#	get the reseller's info
	my $reseller = $schema->resultset("Reseller")->search(
		{
			'reseller_id' => $reseller_id,
		},
		{
			columns => [
				'status',
				'certified'
			],
		},
	);
	unless (defined $reseller->{'status'} and $reseller->{'certified'} =~ /on/i)
	{
		# reseller invalid - no discounts
		return ($items);
	}
	my $discount_groups = {};   # this will prevent unnecessary DB calls
	foreach my $item (@$items)
	{
		my $discount;
		if (defined $discount_groups->{$item->{'discount_group'}})
		{
			$discount = $discount_groups->{$item->{'discount_group'}};
		}
		elsif ($item->{'discount_group'} eq '')
		{
			$discount = '';	# no discount group means no discount
		}
		else
		{
			# now look for the reseller's discount
			my $discount_row = $schema->resultset("ResellerDiscount")->search(
				{
					'reseller_id' => $reseller_id,
					'discount_group' => $item->{'discount_group'},
				},
				{
					columns => [
						'discount_amt'
					]
				}
			);
			if ($discount_row->{'discount_amt'} !~ /\d/)
			{
				# no special discount for this reseller ID
				my $rs = $schema->resultset("ResellerDiscount")->search(
					{
						'discount_group' => $item->{'discount_group'},
						'reseller_status' => $reseller->{'status'},
						'reseller_certified' => $reseller->{'certified'},
					},
					{
						columns => [
							'discount_amt'
						]
					}
				);
			}
			# save the discount amount
			$discount_groups->{$item->{'discount_group'}} = $discount_row->{'discount_amt'};
			$discount = $discount_row->{'discount_amt'};
		}
		# discount logic - apply to selected item
		$item->{'retail_price'} = $item->{'price'};
		if ($discount < 1 or $discount > 0)
		{
			# the number to multiply the item price by
			# if the $discount= 0.20 then $discount_multiplier= 0.80
			my $discount_multiplier = 1 - $discount;
			$item->{'price'} *= $discount_multiplier;
			$item->{'price'} = sprintf("%.2f", $item->{'price'});
		}
	}

	return($items);
}

sub get_reseller
{
	# get the db handle
	my $schema = shift(@_);
	my $search_id  = shift(@_);
	my $search_col = shift(@_);

	my %reseller;
	if ($search_col =~ /^reseller_id$/i)
	{
		%reseller = $schema->resultset("Reseller")->search(
			{
				'reseller_id' => $search_id
			}
		)->single->get_columns;
	}
	elsif ($search_col =~ /^username$/i)
	{
		%reseller = $schema->resultset("Reseller")->search(
			{
				'username' => $search_id
			}
		)->single->get_columns;
	}
	my $reseller = \%reseller;
	return($reseller);
}

sub get_dynamic_items
{
	my $schema = shift(@_);
	my %all_items = {};
	my @rs = $schema->resultset("DynamicItemXref")->all;
	foreach my $item (@rs)
	{
		$all_items{$item->item_keyname} = $item->item_id;
	}
	return \%all_items;
}

sub add_item_to_quote
{
	my $schema          = shift(@_);
	my $quote_header_id = shift(@_);
	my $item_id         = shift(@_);
	my $quantity        = shift(@_);
	my $item_price      = shift(@_);

	my $quote_trans_id = 0;
	if ($item_price =~ m/\d/)
	{
		my $rs = $schema->resultset("QuoteTran")->create(
			{
				'quote_header_id' => $quote_header_id,
				'item_id' => $item_id,
				'quantity' => $quantity,
				'item_price' => $item_price,
			}
		);
		$quote_trans_id = $rs->id;
	}
	else
	{
		my $rs = $schema->resultset("QuoteTran")->create(
			{
				'quote_header_id' => $quote_header_id,
				'item_id' => $item_id,
				'quantity' => $quantity,
			}
		);
		$quote_trans_id = $rs->id;
	}

	return($quote_trans_id);
}

sub get_live_invoice_items
{
	my (%opt, @ret);
	if ($_[0] =~ /^\d{4,6}$/)
	{
		$opt{sid} = shift;
	}
	else
	{
		%opt = ref($_[0]) eq 'HASH' ? %{+shift} : @_;
		$opt{sid} ||= $opt{server_id};
	}
	my $schema = $opt{schema};
	my $rs = $schema->resultset("LiveInvoiceItem")->search(
		{
			'server_id' => $opt{sid}
		}
	);
	while (my $item = $rs->next)
	{
		my %item = $item->get_columns;
		my $ii = \%item;
		push @ret, $ii;
	}
	# Warning: this changes the return value
	if ($opt{sum})
	{
		my $count = 0;
		$count += $_ for map { $_->{'quantity'} } @ret;
		return $count;
	}
	if ($opt{fetch_items})
	{
		foreach my $n (0..$#ret)
		{
			$ret[$n]->{'item_info'} = get_item($schema, $ret[$n]->{'item_id'});
		}
	}
#print Dumper @ret;
	return wantarray ? @ret : \@ret;
}

sub add_quote
{
	my $schema = shift(@_);
	my $quote_total = shift(@_) || 0.00;
	my $referral_site = shift(@_) || '';
	my $referral_date = shift(@_) || '';
	my $reseller_id = shift(@_) || 0;

 	my $rs = $schema->resultset("QuoteHeader")->create(
 		{
 			'creation_date' => \'NOW()',
 			'total' => $quote_total,
 			'referral_site' => $referral_site,
 			'referral_date' => $referral_date,
 			'reseller_id' => $reseller_id,
 		}
 	);
 	my $quote_header_id = $rs->id;
	return($quote_header_id);
}

sub get_quote
{
	my $quote_header_id = shift(@_);
	my $schema = shift(@_);

	unless($quote_header_id =~ /^\d+$/) {
		return(undef);
	}
	my $quote = $schema->resultset("QuoteHeader")->search(
		{
			'quote_header_id' => $quote_header_id,
		},
	);
	return(undef) unless ref($quote);

	my @items = ();
	my $rs = $schema->resultset("QuoteTran")->search(
		{
			'quote_header_id' => $quote_header_id,
		},
	);
	while (my $item = $rs->next)
	{
		my %item = $item->get_columns;
		my $i = \%item;
		push @items, $i;
	}

	# Put the items on the hashref_of_quote_info
	$quote->{'items'} = \@items;

	# Return the hashref_of_quote_info
	return($quote);
}

sub get_voip_only_timing_cards
{
	my $schema = shift(@_);
	my $netsuite_to_item_ids = shift(@_);
	my $selected_server_item_id = shift(@_);
	my $reseller_id = shift(@_) || '';

	my $dell_1U_basic   = F::Order::kDELL_1U_BASIC_SERVER_NETSUITE_ID;
	my $dell_1U_premium = F::Order::kDELL_1U_PREMIUM_SERVER_NETSUITE_ID;
	my $item_ref = undef;

	# now get the correct cheap timing card for the selected server type
	if ($selected_server_item_id == $netsuite_to_item_ids->{$dell_1U_basic}  or  $selected_server_item_id == $netsuite_to_item_ids->{$dell_1U_premium})
	{
		# Dell 1U servers cannot accommodate a PCI card - so they get the internal USB only
		my $netsuite_id = F::Order::kVOIP_TIMING_CARD_NETSUITE_ID;
		$item_ref = get_reseller_item($schema, $netsuite_to_item_ids->{$netsuite_id}, $reseller_id);
	}
	else
	{
		# all other servers get the internal Sangoma USB with a PCI card
		my $netsuite_id = F::Order::kVOIP_TIMING_CARD_KIT_NETSUITE_ID;
		$item_ref = get_reseller_item($schema, $netsuite_to_item_ids->{$netsuite_id}, $reseller_id);
	}

	return $item_ref;
}

sub get_servers
{
	my $schema = shift(@_);
	my $discount = shift(@_);

	# discount logic - apply to all selected items if a discount value was provided
	my $discount_multiplier;
	if(defined($discount))
	{
		$discount_multiplier = 1 - $discount;
	}

	my($item,@items);
	my $rs = $schema->resultset("Item")->search(
		{
			'status' => 'active',
			'group_name' => 'servers'
		},
		{
			prefetch=>{"item_server"}
		}
	);

	while($item = $rs->next) {
		my %itemsh = $item->get_columns;
		my $ii = \%itemsh;
		if(defined($discount))
		{
			# apply the discount if appropriate
			$ii->{price} *= $discount_multiplier;
			$ii->{price} = sprintf("%.0f", $ii->{price}); # round price with no decimals
		}
		push(@items, $ii);
	}
	return(\@items);
}

sub get_qty_phone_ports
{
	my $item_hash       = shift(@_);
	my $port_hash       = shift(@_);
	my $qty_phone_ports = 0;

	foreach my $item_id (keys %$item_hash)
	{
		# now loop through the Phone Port hash and add the quantities
		foreach my $port_item_id (keys %$port_hash)
		{
			if ($port_item_id == $item_id)
			{
				$qty_phone_ports += $port_hash->{$port_item_id} * $item_hash->{$item_id};
			}
		}
	}
	return $qty_phone_ports;
}
