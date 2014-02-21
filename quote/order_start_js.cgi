#!/usr/bin/perl

use strict;

use F::Util;
use Apache::Request();
use Apache::Constants qw(REDIRECT);
use Template ();
use Template::Stash; # Template::Stash is for custom TT methods (such as substr below) 
use Date::Calc qw(:all);
use F::Database;
use F::Order;
use F::Cookies;
use F::Resellers;
use Data::Dumper;

my $reseller_cookie = 'FONALITYreseller';
my $reseller        = 0;
my $reseller_id     = '';

my $file = 'order_start.js';
my $q    = new Apache::Request(@_, DISABLE_UPLOADS => 0, POST_MAX => (20 * (1024 * 1024))); 
my $vars = {};
my $dbh  = mysql_connect() || die "Unable to connect to database; $!"; # Connect to the db

# is a manager's discount present? this only matters in orders
if ($q->param('deduction_exists'))
{
	$vars->{'DEDUCTION_EXISTS'} = 1;
}

$vars->{'PBXTRA_VERSION'} = 5;

# is this an ADD-ON?
if ($q->param('addon'))
{
	$vars->{'ADDON'} = 1;
}

# separate quotes from orders
$vars->{'QUOTE'} = 0;
my $type = $q->param('type');
if ($type eq 'q')
{
	$vars->{'QUOTE'} = 1;
}

# is this an order or a quote?
my $quote_or_order = {};
my $my_id = $q->param('id');
if ($my_id)
{
	if ($type eq 'q')
	{
		$quote_or_order = F::Order::get_quote($dbh,$my_id) or err($q,"Error getting proposal from database. $@");
	}
	else
	{
		$quote_or_order = F::Order::get_order($dbh,$my_id) or err($q,"Error getting order from database. $@");
	}
}

my $affiliate = affiliate_update($q, $vars);

# ADDON
my $server_info = undef;
my $server_id   = undef;
if ($vars->{'ADDON'})
{
	$server_id = $quote_or_order->{'server_id'};
	$server_info = F::Server::get_server_info($dbh, $server_id) or err($q);
	$vars->{'CP_VERSION'} = $server_info->{'cp_version'};
}

# get dynamic item ID values; global variables are retrieved from the dynamic_item_xref table
my $dynamic_item_IDs = F::Order::get_dynamic_items();

# save the name of inactivated items from old quotes
foreach my $item (@{$quote_or_order->{'items'}})
{
	if ($item->{'item_id'} == $dynamic_item_IDs->{'HP_MINITOWER_SERVER'})
	{
		$vars->{'HP_MINITOWER_SELECTED'} = 1;
	}
	elsif ($item->{'item_id'} == $dynamic_item_IDs->{'FONALITY_2U_SERVER'})
	{
		$vars->{'FONALITY_2U_SELECTED'} = 1;
	}
	elsif ($item->{'item_id'} == $dynamic_item_IDs->{'HP_1U_SERVER'})
	{
		$vars->{'HP_1U_SELECTED'} = 1;
	}
}

# get cookie - reseller's ID and discounts
# these values are actually in the database but derived from a random string in the cookie
$vars->{'RESELLER'} = 0;
if (my $reseller_cookie = F::Cookies::get_cookie_from_browser($q, $reseller_cookie))
{
	my $href = F::Cookies::get_reseller_id_from_cookie($dbh,$q,$reseller_cookie,1);
	if (defined $href)
	{
		$href = F::Resellers::get_reseller($dbh,$href->{'reseller_id'},'reseller_id') or err($q);
		$vars->{'RESELLER_STATUS'} = $href->{'status'};
		if ($href->{'certified'} eq 'on')
		{
			$reseller_id = $href->{'reseller_id'};
			$reseller = 1; # set to true
			$vars->{'RESELLER'} = 1;
		}
	}
}

my $per_seat_licensing_fee = F::Order::get_reseller_item($dbh, $dynamic_item_IDs->{'VoIP_TIMING_CARD_DellXE'}, $reseller_id);
$vars->{'PER_SEAT_LICENSING_FEE'} = $per_seat_licensing_fee->{'price'};

my $linked_server = F::Order::get_reseller_item($dbh, $dynamic_item_IDs->{'PBXTRA_LINKING_STANDARD'}, $reseller_id);
$vars->{'LINKED_ITEM_ID'} = $dynamic_item_IDs->{'PBXTRA_LINKING_STANDARD'};
$vars->{'LINKED_FEE'}     = $linked_server->{'price'};

my $linked_server_cce = F::Order::get_reseller_item($dbh, $dynamic_item_IDs->{'PBXTRA_LINKING_CALL_CENTER'}, $reseller_id);
$vars->{'LINKED_CCE_ITEM_ID'} = $dynamic_item_IDs->{'PBXTRA_LINKING_CALL_CENTER'};
$vars->{'LINKED_CCE_FEE'}     = $linked_server_cce->{'price'};

# Reseller provisioning fees/credits
my $reseller_fee_fonality_config_fonality_phones = F::Order::get_reseller_item($dbh, $dynamic_item_IDs->{'RESELLER_FEE_OUR_PHONE'}, $reseller_id);
$vars->{'RESELLER_FEE_FONALITY_CONFIG_FONALITY_PHONES_PRICE'}   = $reseller_fee_fonality_config_fonality_phones->{'price'};

my $reseller_fee_fonality_config_reseller_phones = F::Order::get_reseller_item($dbh, $dynamic_item_IDs->{'RESELLER_FEE_OUR_PHONE'}, $reseller_id);
$vars->{'RESELLER_FEE_FONALITY_CONFIG_RESELLER_PHONES_PRICE'}   = $reseller_fee_fonality_config_reseller_phones->{'price'};

my $reseller_credit_reseller_config_fonality_phones = F::Order::get_reseller_item($dbh, $dynamic_item_IDs->{'RESELLER_CREDIT_OUR_PHONE'}, $reseller_id);
$vars->{'RESELLER_CREDIT_RESELLER_CONFIG_FONALITY_PHONES_PRICE'}   = $reseller_credit_reseller_config_fonality_phones->{'price'};

my $reseller_credit_reseller_config_reseller_phones = F::Order::get_reseller_item($dbh, $dynamic_item_IDs->{'RESELLER_CREDIT_THEIR_PHONE'}, $reseller_id);
$vars->{'RESELLER_CREDIT_RESELLER_CONFIG_RESELLER_PHONES_PRICE'}   = $reseller_credit_reseller_config_reseller_phones->{'price'};

# get a list of phone data
$vars->{'PHONES'} = F::Order::get_phones($dbh);

# save software item IDs
$vars->{'PBXTRA_STANDARD_ID'}      = $dynamic_item_IDs->{'PBXTRA_SOFTWARE_STANDARD'};
$vars->{'PBXTRA_PROFESSIONAL_ID'}  = $dynamic_item_IDs->{'PBXTRA_SOFTWARE_PROFESSIONAL'};
$vars->{'PBXTRA_CALL_CENTER_ID'}   = $dynamic_item_IDs->{'PBXTRA_SOFTWARE_CALL_CENTER'};
$vars->{'PBXTRA_UNIFIED_AGENT_ID'} = $dynamic_item_IDs->{'PBXTRA_SOFTWARE_UAE'};

# HUD software
$vars->{'HUD_AGENT_ITEM_ID'} = $dynamic_item_IDs->{'HUD_AGENT'};
$vars->{'HUD_QUEUES_OVER20_ITEM_ID'} = $dynamic_item_IDs->{'HUD_QUEUES_LARGE'};
$vars->{'HUD_QUEUES_OVER20'} = F::Order::get_reseller_item($dbh, $dynamic_item_IDs->{'HUD_QUEUES_LARGE'}, $reseller_id);
$vars->{'HUD_QUEUES_UNDER20_ITEM_ID'} = $dynamic_item_IDs->{'HUD_QUEUES_SMALL'};
$vars->{'HUD_QUEUES_UNDER20'} = F::Order::get_reseller_item($dbh, $dynamic_item_IDs->{'HUD_QUEUES_SMALL'}, $reseller_id);

# LINKING software
$vars->{'LINKING_SOFTWARE_STANDARD_ID'}    = $dynamic_item_IDs->{'PBXTRA_LINKING_STANDARD'};
$vars->{'LINKING_SOFTWARE_CALL_CENTER_ID'} = $dynamic_item_IDs->{'PBXTRA_LINKING_CALL_CENTER'};

# PBXtra servers
$vars->{'DELL_1U_BASIC_SERVER_ID'} = $dynamic_item_IDs->{'PBXTRA_DELL_R310'};

$vars->{'REPROVISIONED_PHONE'} = F::Order::get_reseller_item($dbh,$dynamic_item_IDs->{'REPROVISIONED_PHONE'},$reseller_id);
$vars->{'REMOTE_REPROVISIONED_PHONE'} = F::Order::get_reseller_item($dbh,$dynamic_item_IDs->{'REMOTE_REPROVISIONED_PHONE'},$reseller_id);

# get reprovisionined phone info
$vars->{'REPROVISIONED_PHONE_ID'} = $dynamic_item_IDs->{'REPROVISIONED_PHONE'};
my $remote_provisioning = F::Order::get_reseller_item($dbh, $dynamic_item_IDs->{'REMOTE_REPROVISIONED_PHONE'}, $reseller_id);
$vars->{'REMOTE_REPROVISIONING_FEE'} = $remote_provisioning->{'price'};
$vars->{'REMOTE_REPROVISIONED_PHONE_ID'} = $dynamic_item_IDs->{'REMOTE_REPROVISIONED_PHONE'};

# unbound addon order processing
if ($vars->{'UNBOUNDADD'})
{
	# save this to know if the customer is renting phones or purchasing them
	my $customer = F::Order::get_customer_info_detailed($dbh);
	$vars->{'RENTAL_PHONES'} = $quote_or_order->{'rental_phones'};

	# vars only needed by PBXtra UNBOUND
	$vars->{'UNBOUND_PHONE_RENTALS'} = F::Order::get_reseller_items($dbh,$reseller_id,'PBXtra UNBOUND Handset Rental',1);

	$vars->{'SOFTPHONE_BUNDLE_ITEM_ID'} = $dynamic_item_IDs->{'SOFTPHONE'};
	$vars->{'POLYCOM_331_ITEM_ID'}      = $dynamic_item_IDs->{'POLYCOM_331'};
	$vars->{'POLYCOM_560_ITEM_ID'}      = $dynamic_item_IDs->{'POLYCOM_560'};
	$vars->{'AASTRA_480I_CT_ITEM_ID'}   = $dynamic_item_IDs->{'AASTRA9480CT'};

	$vars->{'RENTAL_SOFTPHONE_BUNDLE_ITEM_ID'} = $dynamic_item_IDs->{'RENTAL_SOFTPHONE'};
	$vars->{'RENTAL_BUDGETONE_200_ITEM_ID'}    = $dynamic_item_IDs->{'RENTAL_BUDGETONE'};
	$vars->{'RENTAL_GXP2000_ITEM_ID'}          = $dynamic_item_IDs->{'RENTAL_GXP2000'};
	$vars->{'RENTAL_POLYCOM_331_ITEM_ID'}      = $dynamic_item_IDs->{'RENTAL_POLYCOM331'};
	$vars->{'RENTAL_POLYCOM_450_ITEM_ID'}      = $dynamic_item_IDs->{'RENTAL_POLYCOM450'};
	$vars->{'RENTAL_POLYCOM_550_ITEM_ID'}      = $dynamic_item_IDs->{'RENTAL_POLYCOM550'};
	$vars->{'RENTAL_POLYCOM_560_ITEM_ID'}      = $dynamic_item_IDs->{'RENTAL_POLYCOM560'};
	$vars->{'RENTAL_POLYCOM_6000_ITEM_ID'}     = $dynamic_item_IDs->{'RENTAL_POLYCOM6000'};
	$vars->{'RENTAL_AASTRA_480I_CT_ITEM_ID'}   = $dynamic_item_IDs->{'RENTAL_AASTRA9480CT'};

	# software editions for PBXTRA UNBOUND
	$vars->{'UNBOUND_SE_ITEM_ID'}  = $dynamic_item_IDs->{'UNBOUND_SOFTWARE_STANDARD'};
	$vars->{'UNBOUND_PE_ITEM_ID'}  = $dynamic_item_IDs->{'UNBOUND_SOFTWARE_PRO'};
	$vars->{'UNBOUND_CCE_ITEM_ID'} = $dynamic_item_IDs->{'UNBOUND_SOFTWARE_CALLCENTER'};

	# Linked software for UNBOUND SE
	$vars->{'UNBOUND_LINKED_SE_ITEM_ID'} = $dynamic_item_IDs->{'UNBOUND_LINK_STANDARD'};
	my $unbound_linked_se = F::Order::get_reseller_item($dbh, $vars->{'UNBOUND_LINKED_SE_ITEM_ID'}, $reseller_id);
	$vars->{'UNBOUND_LINKED_SE_PRICE'} = $unbound_linked_se->{'price'};
	# Linked software for UNBOUND PE
	$vars->{'UNBOUND_LINKED_PE_ITEM_ID'} = $dynamic_item_IDs->{'UNBOUND_LINK_PRO'};
	my $unbound_linked_pe = F::Order::get_reseller_item($dbh, $vars->{'UNBOUND_LINKED_PE_ITEM_ID'}, $reseller_id);
	$vars->{'UNBOUND_LINKED_PE_PRICE'} = $unbound_linked_pe->{'price'};
	# Linked software for UNBOUND CCE
	$vars->{'UNBOUND_LINKED_CCE_ITEM_ID'} = $dynamic_item_IDs->{'UNBOUND_LINK_CALLCENTER'};
	my $unbound_linked_cce = F::Order::get_reseller_item($dbh, $vars->{'UNBOUND_LINKED_CCE_ITEM_ID'}, $reseller_id);
	$vars->{'UNBOUND_LINKED_CCE_PRICE'} = $unbound_linked_cce->{'price'};

	# reprovisioned unbound phones
	$vars->{'UNBOUND_REPROVISIONING_ID'} = $dynamic_item_IDs->{'UNBOUND_REPROVISIONING'};
	push @{ $vars->{'PHONES'} }, F::Order::get_reseller_item($dbh, $vars->{'UNBOUND_REPROVISIONING_ID'});
}


# create an array of Support Tiers (count of Phones and Phone Ports)
# the key will be item IDs with matching counts of users that Javascript will use to get the price
my $js_array = "\nvar hashSupportTiers = new Array();\n";
my $hrefSuppTiers = kSUPPORT_TIERS;
my @support_tiers = my %invert_tiers = ();
# first - gather the values (tiers) in kSUPPORT_TIERS
foreach my $key (keys %$hrefSuppTiers)
{
	my $item_id = $key;
	my $ports   = $hrefSuppTiers->{$item_id};
	push(@support_tiers,$ports);
	# get the price of $item_id
	my $item_ref = get_reseller_item($dbh,$item_id,$reseller_id);
	# save the price with the Port Count
	$invert_tiers{$ports} = $item_ref->{'price'};
}
# second - sort them and create the Javascript array hash
foreach my $ports (reverse sort {$a <=> $b} @support_tiers)
{
	my $price = $invert_tiers{$ports};
	if ($reseller)
	{
		$price = sprintf("%.2f", $price);	# format decimals correctly for resellers who get a discount
	}
	$js_array .= "hashSupportTiers[\"$ports\"] = '$price';\n";
}
$vars->{'SUPPORT_TIERS'} = $js_array;




# create an array of the live backup servers ('redundancy')
# this is for a dynamically created javascript list in the template
$js_array  = "\nvar hashRedundants = new Array();\n";
my $js_array2 = "\nvar hashRedundantsPrice = new Array();\n";
my $js_array3 = "\nvar hashRedundantsRelation = new Array();\n";
my $arefRedundancy = F::Order::get_reseller_items($dbh,$reseller_id,'redundancy');
foreach my $ref (@$arefRedundancy)
{
	my $item_id = $ref->{'item_id'};
#my $item_name = "$ref->{name} [+ \$$ref->{price}]";
#$js_array    .= "hashRedundants[\"$item_id\"] = \"$item_name\";\n";
	my $name    = $ref->{'name'};
	my $price   = $ref->{'price'};
	my $base_assembly = $ref->{'base_assembly_id'};
	if ($reseller)
	{
		$price = sprintf("%.2f", $price);	# format decimals correctly for resellers who get a discount
	}
	$js_array  .= "hashRedundants[\"$item_id\"] = \"$name\";\n";
	$js_array2 .= "hashRedundantsPrice[\"$item_id\"] = '$price';\n";
	$js_array3 .= "hashRedundantsRelation[\"$base_assembly\"] = \"$item_id\";\n";

}
$vars->{'JS_ARRAY_REDUNDANCY'} = $js_array;
$vars->{'JS_ARRAY_REDUNDANCY_PRICES'} = $js_array2;
$vars->{'JS_ARRAY_REDUNDANCY_RELATION'} = $js_array3;




# get data on the various Software Editions
$js_array  = "\nvar hashEditions = new Array();\n";
$js_array2 = "\nvar hashEditionsPrice = new Array();\n";
my $arefEditions = F::Order::get_reseller_items($dbh,$reseller_id,'PBXtra Software',1);	# the final '1' is for ordering by PRICE
foreach my $ref (@$arefEditions)
{
	my $item_id   = $ref->{'item_id'};
	my $item_name = "$ref->{name}";
	my $price     = $ref->{'price'};
	if ($reseller)
	{
		$price = sprintf("%.2f", $price);	# format decimals correctly for resellers who get a discount
	}
	$js_array  .= "hashEditions[\"$item_id\"] = \"$item_name\";\n";
	$js_array2 .= "hashEditionsPrice[\"$item_id\"] = '$price';\n";
	# look for a Software Edition that needs to be selected when the page first loads
	foreach my $item (@{$quote_or_order->{'items'}})
	{
		if ($item->{'item_id'} == $item_id)
		{
			$vars->{'SELECTED_EDITION'} = $item_id;
			last;
		}
	}
}
$vars->{'JS_ARRAY_EDITIONS'} = $js_array;
$vars->{'JS_ARRAY_EDITIONS_PRICES'} = $js_array2;
# set a default
unless ($vars->{'SELECTED_EDITION'})
{
	my $ref = $$arefEditions[0];
	$vars->{'SELECTED_EDITION'} = $ref->{'item_id'};
}



# get data on the various HUD Versions
$js_array  = "\nvar hashHUD = new Array();\n";
$js_array2 = "\nvar hashHUDPrice = new Array();\n";
my $arefHUD = F::Order::get_reseller_items($dbh,$reseller_id,'PBXtra HUD',1);	# the final '1' is for ordering by PRICE
foreach my $ref (@$arefHUD)
{
	my $item_id   = $ref->{'item_id'};
	my $item_name = "$ref->{name}";
	my $price     = $ref->{'price'};
	if ($reseller)
	{
		$price = sprintf("%.2f", $price);	# format decimals correctly for resellers who get a discount
	}
	$js_array  .= "hashHUD[\"$item_id\"] = \"$item_name\";\n";
	$js_array2 .= "hashHUDPrice[\"$item_id\"] = '$price';\n";
	# look for a HUD version that needs to be selected when the page first loads
	foreach my $item (@{$quote_or_order->{'items'}})
	{
		if ($item->{'item_id'} == $item_id)
		{
			$vars->{'SELECTED_HUD'} = $item_id;
			last;
		}
	}
}
$vars->{'JS_ARRAY_HUD'} = $js_array;
$vars->{'JS_ARRAY_HUD_PRICES'} = $js_array2;
# set a default
unless ($vars->{'SELECTED_HUD'})
{
	my $ref = $$arefHUD[0];
	$vars->{'SELECTED_HUD'} = $ref->{'item_id'};
}




# get data on the various Servers
$js_array  = "\nvar hashServers = new Array();\n";
$js_array2 = "\nvar hashServersPrice = new Array();\n";
my $arefServers = F::Order::get_reseller_items($dbh,$reseller_id,'Servers',1);	# the final '1' is for ordering by PRICE
foreach my $ref (@$arefServers)
{
	my $item_id   = $ref->{'item_id'};
	my $item_name = "$ref->{name}";
	my $price     = $ref->{'price'};
	if ($reseller)
	{
		$price = sprintf("%.2f", $price);	# format decimals correctly for resellers who get a discount
	}
	$js_array  .= "hashServers[\"$item_id\"] = \"$item_name\";\n";
	$js_array2 .= "hashServersPrice[\"$item_id\"] = '$price';\n";
}
$vars->{'JS_ARRAY_SERVERS'} = $js_array;
$vars->{'JS_ARRAY_SERVERS_PRICES'} = $js_array2;





# get data on the various Analog Cards
my $servers = F::Order::get_servers($dbh);
$js_array = "\nvar hashServerAnalogType = new Array();\n";
foreach my $ref (@$servers)
{
	my $item_id = $ref->{'item_id'};
	my $type    = lc($ref->{'analog_card_type'});
	$js_array .= "hashServerAnalogType[\"$item_id\"] = \"$type\";\n";
}
$vars->{'JS_ARRAY_SERVER_ANALOG'} = $js_array;


my $analog = F::Order::get_reseller_items($dbh, $reseller_id, 'analog_base_pcie');
@$analog = (@$analog, @{F::Order::get_reseller_items($dbh, $reseller_id, 'analog_base_pci')});
$js_array = "\nvar hashAnalogPrice = new Array();\n";
foreach my $ref (@$analog)
{
	my $port_type = $ref->{'mnemonic'};
	my $price     = $ref->{'price'};
	if ($reseller)
	{
		$price = sprintf("%.2f", $price);	# format decimals correctly for resellers who get a discount
	}
	$ref->{'group_name'} =~ /(pci|pcie)$/;
	my $card_type = $1;
	$js_array .= "hashAnalogPrice[\"$card_type|1|$port_type\"] = '$price';\n";
}

$analog = F::Order::get_reseller_items($dbh, $reseller_id, 'analog_exp1');
foreach my $ref (@$analog)
{
	my $port_type = $ref->{'mnemonic'};
	my $price     = $ref->{'price'};
	if ($reseller)
	{
		$price = sprintf("%.2f", $price);	# format decimals correctly for resellers who get a discount
	}
	$js_array .= "hashAnalogPrice[\"pci|2|$port_type\"] = '$price';\n";
	$js_array .= "hashAnalogPrice[\"pcie|2|$port_type\"] = '$price';\n";
}

$analog = F::Order::get_reseller_items($dbh, $reseller_id, 'analog_exp2');
foreach my $ref(@$analog)
{
	my $port_type = $ref->{'mnemonic'};
	my $price     = $ref->{'price'};
	if ($reseller)
	{
		$price = sprintf("%.2f", $price);	# format decimals correctly for resellers who get a discount
	}
	$js_array .= "hashAnalogPrice[\"pci|3|$port_type\"] = '$price';\n";
	$js_array .= "hashAnalogPrice[\"pcie|3|$port_type\"] = '$price';\n";
}

$vars->{'JS_ARRAY_SERVER_ANALOG_PRICES'} = $js_array;


# create an array of the EXPANSION SLOT CARDS
# prices used by the Live Backup Server price calculation
$js_array = "\nvar hashT1CARDs = new Array();\n";
$js_array2 = "\nvar hashT1CARDsPrice = new Array();\n";
my $arefCards = F::Order::get_reseller_items($dbh,$reseller_id,'Cards - Digital',1);
# also get the T1 Setup Fee (Resellers aren't charged for this fee)
my $t1_setup_fee;
unless ($reseller)
{
	$t1_setup_fee = get_reseller_item($dbh,$dynamic_item_IDs->{'T1_SETUP'},$reseller_id);
	$t1_setup_fee = $t1_setup_fee->{'price'};
}
my %t1cards;
foreach my $ref (@$arefCards)
{
	my $item_id = $ref->{'item_id'};
	my $item_name = $ref->{'name'};
	my $price     = $ref->{'price'};
	if ($reseller)
	{
		$price = sprintf("%.2f", $price);	# format decimals correctly for resellers who get a discount
	}
	else
	{
		# add the T1 Setup Fee for non-resellers
		$price += $t1_setup_fee;
		$item_name . " w/Setup";
	}
	$js_array  .= "hashT1CARDs[\"$item_id\"] = \"$item_name\";\n";
	$js_array2 .= "hashT1CARDsPrice[\"$item_id\"] = '$price';\n";
}
$vars->{'JS_ARRAY_EXPANSION_CARDS'} = $js_array;
$vars->{'JS_ARRAY_EXPANSION_CARD_PRICES'} = $js_array2;





# get the server config options
my $config_options = F::Order::get_server_config_options($dbh);
# save as a Javascript array
$js_array = "\nvar configOptions = new Array();\n";
my $dummy_ram = 124;
my $dummy_cpu = 143;
foreach my $option (@$config_options)
{
	$js_array .= 'configOptions["' . $option->{'server_config_option_id'} . '"] = ';
	$js_array .= '[' . $option->{'base_assembly_id'} . ',' . ($option->{'required_ram_item_id'} || $dummy_ram) . ',';
	$js_array .= ($option->{'required_cpu_item_id'} || $dummy_cpu) . "];\n";
}
$vars->{'JS_ARRAY_CONFIG_OPTIONS'} = $js_array;





# get the config option connectivity allowances
my $config_connectivity = F::Order::get_server_config_connectivity($dbh);
# save as a Javascript array
$js_array = "\nvar connectivity = new Array();\n";
my $total_cnt = 1;
foreach my $option (@$config_connectivity)
{
	$js_array .= 'connectivity["' . $total_cnt . '"] = ';
	$js_array .= '[' . $option->{'server_config_option_id'} . ',{';
	foreach my $card_type (@{$option->{'cards'}})
	{
		$js_array .= $card_type->{'card_type'} . ':' . $card_type->{'card_max'} . ',';
	}
	$js_array =~ s/,$//;
	$js_array .= "}];\n";
	$total_cnt++;
}
$vars->{'JS_ARRAY_CONNNECTIVITY'} = $js_array;




$js_array = "\nvar hashRhinos = new Array();\n";
$js_array2 = "\nvar hashRhinosPrice = new Array();\n";
my $rhino_base = get_reseller_item($dbh,$dynamic_item_IDs->{'RHINO_BASE'},$reseller_id);
my $rhino_FXO  = get_reseller_item($dbh,$dynamic_item_IDs->{'RHINO_FXO'},$reseller_id);  # module of 4 FXO ports
my $rhino_FXS  = get_reseller_item($dbh,$dynamic_item_IDs->{'RHINO_FXS'},$reseller_id);  # module of 4 FXS ports
my @rhinos = ();
for (my $x=0; $x <= 6; $x++)
{
	for (my $y=0; $y <= 6; $y++)
	{
		# create the dropdown list manually for all combinations of ports up to a maximum of 24
		my $key = "$x-$y";
		next if ($key eq '0-0'); # let the template create a NONE SELECTED option
		my $cntFXO = $x * 4;
		my $cntFXS = $y * 4;
		next if (($cntFXO + $cntFXS) > 24); # no more than 24 ports per channel bank
		my $rhino_price = $rhino_base->{'price'} + ($rhino_FXO->{'price'} * $x) + ($rhino_FXS->{'price'} * $y);
		my $item_id   = "$y-$x";
		my $item_name = "$cntFXS FXS/$cntFXO FXO Channel Bank" ;
		my $price     = $rhino_price;
		if ($reseller)
		{
			$price = sprintf("%.2f", $price);	# format decimals correctly for resellers who get a discount
		}
		$js_array  .= "hashRhinos[\"$item_id\"] = \"$item_name\";\n";
		$js_array2 .= "hashRhinosPrice[\"$item_id\"] = '$price';\n";
	}
}
$vars->{'JS_ARRAY_RHINOS'} = $js_array;
$vars->{'JS_ARRAY_RHINOS_PRICES'} = $js_array2;


# get a list of SERVER information
my $servers = get_servers($dbh);
my $js_array = "\nvar hashServerSupportsFXS = new Array();\n";
foreach my $server (@$servers)
{
	$js_array .= 'hashServerSupportsFXS["' . $server->{'item_id'} . '"] = "' . $server->{'supports_fxs'} . '";' . "\n";
}
$vars->{'JS_ARRAY_SERVERS_SUPPORT_FXS'} = $js_array;


# process the javascript template file
print "Pragma: no-cache\r\n";
print "Cache-control: no-cache\r\n";
print "Expires: 0\r\n";
F::Util::show_template($q, $vars, $file, 1);


#############################################################################
#	Determine TT directory path and lead source variable by source
#############################################################################
sub affiliate_update
{
	my $q = shift(@_);
	my $vars = shift(@_);

	my $source = $q->param('src');
	$source =~ s/\W//g;
	my $ttpath = (-e $source ? $source : '.');

	$vars->{'TT_DIR'} = $ttpath;

	if($ttpath eq 'pbxtra')
	{
		$vars->{'PBXTRA'} = 1;
	}
	elsif($source eq 'unboundadd')
	{
	    $ttpath = 'unbound';
	    $vars->{'TT_DIR'} = $ttpath;
	    $vars->{'UNBOUNDADD'} = 1;
	}
	else
	{
		$ttpath = 'pbxtra';
		$vars->{'PBXTRA'} = 1;
	}

	return $ttpath;
}
1;
