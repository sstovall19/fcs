// GLOBAL vars
var ram_upgrade;
var raid_upgrade;
var cpu_upgrade;
var item_slot1;
var power_upgrade;

var totalPhones = 0;

var quadT1_item_ID = 46;
var per_seat_licensing_fee = [% PER_SEAT_LICENSING_FEE %];
var server_config_option_id;

[% JS_ARRAY_EDITIONS %]
[% JS_ARRAY_EDITIONS_PRICES %]
[% JS_ARRAY_HUD %]
[% JS_ARRAY_HUD_PRICES %]
[% JS_ARRAY_SERVERS %]
[% JS_ARRAY_SERVERS_PRICES %]
[% JS_ARRAY_REDUNDANCY %]
[% JS_ARRAY_REDUNDANCY_PRICES %]
[% JS_ARRAY_REDUNDANCY_RELATION %]
[% #JS_ARRAY_CPU %]
[% #JS_ARRAY_CPU_PRICES %]
[% #JS_ARRAY_WARRANTY %]
[% #JS_ARRAY_WARRANTY_PRICES %]
[% #JS_ARRAY_POWER %]
[% #JS_ARRAY_POWER_PRICES %]
[% #JS_ARRAY_RAM %]
[% #JS_ARRAY_RAM_PRICES %]
[% #JS_ARRAY_RAID %]
[% #JS_ARRAY_RAID_PRICES %]
[% JS_ARRAY_SERVER_ANALOG %]
[% JS_ARRAY_SERVER_ANALOG_PRICES %]
[% JS_ARRAY_EXPANSION_CARDS %]
[% JS_ARRAY_EXPANSION_CARD_PRICES %]
[% JS_ARRAY_CONFIG_OPTIONS %]
[% JS_ARRAY_CONNNECTIVITY %]
[% JS_ARRAY_SERVERS_SUPPORT_FXS %]
[% JS_ARRAY_RHINOS %]
[% JS_ARRAY_RHINOS_PRICES %]


var hashPhones = new Array();
var hashPhonesPrice = new Array();
[%### UNBOUNDADD: UNBOUNDADD ###%]
[%### RENTAL_PHONES: RENTAL_PHONES ###%]

[% IF UNBOUNDADD %]
	[% UNLESS RENTAL_PHONES %]
		[% FOREACH PHONE = PHONES %]
			[% IF PHONE.item_id == SOFTPHONE_BUNDLE_ITEM_ID ||
			      PHONE.item_id == POLYCOM_331_ITEM_ID      ||
			      PHONE.item_id == POLYCOM_560_ITEM_ID      ||
			      PHONE.item_id == AASTRA_480I_CT_ITEM_ID   ||
			      PHONE.item_id == UNBOUND_REPROVISIONING_ITEM_ID
			%]
hashPhones["phone_[% PHONE.item_id %]"] = 0;
hashPhonesPrice["phone_[% PHONE.item_id %]"] = [% PHONE.price %];

			[% END %]
		[% END %]
	[% END %]
	[% FOREACH RENTAL = UNBOUND_PHONE_RENTALS %]
		[% IF RENTAL.item_id == RENTAL_SOFTPHONE_BUNDLE_ITEM_ID ||
		      RENTAL.item_id == RENTAL_BUDGETONE_200_ITEM_ID    ||
		      RENTAL.item_id == RENTAL_GXP2000_ITEM_ID          ||
		      RENTAL.item_id == RENTAL_POLYCOM_331_ITEM_ID      ||
		      RENTAL.item_id == RENTAL_POLYCOM_450_ITEM_ID      ||
		      RENTAL.item_id == RENTAL_POLYCOM_550_ITEM_ID      ||
		      RENTAL.item_id == RENTAL_POLYCOM_560_ITEM_ID      ||
		      RENTAL.item_id == RENTAL_POLYCOM_6000_ITEM_ID     ||
		      RENTAL.item_id == RENTAL_AASTRA_480I_CT_ITEM_ID
		%]
hashPhones["phone_[% RENTAL.item_id %]"] = 0;
hashPhonesPrice["phone_[% RENTAL.item_id %]"] = [% RENTAL.price %];

		[% END %]
	[% END %]
[% ELSE %]
	[% FOREACH PHONE = PHONES %]
		hashPhones["phone_[% PHONE.item_id %]"] = 0;
		hashPhonesPrice["phone_[% PHONE.item_id %]"] = [% PHONE.price %];
	[% END %]
	hashPhones["phone_[% REPROVISIONED_PHONE.item_id %]"] = 0; // RE-PROVISIONED PHONES
	hashPhonesPrice["phone_[% REPROVISIONED_PHONE.item_id %]"] = [% REPROVISIONED_PHONE.price %];
	hashPhones["phone_[% REMOTE_REPROVISIONED_PHONE.item_id %]"] = 0; // REMOTE RE-PROVISIONED PHONES
	hashPhonesPrice["phone_[% REMOTE_REPROVISIONED_PHONE.item_id %]"] = [% REPROVISIONED_PHONE.price %];
[% END %]

var hashLinkedServers = new Array();
hashLinkedServers["[% LINKED_ITEM_ID %]"] = "Server is linked [+ $[% LINKED_FEE %]]";
hashLinkedServers["[% LINKED_CCE_ITEM_ID %]"] = "Server is linked (Call Center Edition) [+ $[% LINKED_CCE_FEE %]]";

var hashLinkedServersPrice = new Array();
hashLinkedServersPrice["[% LINKED_ITEM_ID %]"] = [% LINKED_FEE %];
hashLinkedServersPrice["[% LINKED_CCE_ITEM_ID %]"] = [% LINKED_CCE_FEE %];

[% IF UNBOUND OR UNBOUNDADD %]
	var hashUnboundLinkedServers = new Array();
	hashUnboundLinkedServers["[% UNBOUND_SE_ITEM_ID %]"]  = "Server is linked (Standard Edition) [+ $[% UNBOUND_LINKED_SE_PRICE %]]";
	hashUnboundLinkedServers["[% UNBOUND_PE_ITEM_ID %]"]  = "Server is linked (Professional Edition) [+ $[% UNBOUND_LINKED_PE_PRICE %]]";
	hashUnboundLinkedServers["[% UNBOUND_CCE_ITEM_ID %]"] = "Server is linked (Call Center Edition) [+ $[% UNBOUND_LINKED_CCE_PRICE %]]";

	var hashUnboundLinkedServersPrice = new Array();
	hashUnboundLinkedServersPrice["[% UNBOUND_SE_ITEM_ID %]"]  = [% UNBOUND_LINKED_SE_PRICE %];
	hashUnboundLinkedServersPrice["[% UNBOUND_PE_ITEM_ID %]"]  = [% UNBOUND_LINKED_PE_PRICE %];
	hashUnboundLinkedServersPrice["[% UNBOUND_CCE_ITEM_ID %]"] = [% UNBOUND_LINKED_CCE_PRICE %];

	var hashUnboundLinkedServersIDs = new Array();
	hashUnboundLinkedServersIDs["[% UNBOUND_SE_ITEM_ID %]"]  = [% UNBOUND_LINKED_SE_ITEM_ID %];
	hashUnboundLinkedServersIDs["[% UNBOUND_PE_ITEM_ID %]"]  = [% UNBOUND_LINKED_PE_ITEM_ID %];
	hashUnboundLinkedServersIDs["[% UNBOUND_CCE_ITEM_ID %]"] = [% UNBOUND_LINKED_CCE_ITEM_ID %];
[% END %]

[% PHONE_PORTS %]
[% SUPPORT_TIERS %]
[%# below added by pgoddard 2009.03.12  %]
// Create new array of the keys from hashSupportTiers
// to determine correct order when looping
// to prevent wierdness in Safari, which REorders above array
var supportTeirKeys = new Array();
for(k in hashSupportTiers) {
	supportTeirKeys.push(k);
}
supportTeirKeys.sort( function (a, b){return (a-b);});
hashSupportTiers.sort(function(a,b) { return b-a });


// calculates the Analog Card price based on user input (for Display purposes)
function calculateAnalogCardsPrice()
{
	var index = document.form.accessory_fxo_card.selectedIndex;
	var fxo   = parseInt(document.form.accessory_fxo_card.options[index].value);
	index     = document.form.accessory_fxs_card.selectedIndex;
	var fxs   = parseInt(document.form.accessory_fxs_card.options[index].value);

	var dis_fxo = fxo;
	var dis_fxs = fxs;

	index     = document.form.item_server_hardware.selectedIndex;
	index     = document.form.item_server_hardware.options[index].value;
	var card_type = hashServerAnalogType[index];

	var ec_type   = document.form.accessory_analog_echo.checked ? 1 : 0;
	var dis_ec = ec_type;
	ec_type = "echw" + ec_type;


	var total_cards = Math.ceil((fxo + fxs) / 4);
	var total_price = 0;
	for(var i = 1; i <= total_cards; i++)
	{
		//how many (4fxo, fxs) cards?
		if(parseInt(fxo/4))
		{
			index = card_type + "|" + i + "|" + ec_type + "|fxo4|fxs0";
			total_price += parseFloat(hashAnalogPrice[index], 10);
			fxo -= 4;
		}
		// is there a mixed card (2,0), (2,2)
		else if(fxo % 4 && (fxo || fxs))
		{
			index = fxs > 0 ? 2 : 0;
			fxs -= index;

			index = "fxo" + fxo % 4 + "|" + "fxs" + index;
			index = card_type + "|" + i + "|" + ec_type + "|" + index;
			total_price += parseFloat(hashAnalogPrice[index], 10);

			fxo -= (fxo % 4);
		}

		else if(parseInt(fxs/4))
		{
			index = card_type + "|" + i + "|" + ec_type + "|fxo0|fxs4";
			total_price += parseFloat(hashAnalogPrice[index], 10);
			fxs -= 4;
		}
		else if(fxs % 4)
		{
			index = card_type + "|" + i + "|" + ec_type + "|fxo0|fxs2";
			total_price += parseFloat(hashAnalogPrice[index], 10);
			fxs -= (fxs % 4);
		}
	}

	return { price : total_price, fxo : dis_fxo, fxs : dis_fxs, ec : dis_ec };
}


// business rules for the RAID upgrades
function selectRAID(indexID)
{
	// save the RAID value in case another selection disables the drop-down list
	raid_upgrade = indexID;

//	// update the Live Backup Server price
//	_change_item_upgrade_redundancy(document.form.item_upgrade_redundancy[1].value);
}

// business rules for the RAM upgrades
function selectRAM(indexID)
{
	if(document.form.item_upgrade_ram != null)
	{
		// save the RAM value in case another selection disables the drop-down list
		ram_upgrade = indexID;

		// look at all the Config Options to find out which Option ID has been selected
		setDefaultConfigOption();

		// update the card options
		_change_item_slots();

//		// update the Live Backup Server price
//		_change_item_upgrade_redundancy(document.form.item_upgrade_redundancy[1].value);
	}
}

// business rules for the CPU upgrades
function selectCPU(indexID)
{
	if(document.form.item_upgrade_cpu != null)
	{
		// save the CPU value in case another selection requires this be set to NOT AVAILABLE
		cpu_upgrade = indexID;

		// look at all the Config Options to find out which Option ID has been selected
		setDefaultConfigOption();
	
		// update the card options
		_change_item_slots();

//		// update the Live Backup Server price
//		_change_item_upgrade_redundancy(document.form.item_upgrade_redundancy[1].value);
	}
}

// business rules for the Redundant Power Supply upgrades
function selectPower(indexID)
{
	if(document.form.item_upgrade_power != null)
	{
		// save the Redundant Power Supply value in case another selection requires this be set to NOT AVAILABLE
		power_upgrade = indexID;

//		// update the Live Backup Server price
//		_change_item_upgrade_redundancy(document.form.item_upgrade_redundancy[1].value);
	}
}


var connectivityProblem = false;	// this will be true if an invalid connectivity choice was selected when the form is submitted 

// business rules for the Expansion Cards select menus
// verify the selected connectivity cards will work with the current server configuration
function selectSlot(select_field)
{
	// get the connectivity cards the customer has selected
	var selected_cards = new Array();
	for (card_item_id in hashT1CARDs)
	{
		selected_cards[card_item_id] = 0;	//prepopulate with zeros
	}
	// get both T1 card selections
	var selected_t1_1 = document.form.item_slot1[document.form.item_slot1.selectedIndex].value || 0;
	if (selected_t1_1 > 0)
	{
		selected_cards[selected_t1_1] = selected_cards[selected_t1_1] + 1;	// get the value if a T1 is selected
	}
	var selected_t1_2 = 0;
	// get the combined total of FXS/FXO ports
	var select_FXO = document.form.accessory_fxo_card.value || 0;
	var select_FXS = document.form.accessory_fxs_card.value || 0;
	// 152 is the old Sangoma card and is used here only as part of the connectivity machine
	selected_cards["152"] = parseInt(select_FXO) + parseInt(select_FXS);

	// look through all connectivity options that match the selected server_config_option_id
	var valid_selections = 0;
	for (conn in connectivity)
	{
		if (connectivity[conn][0] != server_config_option_id) continue;
		var found_error = 0;	// reset for each set of connectivity options
		for (card_type in connectivity[conn][1])
		{
			if (selected_cards[card_type] > connectivity[conn][1][card_type])
			{
				found_error = 1;	// more of this connectivity type than is allowed was selected
			}
		}
		for (card_type in selected_cards)
		{
			if (selected_cards[card_type] < 1) continue;
			if (typeof connectivity[conn][1][card_type] == "undefined")
			{
				found_error = 1;	// a card not in this connectivity group was selected
			}
		}
		if (! found_error)
		{
			valid_selections = 1;	// this was a valid selection
			break;	// stop looking
		}
	}

	if (! valid_selections)
	{
		if (selected_t1_1 > 0 || selected_t1_2 > 0)
		{
			alert("This combination of T1 and Analog Lines/Ports is not supported\nby this Server with the selected CPU and RAM.");
		}
		else if (selected_cards["analog_card"] > 12)
		{
			alert("PBXtra servers do not support more than 12 total internal analog lines and ports.");
		}
		else
		{
			alert("This number of Analog Lines/Ports is not supported\nby this Server with the selected CPU and RAM.");
		}

		if (select_field == "item_slot1")
		{
			document.form.item_slot1.selectedIndex = 0;
		}
		else if (select_field == "accessory_fxo_card")
		{
			document.form.accessory_fxo_card.value = "0";
		}
		else if (select_field == "accessory_fxs_card")
		{
			document.form.accessory_fxs_card.value = "0";
		}
		else if (select_field == "check_all")
		{
			// do not change the T1 cards - other methods will unselect inappropriate T1 cards (i.e. selectServer)
			document.form.accessory_fxo_card.value = "0";
			document.form.accessory_fxs_card.value = "0";
		}
		connectivityProblem = true;

		_set_analog_echo(); // disable or enable HW echo cancellation option
		_verify_voip_timing_card(); // disable or enable VoIP timing card
		return false;
	}

	_set_analog_echo(); // disable or enable HW echo cancellation option

	// update the Maintenance & Support
	_update_support_price();

//	// update the Live Backup Server price
//	_change_item_upgrade_redundancy(document.form.item_upgrade_redundancy[1].value);

	// if a T1 w/o HW EC was selected
	if (select_field == "item_slot1" &&
		( selected_t1_1 == 44  || selected_t1_2 == 44  ||
		  selected_t1_1 == 598 || selected_t1_2 == 598 ))
	{
		alert("Hardware-based Echo Cancellation (HWEC) is superior to software based alternatives and frees your processor from additional workload. We recommend you select the Single Span T1 w/HWEC for superior call quality.");
	}
	else
	{
		_recommend_HW_EC(select_field);	// recommend Echo Cancellation for Analog Phone Line
	}

	_check_T1_fax_timing_cable_requirements()
	_verify_voip_timing_card(); // disable or enable VoIP timing card
	return true;
}

function _verify_voip_timing_card()
{
	// disable VoIP Timing Card option if another card is selected - otherwise enable it
	if (document.form.item_slot1[document.form.item_slot1.selectedIndex].value == 0 &&
		document.form.accessory_fxo_card.value                                 == 0 &&
		document.form.accessory_fxs_card.value                                 == 0	)
	{
		document.form.accessory_voip_timing_card.disabled = false;
	}
	else
	{
		document.form.accessory_voip_timing_card.disabled = true;
		document.form.accessory_voip_timing_card.checked  = false;
	}
}

// test requirements for the "Send faxes over T1" option
function _check_T1_fax_timing_cable_requirements()
{
	var selectedT1ID = document.form.item_slot1[document.form.item_slot1.selectedIndex].value;
	if (document.form.accessory_fxs_card.selectedIndex > 0 && 
		(selectedT1ID == 45 || selectedT1ID == 46 || selectedT1ID == 205 || selectedT1ID == 475 || selectedT1ID == 477 || selectedT1ID == 586))
	{
		document.form.accessory_fax_timing_cable.disabled = false;
	}
	else
	{
		document.form.accessory_fax_timing_cable.disabled = true;
		document.form.accessory_fax_timing_cable.checked  = false;
	}
	return true;
}

// disable shipping state if country != United States
function select_shipping_country()
{
	var shipping_country = document.form.shipping_country[document.form.shipping_country.selectedIndex].value;
	if (shipping_country == "United States")
	{
		document.form.shipping_state.disabled = false;
		_removeMyOptions(document.form.shipping_service);
		// now rewrite the options
		document.form.shipping_service.options[0] = new Option('UPS Ground', 'GROUND');
		document.form.shipping_service.options[1] = new Option('UPS 3 Day Select', '3_DAY_SELECT');
		document.form.shipping_service.options[2] = new Option('UPS 2nd Day Air', '2ND_DAY_AIR');
		document.form.shipping_service.options[3] = new Option('UPS Next Day Air', 'NEXT_DAY_AIR');
		document.form.shipping_service.options[4] = new Option('UPS Next Day Air Early AM', 'NEXT_DAY_AIR_EARLY_AM');
//		document.form.shipping_service.options[5] = new Option('UPS Standard', 'STANDARD');
	}
	else
	{
		document.form.shipping_state.disabled = true;
		_removeMyOptions(document.form.shipping_service);
		// now rewrite the options
		document.form.shipping_service.options[0] = new Option('UPS Worldwide Expedited', 'WORLDWIDE_EXPEDITED');
		document.form.shipping_service.options[1] = new Option('UPS Worldwide Express', 'WORLDWIDE_EXPRESS');
	}
	// default the selected field to slow-boat
	document.form.shipping_service.selectedIndex = 0;
}

// recommend Echo Cancellation for Analog Phone Line
function _recommend_HW_EC(select_field)
{
	if (select_field == "accessory_fxo_card")
	{
		if (document.form.accessory_fxo_card.value > 0 && document.form.accessory_analog_echo.checked == false)
		{
			alert("Hardware-based Echo Cancellation (HWEC) is superior to software based alternatives and frees your processor from additional workload. We recommend you also select Analog Echo Cancellation when you select Analog Phone Lines.");
		}
	}
}

function selectEchoCancellation()
{
//	// update the Live Backup Server price
//	_change_item_upgrade_redundancy(document.form.item_upgrade_redundancy[1].value);

	// recommend Echo Cancellation for Analog Phone Line
	_recommend_HW_EC("accessory_fxo_card");
}

// returns the computed css style of a given element object
function _get_computed_style(element)
{
	// Mozilla
	if(window.getComputedStyle)
		return window.getComputedStyle(element,null);
	// IE
	else if(element.currentStyle)
		return element.currentStyle;
}

// unselect and disable the Analog Echo Cancellation if there are no selected Analog Lines or Ports
function _set_analog_echo()
{
	// if the input accessory_analog_echo is not visible, we should not disable it. This function implies visibility
	// thus return if accessory_analog_echo is invisible
	if(_get_computed_style(document.form.accessory_analog_echo).display == 'none')
		return;
		
	var fxo_ports = document.form.accessory_fxo_card.value || 0;
	var fxs_ports = document.form.accessory_fxs_card.value || 0;
	if (fxo_ports == 0 && fxs_ports == 0)
	{
		document.form.accessory_analog_echo.disabled = true;
		document.form.accessory_analog_echo.checked  = false;
	}
	else
	{
		document.form.accessory_analog_echo.disabled = false;
	}
}

// business rules for the Software Edition select menu
function selectSoftwareEdition(software_type)
{
	// change the Servers Linked based on the software edition selected
	if (software_type == [% PBXTRA_CALL_CENTER_ID %] || software_type == [% PBXTRA_UNIFIED_AGENT_ID %])
	{
		// PBXtra UNIFIED AGENT -- ONLY WORKS WITH HUD AGENT
		var item_server_hud_value = document.form.item_server_hud[document.form.item_server_hud.selectedIndex].value;
		// Call Center or Unified Agent linking
		_change_item_server_can_link([% LINKING_SOFTWARE_CALL_CENTER_ID %]);
		// UAE requires HUD Agent
		if (software_type == [% PBXTRA_UNIFIED_AGENT_ID %]   &&
			item_server_hud_value != [% HUD_AGENT_ITEM_ID %] &&
			item_server_hud_value != [% HUD_QUEUES_UNDER20_ITEM_ID %] &&
			item_server_hud_value != [% HUD_QUEUES_OVER20_ITEM_ID %]	)
		{
			alert("PBXtra Unified Agent requires the purchase of HUD Agent or HUD Queues");
			// select HUD Agent
			document.form.item_server_hud.selectedIndex = 2;
			return;
		}
	}
	else
	{
		// Standard or Professional linking
		_change_item_server_can_link([% LINKING_SOFTWARE_STANDARD_ID %]); // Standard or Professional linking
		if (document.form.item_server_hud[document.form.item_server_hud.selectedIndex].value == [% HUD_AGENT_ITEM_ID %])
		{
			alert("Certain HUD Agent features require the purchase of PBXtra Call Center Edition or PBXtra Unified Agent Edition. For more information, please review the Fonality Products page or contact your sales representative.");
		}
		else if (document.form.item_server_hud[document.form.item_server_hud.selectedIndex].value == [% HUD_QUEUES_UNDER20_ITEM_ID %] ||
				 document.form.item_server_hud[document.form.item_server_hud.selectedIndex].value == [% HUD_QUEUES_OVER20_ITEM_ID %]	)
		{
			alert("HUD Queues requires the purchase of PBXtra Call Center Edition or PBXtra Unified Agent Edition. To change your PBXtra Edition selection, please change HUD first.");
			document.form.item_software_edition.selectedIndex = 2;
		}
	}
}

var selectedHUD;

// business rules for the HUD select menu
function selectHUD(hud_type)
{
	var item_software_edition_value = document.form.item_software_edition[document.form.item_software_edition.selectedIndex].value;
	// change the Servers Linked based on the software edition selected
	if (hud_type == [% HUD_AGENT_ITEM_ID %])
	{
		if (item_software_edition_value == [% PBXTRA_STANDARD_ID %] || item_software_edition_value == [% PBXTRA_PROFESSIONAL_ID %])
		{
			alert("Certain HUD Agent features require the purchase of PBXtra Call Center Edition or PBXtra Unified Agent Edition. For more information, please review the Fonality Products page or contact your sales representative.");
		}
	}
	else if (hud_type == [% HUD_QUEUES_UNDER20_ITEM_ID %] || hud_type == [% HUD_QUEUES_OVER20_ITEM_ID %])
	{
		if (item_software_edition_value == [% PBXTRA_STANDARD_ID %] || item_software_edition_value == [% PBXTRA_PROFESSIONAL_ID %])
		{
			alert("HUD Queues requires the purchase of PBXtra Call Center Edition or PBXtra Unified Agent Edition. For more information, please review the Fonality Products page or contact your sales representative.");
			// reset to last valid setting
			document.form.item_server_hud.selectedIndex = selectedHUD;
		}
	}
	else
	{
		if (item_software_edition_value == [% PBXTRA_UNIFIED_AGENT_ID %])
		{
			// select HUD Agent again
			alert("PBXtra Unified Agent requires the purchase of HUD Agent or HUD Queues. To change your HUD selection, please change the PBXtra Edition first.");
			document.form.item_server_hud.selectedIndex = 2;
		}
	}

	// save the currently selected HUD edition in case we need to roll back to it, e.g. customer selects an invalid setting
	selectedHUD = document.form.item_server_hud.selectedIndex;
}

function selectServer(server_type)
{
	// set the server config option ID - the combination of selected Server, CPU and RAM Item IDs 
	setDefaultConfigOption();
	// change the Expansion Card options
	_change_item_slots();

	// Dell 1U Basic
	if (server_type == [% DELL_1U_BASIC_SERVER_ID %])
	{
		document.getElementById("bundle_warranty").innerHTML = '3-year Dell Pro Support, NBD Onsite, 24/7 phone';
		document.getElementById("bundle_cpu").innerHTML      = 'Intel Core I3 540 3.06Ghz, 4M Cache';
		document.getElementById("bundle_ram").innerHTML      = '2GB, 1333MHz UDIMM';
		document.getElementById("bundle_hd").innerHTML       = 'Dual Hotplug 500GB 3.5" SATA, 7.2k RPM, Hardware RAID 1';
		document.getElementById("bundle_power").innerHTML    = 'Redundant 400W';
	}
	else
	{
		// Dell Mini Tower
		document.getElementById("bundle_warranty").innerHTML = '3-year Dell Pro Support, NBD Onsite, 24/7 phone';
		document.getElementById("bundle_cpu").innerHTML      = 'Intel Pentium Dual Core E5300 2.6GHz, 2M Cache';
		document.getElementById("bundle_ram").innerHTML      = '1GB, 1333MHz DDR3';
		document.getElementById("bundle_hd").innerHTML       = 'Dual 160GB 3.5" SATA, Software RAID';
		document.getElementById("bundle_power").innerHTML    = '300W';
	}
	
	// enable or disable the FXS ports as appropriate
	if (hashServerSupportsFXS[server_type] == "1")
	{
		document.form.accessory_fxs_card.disabled = false;
	}
	else
	{
		document.form.accessory_fxs_card.disabled = true;
		document.form.accessory_fxs_card.value    = 0;
	}
	_change_item_upgrade_redundancy(server_type);
	selectSlot("check_all");

}


// throw an error if a non-number is entered and strip it from the end of the text field
// (assumed to be running on onKeyUp)
function removeNonNumbers(fieldName)
{
	if (!document.form[fieldName])
		return;

	if (document.form[fieldName].value != '')
	{
		var parsed_phone = Math.floor(parseInt(document.form[fieldName].value),10);
		if (isNaN(parsed_phone))
			parsed_phone = 0;
		document.form[fieldName].value = parsed_phone;
	}
}


// global values for handling reseller phone configuration fees
var reseller_phones_provisioning_price = 0;
var fonality_phones_provisioning_price = 0;

// the user has entered a new value in one of the phone text boxes
function recalculatePhoneCnt(init_value)
{
	init_value = init_value || 0;
	totalFonalityPhones      = 0;
	totalReprovisionedPhones = 0;
	for (phone in hashPhones)
	{
		if (!document.form[phone])
		{
			continue;
		}
		removeNonNumbers(phone);

		hashPhones[phone] = Number(document.form[phone].value);
		if (phone == 'phone_[% REPROVISIONED_PHONE_ID %]' || phone == 'phone_[% REMOTE_REPROVISIONED_PHONE_ID %]')
		{
			totalReprovisionedPhones = totalReprovisionedPhones + hashPhones[phone];
		}
		else if (phone != 'phone_1431' && phone != 'phone_1430')
		{
			// do not increment phones if this is a Kirk KWS300 base or a Polycom 650 Sidecar
			totalFonalityPhones = totalFonalityPhones + hashPhones[phone];
		}
	}

	var fonalityConfiguredPhones = 1;

	// These fields don't exist on the unbound order tool
	if (document.getElementById("phone_cnt"))
	{
		document.getElementById("phone_cnt").innerHTML        = totalFonalityPhones + totalReprovisionedPhones;
	}
	if (document.getElementById("per_seat_lic_fee"))
	{
		document.getElementById("per_seat_lic_fee").innerHTML = (totalFonalityPhones + totalReprovisionedPhones) * per_seat_licensing_fee;
	}

	[% IF RESELLER %]
		// determine the value of Reseller Phone Provisioning Fees/Credits
		if (fonalityConfiguredPhones == 1)
		{
			fonality_phones_provisioning_price = round([% RESELLER_FEE_FONALITY_CONFIG_FONALITY_PHONES_PRICE %], 2);
			document.getElementById("fonality_phones_provisioning_price").innerHTML = round([% RESELLER_FEE_FONALITY_CONFIG_FONALITY_PHONES_PRICE %], 2);
			reseller_phones_provisioning_price = round([% RESELLER_FEE_FONALITY_CONFIG_RESELLER_PHONES_PRICE %], 2);
			document.getElementById("reseller_phones_provisioning_price").innerHTML = round([% RESELLER_FEE_FONALITY_CONFIG_RESELLER_PHONES_PRICE %], 2);
		}
		else if (fonalityConfiguredPhones == 0)
		{
			reseller_phones_provisioning_price = round([% RESELLER_CREDIT_RESELLER_CONFIG_RESELLER_PHONES_PRICE %], 2);
			fonality_phones_provisioning_price = round([% RESELLER_CREDIT_RESELLER_CONFIG_FONALITY_PHONES_PRICE %], 2);
			document.getElementById("reseller_phones_provisioning_price").innerHTML = round([% RESELLER_CREDIT_RESELLER_CONFIG_RESELLER_PHONES_PRICE %], 2);
			document.getElementById("fonality_phones_provisioning_price").innerHTML = round([% RESELLER_CREDIT_RESELLER_CONFIG_FONALITY_PHONES_PRICE %], 2);
		}

		// recalculate the total prices - round and divided to get exactly 2 decimal places
		var fonality_phones_total = fonality_phones_provisioning_price * totalFonalityPhones;
		fonality_phones_total = round(fonality_phones_total, 2);
		document.getElementById("fonality_phones_provisioning_total").innerHTML = fonality_phones_total;
		var reseller_phones_total = reseller_phones_provisioning_price * totalReprovisionedPhones;
		reseller_phones_total = round(reseller_phones_total, 2);
		document.getElementById("reseller_phones_provisioning_total").innerHTML = reseller_phones_total;
		document.getElementById("phone_cnt_2").innerHTML                        = totalFonalityPhones;
		document.getElementById("phone_cnt_3").innerHTML                        = totalReprovisionedPhones;
	[% END %]

	totalPhones = totalFonalityPhones + totalReprovisionedPhones;

	[% IF UNBOUND OR UNBOUNDADD %]
		// update the default number of DIDs
		document.getElementById("default_unbound_dids").innerHTML = init_value || totalPhones;
	[% ELSE %]
		// update the Maintenance & Support
		_update_support_price();
	[% END %]
}

function round(n, d)
{
	// round number n to d decimal places
	return (Math.round(n*Math.pow(10,d))/Math.pow(10,d)).toFixed(d);
}


// pop an alert message when a user checks the "I am currently a Fonality reseller" checkbox
function possible_reseller_checkbox()
{
	// uncheck the box - the user should not think they can pretend to be a Reseller
	document.form.possible_reseller.checked = false;
	var reseller_msg  = "Our system cannot find your reseller cookie. " +
						"This means we cannot validate that you are actually a Fonality reseller. " +
						"To correct this, please login to the reseller area now. " +
						"This can be done by clicking \"RESELLERS\" at the top of this page. " +
						"If you cannot remember your reseller username and password please send an email to resellers@fonality.com. " +
						"Once you are logged in, please reload this page and create a new quote.";
	alert(reseller_msg);
}

// the user has checked the "I want to learn more about the Fonality Reseller Program" checkbox
function reseller_interest_checkbox()
{
	var reseller_msg  = "We are thrilled that you want to learn more about the Fonality Reseller Program. " +
						"However, please note:\n\n" +
						"1. Fonality does not offer reseller discounts on your first order.\n\n" +
						"2. A Fonality Reseller Manager *will* be contacting you to discuss the program and how it might work for you. " +
						"This qualification process is required and may slow down your order.";
	if (document.form.reseller_interest.checked == true)
	{
		alert(reseller_msg);
	}
}

// internal use only - update the total number of Phones & Ports 
function _update_support_price()
{
	// add the number of Phones to the Port Cnt
	var phoneCnt = 0;
	if (document.getElementById("phone_cnt").innerHTML > 0)
	{
		phoneCnt = parseInt(document.getElementById("phone_cnt").innerHTML);
	}

	// add the number of FXS Ports to the Port Cnt
	var portCnt = 0;
	if (document.form.accessory_fxs_card.value > 0)
	{
		portCnt = parseInt(document.form.accessory_fxs_card.value);
	}

	// add Rhino Channel Bank FXS -- if any
	var rhino_fxs = document.form.accessory_rhino.value.substr(0,1) || 0;
	rhino_fxs = rhino_fxs * 4; // Rhino FXS ports come in packages of 4
	portCnt += parseInt(rhino_fxs);

	// determine the support tier
	var total_devices = phoneCnt + portCnt;
	var support_price = 0;
	var price_each = 0;
	
	// new loop to fix array wierdness in safari
	for (var i = 0; i < supportTeirKeys.length; i++)
	{
		if (total_devices <= supportTeirKeys[i])
			{
				price_each = hashSupportTiers[i];
				support_price = price_each * total_devices;
				break;
			}
	}
	
//for (tier in hashSupportTiers)
//	{
//		if (total_devices <= tier)
//		{
//			price_each = hashSupportTiers[tier];
//			support_price = price_each * total_devices;
//		}
//	}

	// modify the Annual Software Maintenance and Support Agreements
	var oldval = document.getElementById("support_phone_cnt").innerHTML;
	if (phoneCnt == 1)
	{
		document.getElementById("support_phone_cnt").innerHTML = phoneCnt + " Phone";
	}
	else
	{
		document.getElementById("support_phone_cnt").innerHTML = phoneCnt + " Phones";
	}

	if (portCnt == 1)
	{
		document.getElementById("support_port_cnt").innerHTML  = portCnt + " Phone Port";
	}
	else
	{
		document.getElementById("support_port_cnt").innerHTML  = portCnt + " Phone Ports";
	}

	[% IF RESELLER %]
		support_price = round(support_price, 2);	// only signed resellers should see decimals in prices
	[% END %]

	document.getElementById("support_total").innerHTML = "$" + support_price;

	[% IF RESELLER %]
		price_each = round(price_each, 2);	// only signed resellers should see decimals in prices
	[% END %]

	document.getElementById("support_per_device").innerHTML = "[$" + price_each + " each]";

	// HACK to change the version of HUD Queues in the dropdown
	var totalSeats = phoneCnt + portCnt;
	if (totalSeats > 19)
	{
		document.form.item_server_hud.options[3].value = [% HUD_QUEUES_OVER20_ITEM_ID %];
		document.form.item_server_hud.options[3].text  = '[% HUD_QUEUES_OVER20.name %] [+ $[% HUD_QUEUES_OVER20.price %]]';
	}
	else
	{
		document.form.item_server_hud.options[3].value = [% HUD_QUEUES_UNDER20_ITEM_ID %];
		document.form.item_server_hud.options[3].text  = '[% HUD_QUEUES_UNDER20.name %] [+ $[% HUD_QUEUES_UNDER20.price %]]';
	}
}

// internal use only - change the options available in the Live Backup Server drop-down menu
function _change_item_upgrade_redundancy(server_type)
{
	// find which SERVER relations to which LIVE BACKUP SERVER
	var redundant_server_id = hashRedundantsRelation[server_type];
	// calculate the price of the LIVE BACKUP SERVER
	var backup_price = hashRedundantsPrice[redundant_server_id]; // the default price

	// save the price in a hidden input tag
	redundancy_price = document.getElementById('redundancy_price');
	redundancy_price.value = backup_price;
	// now create the text value of the LIVE BACKUP SERVER

	var backup_text = hashRedundants[redundant_server_id] + " [+ $" + backup_price + "]";
	// FINALLY set the dropdown values
	document.form.item_upgrade_redundancy.options[1].value = redundant_server_id;
	document.form.item_upgrade_redundancy.options[1].text  = backup_text;
}

// internal use only - change the options available in the CPU Upgrade drop-down menu
function _change_item_upgrade_cpu(cpu_id)
{
	// reset the selected value in case the last menu had no CPUs available
	if (cpu_upgrade != null)
	{
		document.form.item_upgrade_cpu.selectedIndex = cpu_upgrade;
	}
}


// internal use only - change the options available in the Expansion Card drop-down menu
function _change_item_slots()
{
	// save the item IDs that were already selected
	item_slot1 = document.form.item_slot1[document.form.item_slot1.selectedIndex].value;
	// this hash will track which T1 cards should appear in the 2nd dropdown
	var second_dropdown_option = new Array();
	var show_first_dropdown  = 0;
	// create a hash of the T1 cards available for the selected server_config_option_id
	var available_cards = new Array();
	for (conn in connectivity)
	{
		if (connectivity[conn][0] != server_config_option_id) continue;
		var cnt_T1 = 1;
		for (card_type in connectivity[conn][1])
		{
			if (card_type == "152") continue;	// 152 is the old Sangoma card and is used here only as part of the connectivity machine
			available_cards[card_type] = 1;
			show_first_dropdown = 1;
			cnt_T1 = cnt_T1 + 1;
		}
	}
	// overwrite each option (except the first) for a clean slate
	var key_cnt = 0;
	var item_slot1_length = document.form.item_slot1.options.length;
	for (i=0; i < item_slot1_length; i++)
	{
		document.form.item_slot1.remove(1);
	}

	// now rewrite the options
	var option1_cnt = 1;
	for (card_id in available_cards)
	{
		var option1_text = hashT1CARDs[card_id] + " [+ $" + hashT1CARDsPrice[card_id] + "]";
		document.form.item_slot1.options[option1_cnt] = new Option(option1_text, card_id);

		option1_cnt = option1_cnt + 1;
	}
	// default the selected field to NONE
	document.form.item_slot1.selectedIndex = 0;
	// Expansion Card contents change - match by value not index
	if (item_slot1 > 0)
	{
		for (var cnt=1; cnt < document.form.item_slot1.options.length; cnt++)
		{
			if (document.form.item_slot1.options[cnt].value == item_slot1)
			{
				document.form.item_slot1.selectedIndex = cnt;
				break;
			}
		}
	}
	if (show_first_dropdown) {
		document.form.item_slot1.options[0].text = "--- no card has been selected ---";
		document.form.item_slot1.disabled = false;
	} else {
		document.form.item_slot1.options[0].text = "--- not supported by selected configuration ---";
		document.form.item_slot1.disabled = true;
	}
}

// internal use only - change the options available in the Warranty drop-down menu
function _change_item_server_can_link(server_can_link_id)
{
	[% IF UNBOUND OR UNBOUNDADD %]
		document.form.unbound_server_can_link.options[1].value = hashUnboundLinkedServersIDs[server_can_link_id];
		document.form.unbound_server_can_link.options[1].text  = hashUnboundLinkedServers[server_can_link_id];
	[% ELSE %]
		document.form.item_server_can_link.options[1].value = server_can_link_id;
		document.form.item_server_can_link.options[1].text  = hashLinkedServers[server_can_link_id];
	[% END %]
}


// This function is used to re-populate several different select boxes when the server type changes
function set_value(box, val)      
{
	// set the value of an inputbox by value
	var box_arr = new Array();
	for (i=0; i < box.length; i++)
	{
		box_arr[box[i].value] = i;
	}
	box.selectedIndex = box_arr[val];
}


function set_software()
{
	var myCnt = 0;
	for (item_id in hashEditionsPrice)
	{
		document.form.item_software_edition.options[myCnt].value = item_id;
		document.form.item_software_edition.options[myCnt].text  = hashEditions[item_id] + " [+ $" + hashEditionsPrice[item_id] + "]";
		myCnt++;
	}
}

// look at all the Config Options to find out which Option ID has been selected
function setDefaultConfigOption()
{
	server_config_option_id = "";
	var loop_cnt = 0;
	while (server_config_option_id == "")
	{
		// until server_config_option_id is assigned - start from the selected RAM
		// not all possible combinations have config options but we will find one by stepping back through the RAM options
		var ram_index = 0;
		if(document.form.item_upgrade_ram != null)
			ram_index = document.form.item_upgrade_ram.selectedIndex - loop_cnt;
		if (ram_index < 0) break;

		for (option in configOptions)
		{
			if (document.form.item_server_hardware != null && 
				configOptions[option][0] != document.form.item_server_hardware[document.form.item_server_hardware.selectedIndex].value) continue;
			if (document.form.item_upgrade_ram != null && 
				configOptions[option][1] != document.form.item_upgrade_ram[ram_index].value) continue;
			if (document.form.item_upgrade_cpu != null && 
				configOptions[option][2] != document.form.item_upgrade_cpu[document.form.item_upgrade_cpu.selectedIndex].value) continue;
			server_config_option_id = option;	// found a match!
			break;
		}
		loop_cnt += 1;
	}
}

// load default settings - important if a proposal is recalled or if the the page is renavigated
function init()
{

	[% IF ADDON %]
		// initialize the addon options
		switchAddonOptions();
		// initialize the Reprovisioned Phones
		selectReprovisionedPhone();

	[% ELSE %]
		// save the selected values of the Expansion Card dropdowns
		item_slot1 = document.form.item_slot1.value;

		// the server type affects other selections and should be initialized
		selectServer(document.form.item_server_hardware[document.form.item_server_hardware.selectedIndex].value, -1);

		// initialize the support price per Phone/Phone Port
		_update_support_price();

		[% IF SELECTED_HUD > 0 %]
			// re-select the HUD Edition - HUD Queues will break when the wrong version was in the dropdown when the page first loaded
			set_value(document.form.item_server_hud, '[% SELECTED_HUD %]');
		[% END %]

		// initialize the Software Editions dropdown list
		set_software();
		[% IF SELECTED_EDITION > 0 %]
			set_value(document.form.item_software_edition, '[% SELECTED_EDITION %]');
		[% END %]

		// the software type affects the Server Linking Software
		selectSoftwareEdition(document.form.item_software_edition[document.form.item_software_edition.selectedIndex].value);

		// we save the selected HUD edition in case we need to revert to it, e.g. customer makes an invalid selection
		selectedHUD = document.form.item_server_hud.selectedIndex;

		[%# IF SELECTED_WARRANTY %]
			//set_value(document.form.item_server_warranty, '[% SELECTED_WARRANTY %]');
		[%# END %]

		[%# IF SELECTED_CPU %]
			//set_value(document.form.item_upgrade_cpu, '[% SELECTED_CPU %]');
		[%# END %]

		[%# IF SELECTED_RAM %]
			//set_value(document.form.item_upgrade_ram, '[% SELECTED_RAM %]');
		[%# END %]

		[%# IF SELECTED_RAID %]
			//set_value(document.form.item_upgrade_raid, '[% SELECTED_RAID %]');
		[%# END %]

		[%# IF SELECTED_POWER %]
			//set_value(document.form.item_upgrade_power, '[% SELECTED_POWER %]');
		[%# END %]

		// look at all the Config Options to find out which Option ID has been selected
		setDefaultConfigOption();
		// reset the card values
		_change_item_slots();

		_set_analog_echo();	// disable or enable HW echo cancellation

		// re-process the Live Backup Server to set the price as the previous selections will affect the total price
		_change_item_upgrade_redundancy(document.form.item_server_hardware[document.form.item_server_hardware.selectedIndex].value);

		[% IF RESELLER %]
			// update the reseller phone fees/credits
			recalculatePhoneCnt();
		[% END %]
	[% END %]

	[% IF QUOTE %]
		// enable/disable state based on what shipping country is selected
		select_shipping_country();
	[% END %]

	[%# POP ALERTS - INACTIVATED SERVERS %]
	[% IF HP_MINITOWER_SELECTED %]
		alert("The HP Minitower has been discontinued. We recommend the Dell Minitower instead.");
	[% ELSIF FONALITY_2U_SELECTED %]
		alert("The Fonality 2U server has been discontinued. We recommend the Dell 1U instead.");
	[% ELSIF HP_1U_SELECTED %]
		alert("The Fonality 1U server has been discontinued. We recommend the Dell 1U instead.");
	[% END %]
}

window.onload = init;





// after removing records, we need to bump things up
function BumpUp(box)
{
	var ln;
	for (var i=0; i < box.options.length; i++)
	{
		if (box.options[i].text == "")
		{
			for (var j = i; j < box.options.length - 1; j++)
			{
				box.options[j].value = box.options[j+1].value;
				box.options[j].text  = box.options[j+1].text;
			}

			ln = i;
			break;
		}
	}

	if (ln < box.options.length)
	{
		box.options.length -= 1;
		BumpUp(box);
	}
}

// This function takes a dropdown, an array, and a string
// and sets the dropdown to everything in the array except
// items that have "string" in them (if there's a string)
function setDropdowns(dropdown, list, exception)
{        
	// reset dropdown
	dropdown.options.length = 0;

	// put items in dropdown
	for (var item in list)
	{
		// if we need to check for exceptions and found one, ignore it
		if (exception && list[item].indexOf(exception) >= 0)
			continue;

		var no = new Option();
		no.value = item;
		no.text = list[item];
		dropdown.options[dropdown.options.length] = no;
	}
}

// is a number even or odd?
function isEven(value)
{
	if (value % 2 == 0)
	{
		return true;
	}
	else
	{
		return false;
	}
}

// do this before submitting the order form
var bypass_validation = 0;

function validateSubmit()
{
	if (bypass_validation)
	{
		return true;
	}

	if (connectivityProblem)
	{
		//this is here so the form won't submit on ENTER
		connectivityProblem = false; // this problem will already have been solved by selectSlot
		return false;
	}

	return true;
}

// Count if we have cordless units without a base
function count480i()
{
	if (document.getElementById('a480i_handset').value > 0 && document.getElementById('phone_1267').value < 1)
	{
		alert('480i handsets require at least one Aastra 9480i CT to function properly.');
		return false;
	}
	else if (document.getElementById('phone_1431').value > 0 && document.getElementById('phone_973').value < 1)
	{
		alert('Polycom 650 sidecars require at least one Polycom 650.');
		return false;
	}
	else if (document.getElementById('phone_1428').value > 0 && document.getElementById('phone_1430').value < 1)
	{
		alert('Kirk 5020 handsets require at least one Kirk KWS300 base.');
		return false;
	}

	// twelve Kirk 5020 handsets per KWS300 base
	if (document.getElementById('phone_1428').value > 0)
	{
		removeNonNumbers('phone_1428');
		var kirk_handsets = document.getElementById('phone_1428').value;
		removeNonNumbers('phone_1430');
		var kirk_bases = document.getElementById('phone_1430').value;
		if (kirk_handsets > (kirk_bases * 12))
		{
			alert('Each Kirk KWS300 base can only support up to 12 Kirk 5020 handsets.');
			return false;
		}
	}

	// four 480i handsets per Aastra 480iCT base
	if (document.getElementById('a480i_handset').value > 0)
	{
		removeNonNumbers('a480i_handset');
		var aastra_handsets = document.getElementById('a480i_handset').value;
		removeNonNumbers('phone_1267');
		var aastra_bases = document.getElementById('phone_1267').value;
		if (aastra_handsets > (aastra_bases * 4))
		{
			alert('Each Aastra 9480i CT base can only support up to 4 extra 480i handsets.');
			return false;
		}
	}

	return 1;
}

// adds commas to a number (integer or float)
function formatPrice(S)
{
	S = String(S);
	var RgX = /^(.*\s)?([-+$\u00A3\u20AC]*\d+)(\d{3})(\.\d{1,2})?\d*/;
	S == (S = S.replace(RgX, "$1$2,$3$4")) ? S : formatPrice(S);
	RgX = /(\.\d{1})$/;
	return S == (S = S.replace(RgX, "$1"+"0")) ? S: formatPrice(S);

}


//
// remove every option from a select tag dropdown box
//
function _removeMyOptions(myInputName)
{
	// overwrite each option (except the first) for a clean slate
	var key_cnt = 0;
	var myInputNameLength = myInputName.options.length;
	for (i=0; i < myInputNameLength; i++)
	{
		myInputName.remove(0);
	}
}

