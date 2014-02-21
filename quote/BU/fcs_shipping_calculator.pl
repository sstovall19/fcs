#!/usr/bin/perl

use strict;
use warnings;
use lib '/home/smisel/perl5/lib/perl5';
use lib '/home/smisel/Fcs/lib';
use SM::Client;
use Fap::Db::Fcs;
use Getopt::Std;

use Data::Dumper;
use Fap::SolvingMaze;
use Locale::Country;
use Locale::US;

my $db = Fap::Db::Fcs->new();
my $client = SM::Client->new();
my %options=();
getopts('r', \%options);

my ($input)  = $client->initialize();
rollback($client, \%options, $input) if (defined($options{'r'}));
my ($output, $error, $status) = execute($client, $input, \%options);

(($status == 1) ? $client->displaysuccess($output) : $client->displayfailure($error));
exit;

sub execute {
	my ($client) = shift;
	my ($input) = shift;
	my ($options) = shift;
	my ($output);
	my ($error);
	$output=$input;

	my $grouped_by_address_and_service = organize(\$input);

	foreach my $address (keys %{$grouped_by_address_and_service->{'Address'}}) {
			my ($rates) = GetUPSRate(	$grouped_by_address_and_service->{'Address'}->{$address}->{'Info'}, 
							$grouped_by_address_and_service->{'Address'}->{$address}->{'Items'});
			if (!defined($rates)) {
				$client->displayfailure("Unable to get UPS Rates: ". $@);
			}
			$output->{'Shipping'}->{'Info'}->{$address}->{'Comingled'} = $grouped_by_address_and_service->{'Info'}->{'Comingled'};
			$output->{'Shipping'}->{'Info'}->{$address}->{'Items'} = $grouped_by_address_and_service->{'Address'}->{$address}->{'Items'};
			$output->{'Shipping'}->{'Info'}->{$address}->{'Address'} = $grouped_by_address_and_service->{'Address'}->{$address}->{'Info'};
			$output->{'Shipping'}->{'Info'}->{$address}->{'Rates'} = $rates;
	}

	return($output, $error, 1);
}

sub organize {
	# Organize by address and shipping service, so multiple orders going to the same address with the same
	# 	shipping can all co-mingle in boxes... and set the comingle flag so someone in provisioning knows
	#	to mark each product with the ServerID.  This will prevent the cusotmer from being extremely confused
	#	when items from different orders shipped in the same box.

	my $grouped_by_address_and_service;
	for (my $i=0;$i<@{$input->{'servers'}};$i++) {
		my $address_and_service;
		foreach my $item ('shipping_state','shipping_country','shipping_city','shipping_zip','shipping_street','shipping_service') {
			if (defined($input->{'servers'}->[$i]->{'Shipping'}->{$item})) {
				$address_and_service .= "_".$input->{'servers'}->[$i]->{'Shipping'}->{$item};
			}
		}
		foreach my $itemarray ($input->{'servers'}->[$i]->{'Items'}) {
			foreach my $item (@{$itemarray}) {
				if ( (defined ($item->{'value'})) && ($item->{'value'} =~/^[0-9]+$/) ) {
					$grouped_by_address_and_service->{'Address'}->{$address_and_service}->{'Items'}->{$item->{'id'}} += $item->{'value'};
				}
			}
		}
		$grouped_by_address_and_service->{'Address'}->{$address_and_service}->{'Info'} = $input->{'servers'}->[$i]->{'Shipping'};
	}
	$grouped_by_address_and_service->{'Info'}->{'Comingled'} = @{$input->{'servers'}} ne scalar(keys %{$grouped_by_address_and_service->{'Address'}}) || 0;

	return ($grouped_by_address_and_service);
}

sub rollback {
	my ($client) = shift;
	my ($options) = shift;
	$client->display(*STDERR, "Asked to Roll Back but this BU does not do anything that can be rolled back.");
	$client->displaysuccess($input);
}

sub GetUPSRate {
	my $address = shift;
	my $products = shift;

	my $sm = SolvingMaze->new('Los Angeles','B941SJC7QP42PR7RNSQW');
	# ISO country code required.
	my $country = country2code($address->{'shipping_country'}) || $address->{'shipping_country'};

	my $state = $address->{'shipping_state'};
	# United States?  State name must be two letters.
	if ( ($country =~/^US$/i) && (length($state) > 2) ) {
		my $u = Locale::US->new;
		$state  = $u->{state2code}{uc($state)};
 	}
 
	$sm->destination( {	'country' => $country, 'region' => $state,
				'post' => $address->{'shipping_zip'}, 'city' => $address->{'shipping_city'}	});
	$sm->simplify(1);

	foreach my $item (keys %{$products}) {
		my ($i) = $db->table('bundle_packing')->search(
			{ 'me.bundle_id' => $item },
			{ prefetch => 'bundle'}  );

		my ($data) = $db->strip($i);

		if ($data) {
			my $packable = JSON::XS::true;
			my $filler = JSON::XS::false;
			# If an item is filler, it is automatically packable.
			if ($data->{'packing'} eq 'filler') {
				$filler = JSON::XS::true;
				$packable = JSON::XS::true;

			# If an item has a box, it is not packable and not filler.
			} elsif ($data->{'packing'} eq 'is_boxed') {
				$packable = JSON::XS::false;
				$filler = JSON::XS::false;
			}

			$sm->add_item_detail( {
					'sku' => $item,
					'qty' => $products->{$item},
					'name' => $data->{'bundle'}->{'name'},
					'weight' => $data->{'ounces'},
					'weightUnit' => 'oz',
					'unitPrice' => $data->{'bundle'}->{'price'},
					'rotatable' => JSON::XS::true,
					'packable' => $packable,
					'voidFiller' => $filler,
					'dimensionUnit' => 'in',
					'dimensions' => [    {
						'length' => $data->{'l'},
						'width' => $data->{'w'},
						'height'=> $data->{'h'} 
					}  ]
				} );
		}

	}
	return($sm->get_rates());
}
