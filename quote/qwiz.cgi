#!/usr/bin/perl

use Template ();
use CGI;
use Cwd;
use strict;
use Apache::Request();
use Apache::Cookie();
#use Data::Dumper;
use F::Order;
use F::Database;
use lib '/html/pbxtra';
use F::Sugar;
use F::SOAP::Lite;
use Digest::MD5 qw(md5_hex);
use HTML::HTMLDoc;
use CGI qw(escapeHTML);
use Mail::Sender;
use F::Mail;
use F::Cookies;
use F::IntranetSupport;
use Date::Calc;
use F::Country;
use F::BlueHornet;
use POSIX;
use Time::Local;
use PDF::Reuse;

{
	&main(@_);
	exit;
}

sub main {
		
		#
		#   Set up/defaults
		#
		
	my $q    = new Apache::Request(@_, DISABLE_UPLOADS => 0, POST_MAX => (10 * (1024 * 1024)));
	my $dbh  = F::Database::mysql_connect() || die "Unable to connect to database; $!";
	my $vars = {%ENV}; # This is where values from form are passed to $vars array
#if ( $q->param('rickscaptcha') )
{   
	print STDERR "Captcha: ". $q->param('rickscaptcha')."\n";
	#   return;
}
	my $ttpath = affiliate_update($q, $vars);
	# default form template name
	my $tmpl_name = 'qwiz2.tt';

	# save this if the customer came from a PBXtra UNBOUND landing page
	# if we want to make sure the q param of unbound is 0/1, just && it - Andre
	$vars->{UNBOUND} = $q->param('unbound') && 1;
	# the PBXTRA var is already taken - Andre
	$vars->{NOT_UNBOUND} = $q->param('pbxtra') && 1;

	my $template = Template->new
		({
			ABSOLUTE  => 1,
			EVAL_PERL => 1,
	    	PRE_PROCESS  => $vars->{'BASE_DIR'} . 'config.tt',
	    	WRAPPER => 'wrapper_order.tt', 
	    	INCLUDE_PATH => $ttpath, PRE_CHOMP => 1, TRIM => 1, POST_CHOMP => 1
	  });


	#### Dell/Fonality Quote Tool Mutual Exclusivity #######
	# Users that make a quote using Dell, are not allowed to make a quote on Fonality, and vice versa

	# Is a salesperson logged into the quote tool?
	# get the user ID if the user is also logged into the Intranet - sales will do this to add sales queue call proposals
	my (undef, $intranet_id, $intranet_name) = F::IntranetSupport::get_cookie($dbh);
	$vars->{'INTRANET_NAME'} = $intranet_name;
	my $sales_person = F::Sugar::get_sugar_salesperson_by_username($dbh, $intranet_name);

	# Is a certified reseller logged into the quote tool?
	my $reseller_cookie = 'FONALITYreseller';
	my $reseller_cookie_val = F::Cookies::get_cookie_from_browser($q, $reseller_cookie);
	my $cookie = F::Cookies::get_reseller_id_from_cookie($dbh,$q,$reseller_cookie_val,1) if(defined $reseller_cookie_val);
	my $reseller;
	if(defined $cookie)
	{
			my $href = F::Resellers::get_reseller($dbh,$cookie->{'reseller_id'},'reseller_id');
			$vars->{'RESELLER_NAME'} = $href->{'first_name'}." ".$href->{'last_name'};
			$vars->{'RESELLER_EMAIL'} = $href->{'email'};
			$vars->{'RESELLER_STATUS'} = $href->{'status'};
			$reseller = 1 if($href->{'certified'} eq 'on');
	}

	# if yes, do not block user from using quote tool.
	# user is logged in, delete unique quote cookie (is dell cookie is deleted)
	my ($error, $tmpl_name) = quote_type($q, $vars, $sales_person || $reseller, $tmpl_name); 
	if ($error)
	{
			F::Util::show_template($q, $vars, $tmpl_name, undef, $template);
			return 1;
	}

	my $data_cookie = "fonality_quote";

	$vars->{'HOST'}        = '/';
	$vars->{'SCRIPT_URL'}  = 'http://' . $ENV{'HTTP_HOST'} . $ENV{'SCRIPT_NAME'}; 
	$vars->{'SERVER_NAME'} = 'http://' . $ENV{'HTTP_HOST'};

	# ONCE QUOTE SUBMITTED, THIS WILL ADD A GET VALUE TO THE URL SO OUR ADVERTISING ROI PROGRAMS CAN SEARCH THE LOGS
	$vars->{'SCRIPT_URL'} .= "?";
	$vars->{'SCRIPT_URL'} .= "src=$ttpath&" if($ttpath ne '.');
	$vars->{'SCRIPT_URL'} .= "pg=submit#proposal=sent";   

	# grab items to display on simple quote
	$vars->{'EDITIONS'} = F::Order::get_items($dbh, 'PBXtra Software', undef, undef, 1);
	$vars->{'HUD'}      = F::Order::get_items($dbh, 'PBXtra HUD', undef, undef, 1); 

	$vars->{'PBXTRA_PHONES'}  = get_simple_phones($dbh,"pbxtra");
	$vars->{'UNBOUND_PHONES'} = get_simple_phones($dbh,"unbound");
	if ($vars->{'UNBOUND'})
	{
		$vars->{'PHONES'} = $vars->{'UNBOUND_PHONES'};
	}
	else
	{
		$vars->{'PHONES'} = $vars->{'PBXTRA_PHONES'};
	}

	$vars->{'FIRST_PHONE'} = $vars->{'PHONES'}->[0];

		#
		#	GET A LIST OF ALL ITEM IDs HASHED BY THEIR NetSuite ID
		#
		my $item_ids = F::Order::get_all_item_ids_by_netsuite_id($dbh);
	
		# save software item IDs
		my $netsuite_id = F::Order::kPBXTRA_STANDARD_NETSUITE_ID;
		$vars->{'PBXTRA_STANDARD_ID'} = $item_ids->{$netsuite_id};
		$netsuite_id = F::Order::kPBXTRA_PROFESSIONAL_NETSUITE_ID;
		$vars->{'PBXTRA_PROFESSIONAL_ID'} = $item_ids->{$netsuite_id};
		$netsuite_id = F::Order::kPBXTRA_CALL_CENTER_NETSUITE_ID;
		$vars->{'PBXTRA_CALL_CENTER_ID'} = $item_ids->{$netsuite_id};
		$netsuite_id = F::Order::kPBXTRA_UNIFIED_AGENT_NETSUITE_ID;
		$vars->{'PBXTRA_UNIFIED_AGENT_ID'} = $item_ids->{$netsuite_id};
	
	
		# HUD software
		$netsuite_id = F::Order::kHUD_PERSONAL_NETSUITE_ID;
		$vars->{'HUD_PERSONAL_ID'} = $item_ids->{$netsuite_id};
		$netsuite_id = F::Order::kHUD_TEAM_NETSUITE_ID;
		$vars->{'HUD_TEAM_ID'} = $item_ids->{$netsuite_id};
		$netsuite_id = F::Order::kHUD_AGENT_NETSUITE_ID;
		$vars->{'HUD_AGENT_ID'} = $item_ids->{$netsuite_id};
#		$netsuite_id = F::Order::kHUD_QUEUES_UNDER20_NETSUITE_ID;
#		$vars->{'HUD_QUEUES_ID'} = $item_ids->{$netsuite_id};
#		$netsuite_id = F::Order::kHUD_QUEUES_OVER20_NETSUITE_ID;
#		$vars->{'HUD_QUEUES_OVER20_ID'} = $item_ids->{$netsuite_id};

	# guess what? we are pre-setting the edition based on a param 'ed' - andre
	# we set both soft_selected and ed, because soft_selected can be overwritten later
	# by switching between customize and wizard format - andre
	my $ed = $q->param('ed');
	$ed =~ s/^(.+)$/eval("\$item_ids->{F::Order::kPBXTRA_" . uc($1) . "_NETSUITE_ID}")/e;
	$vars->{SOFT_SELECTED} = $vars->{ED} = $ed;

	my $hrefSuppTiers = F::Order::kSUPPORT_TIERS;
	foreach my $key (sort {$a <=> $b} keys %$hrefSuppTiers)
	{
		my $tier = F::Order::get_item($dbh, $key, undef);
		$tier->{'num_users'} = $hrefSuppTiers->{$key};
		$tier->{'name'} =~ s/\s*\(.+\)\s*$//;
		push(@{$vars->{'SUPPORT_TIERS'}}, $tier);
	} 

	# format prices to include commas for prices > than 999.00
	format_prices($vars->{'EDITIONS'}, 1);
	format_prices($vars->{'HUD'}, 1);
	format_prices($vars->{'SUPPORT_TIERS'}, 1);
	format_prices($vars->{'PHONES'}, 1);
	format_prices($vars->{'PBXTRA_PHONES'}, 1);
	format_prices($vars->{'UNBOUND_PHONES'}, 1);

	# support is always selected, unless customer unselects it
	# support_selected is not selected unless user actually gets phones/ports and it is checked
	$vars->{'AUTO_SUPPORT'} = 1;
	$vars->{'SUPPORT_SELECTED'} = 0;

	# .tt variables, that shows simple quote/quote estimate, simple quote/customize quote
	$vars->{'SHOW_FORM'} = 1;
	$vars->{'WIZARD'} = 1;


	my $proposal_id;


			my $cookie_value = F::Cookies::get_cookie_from_browser($q, $data_cookie);
			print STDERR "1, simple quote - cookie: $cookie_value\n";
	# if we are coming from customize quote, grab the cookie, and set .tt variables, ie number of calls, yes/no on voip, 
	# and grab additonal things from proposal, ie phones
	if($q->param('wizard'))
	{
			 $cookie_value = F::Cookies::get_cookie_from_browser($q, $data_cookie);
			($vars->{'NUM_CALLS'}, $vars->{'USE_VOIP'}, $vars->{'AUTO_SUPPORT'}, $proposal_id) = split(',', $cookie_value);
			print STDERR "simple quote - cookie: $cookie_value\n";

			repop_quote($dbh, $proposal_id, $vars);
	}
	else 
	{
		# if we are coming from anywhere else, clear cookie, clean slate, no number of calls, no proposal, etc.
		F::Cookies::create_cookie_in_browser($q, $data_cookie, ",,,");
	}

	# if param 'customize' is defined and set to 0 (meaning no data has been entered in simple quote), 
	# just switch between quote modes without creating a proposal
	if(defined $q->param('customize') && !$q->param('customize'))
	{
			# we must switch the src path, if going over to q.cgi and its an unbound order - Andre
			$ttpath = "unbound" if($q->param('unbound'));

			F::Cookies::create_cookie_in_browser($q, $data_cookie, ",,,");
			my $loc = "Location: q.cgi?";
			$loc   .= "src=$ttpath&" if($ttpath ne '.');
			$loc  .= "pg=customizequote";
			print $loc;
			#print "Location: q.cgi?pg=customizequote";
			return 1;
	}
	# otherwise we are customizing or we are going to quote estimate page
	elsif($q->param('order_review') || $q->param('customize')) 
	{
			# Dell and Fonality Quote Tools require mutual exclusivity
		    # this will handle the case if a customer presses the back button and resubmits it.
		    # ie, we check for the cookie pre-submit and after-submit, for caution's sake
			# Also, check whether this customer is already assigned to a Dell VoIP Specialist
			# If so, print error message, do not continue.
			my $error = 0;
			($error, $tmpl_name) = quote_type($q, $vars, $sales_person || $reseller, $tmpl_name, 1) if($q->param('order_review'));
			if($error)
			{
				F::Util::show_template($q, $vars, $tmpl_name, undef, $template);
				return 1;
			}
		
		# grab data entered by customer, and calculate quote package (server, phones, support, additonal cards)
		validate($q, $vars, $dbh);
		select_package($vars, $dbh, $q);
		
		
		###################################### 
		#
		#  Form validation
		#
		#  03.25.2009 - pgoddard - lets start with valid email validation. add more later.
		#
		######################################
		
		# do not check email address if we are moving to the Custom Quote
		unless ($q->param('customize'))
		{
			# make sure email address is not blank and is valid
			push (@{$vars->{MSG_ERROR}}, 'Invalid email address') unless F::Mail::check_email_address($q->param('email'));
		}
		
		if ($q->param('email') eq 'radjdufi@gmail.com')
		{
			# death to hackers - hang their broken bodies from a gibbet -pmadison Nov 2009
			push (@{$vars->{MSG_ERROR}}, 'Unknown Error: Segmentation fault');
		}

		if ($vars->{MSG_ERROR})
		#if ($q->param('email') == 'pgoddard@fonality.com')
		{
	  		#push (@{$vars->{MSG_ERROR}}, 'Invalid email address');
	  		form_repop($q,$vars);
			F::Util::show_template($q, $vars, $tmpl_name, undef, $template);
			return 1;	
		}
		
		###################################### 
		#  END Form validation
		###################################### 
		

		# if there is a discount, setup discount TT variables, and modify quote total
		if($vars->{'SMALL_SERVER_DISCOUNT'})
		{
	    	$vars->{'DISCOUNT_SUBTOTAL'} = F::Util::format_comma($vars->{'QUOTE_TOTAL'});
	    	$vars->{'QUOTE_TOTAL'} -= $vars->{'SMALL_SERVER_DISCOUNT'};
	    	$vars->{'SMALL_SERVER_DISCOUNT'} = F::Util::format_comma($vars->{'SMALL_SERVER_DISCOUNT'});
		}

		# It's possible we can't ship to the location; error out if we can't!
		taxes($q, $vars, $dbh);
		if ($vars->{MSG_ERROR})
		{
	  		form_repop($q,$vars);
			F::Util::show_template($q, $vars, $tmpl_name, undef, $template);
			return 1;	
		}

		# format prices to include comma for prices > 999.00
		format_prices($vars->{'ORDER_ITEMS'});
		$vars->{'QUOTE_TOTAL'} = F::Util::format_comma(sprintf("%.2f",$vars->{'QUOTE_TOTAL'}));

		# show customize quote estimate page
		$vars->{'SHOW_FORM'} = 0;
	
		my $cookie_value = F::Cookies::get_cookie_from_browser($q, $data_cookie);
		my(undef, undef, undef, $proposal_id) = split(',', $cookie_value);

		# create a quote
		unless($proposal_id)
		{
	    	$proposal_id = create_quote($q, $vars, $dbh);
		}
		else
		{
			# otherwise if there is already a proposal floating about, just update that proposal instead of creating a new one
	    	#print STDERR "simple quote - updating quote: $proposal_id\n";
	    	F::Order::remove_item_from_quote($dbh,$proposal_id);
	    	create_quote($q, $vars, $dbh, $proposal_id);
		}
		
		$vars->{'PROPOSAL_ID'} = $proposal_id;

		# order_review is (currently) the name of the submit button
		# if simple quote doesn't have param 'order_review', won't do expected submission
		if($q->param('order_review'))
		{
			# if we are going to quote estimate, create a sugar opportunity, and email quote to email address supplied by customer
	    	my $proposal_href = get_quote($dbh, $proposal_id);

	    	# setup the pdf file with the quote data
	    	set_random_pdf_name($q, $dbh, $proposal_href, $proposal_id);

	    	my $opportunity_reference = create_sugar_opportunity($vars, $dbh, $proposal_id, $proposal_href, $q);

	    	unless(defined $opportunity_reference) 
	    	{
#				#print STDERR "simple quote - could not make reference\n";
				return 1;
	    	}
	
	    	#F::Order::update_quote_header($dbh, { quote_id => $proposal_id, sugar_opportunity_id => $opportunity_reference });
	    	email_quote($q, $vars, $dbh, $proposal_href, $proposal_id) unless($vars->{EPIC_FAIL});

	    	# clear cookie
	    	F::Cookies::create_cookie_in_browser($q, $data_cookie, ",,,$proposal_id");
			
			if($vars->{EPIC_FAIL}) {
				$tmpl_name = 'qwiz_error_fail.tt' 
			} elsif($ttpath eq 'sim' || $ttpath eq 'pbxtra' || $ttpath eq 'sim2' || $ttpath eq 'sta') {
				$vars->{'RESPONSE'} = 'qwiz_thanks';
				# name of template for thank you/response page
				$tmpl_name = 'order_email_quote.tt' ;
			}
		}
		else 
		{
			# otherwise we are going over to customize, create cookie, with proposal_id,
			# and other non 1-to-1 mapping data, such as number of calls and yes/no voip answer
	    	# put stuff into cookie

			# we must switch the src path, if going over to q.cgi and its an unbound order - Andre
			$ttpath = "unbound" if($q->param('unbound'));
			
	    	my $data = "$vars->{'NUM_CALLS'},$vars->{'USE_VOIP'},$vars->{'AUTO_SUPPORT'},$proposal_id";
	    	F::Cookies::create_cookie_in_browser($q, $data_cookie, $data);
	    	my $loc = "Location: q.cgi?";
	    	$loc   .= "src=$ttpath&" if($ttpath ne '.');
	    	$loc   .= "pg=customizequote&custom=$proposal_id";
	    	print $loc;
	    	#print "Location: q.cgi?pg=customizequote&custom=$proposal_id";
	    	return 1;
		}
	}
	
	F::Util::show_template($q, $vars, $tmpl_name, undef, $template);
	return 1;
}

#
#   Sub-Routines
#

##########################
# Function: get_simple_phones
# Returns a list of phones, in order of mnemonic, 
# assumes mnemonic pattern as being [0-9]+|description
# args: database pointer
# returns: list of phone hash refs 
# usage: get_simple_phones($dbh);
#########################
sub get_simple_phones
{
	my $dbh        = shift(@_);
	my $phone_type = shift(@_);

	my $phones = undef;
	if ($phone_type eq "unbound")
	{
		$phones = F::Order::get_items($dbh, 'PBXtra UNBOUND Handset Rental');
	}
	else
	{
		$phones = F::Order::get_phones($dbh);
	}

	my @out;
	foreach my $phone(sort { $a->{mnemonic} <=> $b->{mnemonic} } @$phones)
	{
		if(defined $phone->{mnemonic})
		{
			$phone->{mnemonic} =~ s/^\d+\|//;
			push(@out, $phone);
		}
	}
	return \@out;
}

##########################
# Function: repop_quote
# Gets the proposal hash reference, and assigns the appropriate TT variables
# with values from the proposal hash reference to repopulate
# the simple quote with values the customer has already placed
# args: database pointer, proposal id, TT variable hash ref
# returns: void 
# usage: repop_quote($dbh, $proposal_id, $vars);
#########################
sub repop_quote
{
	my $dbh  = shift(@_);
	my $proposal_id = shift(@_);
	my $vars = shift(@_);

	my $proposal_href = get_quote($dbh, $proposal_id);

	# item info
	foreach my $proposal_item (@{$proposal_href->{'items'}})
	{
		if(!defined $vars->{'SOFT_SELECTED'})
		{
	    	foreach my $soft(@{$vars->{'EDITIONS'}})
	    	{
				if($proposal_item->{'item_id'} == $soft->{'item_id'})
				{
		    		$vars->{'SOFT_SELECTED'} = $proposal_item->{'item_id'};
		    		last;
				}
	    	}
		}
	
		if(!defined $vars->{'HUD_SELECTED'})
		{
	    	foreach my $hud(@{$vars->{'HUD'}})
	    	{
				if($proposal_item->{'item_id'} == $hud->{'item_id'})
				{
		    		$vars->{'HUD_SELECTED'} = $proposal_item->{'item_id'};
		    		last;
				}
	    	}
		}
	
		foreach my $phone(@{$vars->{'PHONES'}})
		{
	    	if($proposal_item->{'item_id'} == $phone->{'item_id'})
	    	{
				$phone->{'quantity'} = $proposal_item->{'quantity'};
				last;
	    	}
		}

		if($vars->{'AUTO_SUPPORT'} && $vars->{'SUPPORT_SELECTED'})
		{
	    	foreach my $support (@{$vars->{'SUPPORT_TIERS'}})
	    	{
				if($proposal_item->{'item_id'} == $support->{'item_id'})
				{
		    		$vars->{'SUPPORT_SELECTED'} = $proposal_item->{'item_id'};
		    		last;
				}
	    	}
		}
	}

	# customer info
	$vars->{'NAME'}           = $proposal_href->{'name'};
	$vars->{'EMAIL'}          = $proposal_href->{'email'};
	$vars->{'CONFIRM_EMAIL'}  = $proposal_href->{'email'};
	$vars->{'CUST_PHONE'}     = $proposal_href->{'phone'};
	$vars->{'COUNTRY'}        = $proposal_href->{'shipping_country'};
	$vars->{'SHIPPING_STATE'} = $proposal_href->{'shipping_state'};
	$vars->{'ZIP_CODE'}       = $proposal_href->{'shipping_zip'};
}


##########################
# Function: format_prices
# Formats items' prices in the hash ref to include comma for prices > 999
# second arg is used to whether to set this formating to 'price' or to 'display_price'
# args: hash ref, 1/0
# returns: void 
# usage: format_prices($hash_ref, 1);
#########################
sub format_prices
{
	my $items   = shift(@_);
	my $display = shift(@_);
	foreach my $item (@{$items})
	{
		if($display)
		{
	    	$item->{'display_price'} = F::Util::format_comma($item->{'price'});
		}
		elsif($item->{'price'} !~ /\d+\.\d{2}/ || $item->{'subtotal'} !~ /\d+\.\d{2}/)
		{
	    	$item->{'price'} = F::Util::format_comma($item->{'price'});
	    	$item->{'subtotal'} = F::Util::format_comma($item->{'subtotal'});
		}
	}
}

##########################
# Function: select_package
# Based on the number of calls found in the hash reference, selects the
# best server option with appropriate server upgrades and sets those values
# to the hash reference. Also based on the whether the customer has VoIP service
# and the number of calls will select the best card upgrade for the server
# args: TT variable hash reference, database reference
# returns: void 
# usage: select_package($hash_ref, $dbh);
#########################    
sub select_package 
{
	my $vars   = shift(@_);
	my $dbh    = shift(@_);
	my $q      = shift(@_);
	my $calls  = $vars->{'NUM_CALLS'};
	my $voip   = $vars->{'USE_VOIP'};
	my $soft   = $vars->{'SOFT_SELECTED'};

	# this method only adds server hardware order items - not needed for PBXtra UNBOUND quotes
	return if ($vars->{'UNBOUND'});

	my $quote_package = F::Order::get_quote_package($dbh, $calls);

	my @ITEM_GROUP_LIST = (
			   'server_id',
			   'cpu_id',
			   'ram_id',
			   'raid_id',
			   'power_id',
			   'warranty_id',
			   'card_id',
			   'setup_id'
			   );

	my $server_id = '';	# save this because the Sangoma needs to know the server_id
	foreach my $group (@ITEM_GROUP_LIST) 
	{
		# if user has voip, do not add card or support
		last if(($group =~ 'card_id' || $group =~ 'setup_id') && $voip =~ 'yes');

		$server_id = $quote_package->{$group} if ($group =~ 'server_id');

		# if user does not have voip, and needs sangoma card package
		# end loop, since after adding sangoma card, do not loop through support
		# support should be undefined
		if(($group =~ 'card_id' && defined $voip && $voip !~ 'yes') && ! defined $quote_package->{$group}) 
		{
	    	setup_sangoma_card($dbh, $vars, $server_id);
	    	last;
		}

		my $item = F::Order::get_item($dbh, $quote_package->{$group});
		$item->{'quantity'} = 1;
		$vars->{'QUOTE_TOTAL'} += ($item->{'subtotal'} = $item->{'price'});

		push(@{$vars->{'ORDER_ITEMS'}}, $item);
	}

	# if not standard edition and customer has voip
	if($soft != F::Order::kSOFTWARE_SE_ITEM_ID && $voip eq 'yes') 
	{
		my $item_ids = F::Order::get_all_item_ids_by_netsuite_id($dbh);	# get all item_id values mapped to NetSuite IDs
		# get the correct VoIP Only Timing Card
		my $item = F::Order::get_voip_only_timing_cards($dbh, $item_ids, $server_id);
		$item->{'quantity'} = 1;
		$vars->{'QUOTE_TOTAL'} += ($item->{'subtotal'} = $item->{'price'});

		# add timing card
		push(@{$vars->{'ORDER_ITEMS'}}, $item);
	}
}


##########################
# Function: setup_sangoma_card
# Using the number of calls, will setup a sangoma card and add it to
# the hash reference
# args: TT variable hash reference, database reference
# returns: void 
# usage: setup_sangoma_card($hash_ref, $dbh);
#########################    
sub setup_sangoma_card
{
	my $dbh       = shift(@_);
	my $vars      = shift(@_);
	my $server_id = shift(@_);

	my $num_FXO_ports = $vars->{'NUM_CALLS'} + ($vars->{'NUM_CALLS'} % 2);

	# get the server's analog_card_type (PCI or PCIe)
	my $analog_card_type = '';
	my $servers = get_servers($dbh);
	foreach my $server (@$servers)
	{
		if ($server->{'item_id'} == $server_id)
		{
			$analog_card_type = $server->{'analog_card_type'};
			last;
		}
	}

	# get the Shark cards
	my $base_cards = undef;
	if ($analog_card_type eq 'PCIe')
	{
		$base_cards = F::Order::get_items($dbh, 'analog_base_pcie');
	}
	else
	{
		$base_cards = F::Order::get_items($dbh, 'analog_base_pci');
	}

	# the Sangoma card can support 4 ports, 1 Remora can support another 4 ports
	# so here we create an array that lays out a structure of how the ports will be arrayed on the card
	my @sangoma_ports = (('fxo') x $num_FXO_ports);
	my @sangoma_cards = ();
	while (@sangoma_ports)
	{
		push @sangoma_cards, [splice(@sangoma_ports, 0, 4)];
	}

	# add the base SHARK CARD to the order
	my $base_card_ports = splice(@sangoma_cards, 0, 1);
	my %base_card_ports = (fxo=>0);
	foreach my $port_type (@$base_card_ports)
	{
		$base_card_ports{$port_type}++;
	}
	my $base_card_search = 'echw1|fxo' . $base_card_ports{'fxo'} . '|fxs0';
	foreach my $base_card (@$base_cards)
	{
		if ($base_card->{'mnemonic'} eq $base_card_search)
		{
			# found a matching SHARK CARD
			$base_card->{'quantity'} = 1;
			$base_card->{'subtotal'} = $base_card->{'price'};
			push(@{$vars->{'ORDER_ITEMS'}}, $base_card);
			$vars->{'QUOTE_TOTAL'} += $base_card->{'price'};
			last;
		}
	}

	# add the first REMORA CARD if there are nay ports left
	if (@sangoma_cards)
	{
		my $exp1_ports = splice(@sangoma_cards, 0, 1);
		my %exp1_ports = (fxo=>0);
		foreach my $port_type (@$exp1_ports)
		{
			$exp1_ports{$port_type}++;
		}
		my $first_remoras = F::Order::get_items($dbh, 'analog_exp1');
		my $first_remora_search = 'echw1|fxo' . $exp1_ports{'fxo'} . '|fxs0';
		foreach my $first_remora (@$first_remoras)
		{
			if ($first_remora->{'mnemonic'} eq $first_remora_search)
			{
				# found a matching REMORE CARD
				$first_remora->{'quantity'} = 1;
				$first_remora->{'subtotal'} = $first_remora->{'price'};
				push(@{$vars->{'ORDER_ITEMS'}}, $first_remora);
				$vars->{'QUOTE_TOTAL'} += $first_remora->{'price'};
				last;
			}
		}
	}

	# add the second REMORA CARD if there are nay ports left
	if (@sangoma_cards)
	{
		my $exp2_ports = splice(@sangoma_cards, 0, 1);
		my %exp2_ports = (fxo=>0);
		foreach my $port_type (@$exp2_ports)
		{
			$exp2_ports{$port_type}++;
		}
		my $second_remoras = F::Order::get_items($dbh, 'analog_exp2');
		my $second_remora_search = 'echw1|fxo' . $exp2_ports{'fxo'} . '|fxs0';
		foreach my $second_remora (@$second_remoras)
		{
			if ($second_remora->{'mnemonic'} eq $second_remora_search)
			{
				# found a matching REMORE CARD
				$second_remora->{'quantity'} = 1;
				$second_remora->{'subtotal'} = $second_remora->{'price'};
				push(@{$vars->{'ORDER_ITEMS'}}, $second_remora);
				$vars->{'QUOTE_TOTAL'} += $second_remora->{'price'};
				last;
			}
		}
	}


#    $sangoma_card->{'name'} = "Analog Card w/$num_FXO_ports FXO";
#    $sangoma_card->{'group_name'} = 'cards';
#    $sangoma_card->{'quantity'}   = 1;
#    
#    $base_card->{'quantity'} = 1;
#    $sangoma_card->{'price'} += ($base_card->{'subtotal'} = $base_card->{'price'});
#    push(@{$vars->{'ORDER_ITEMS'}}, $base_card);
#    
#    if($num_cards > 1) 
#    {
#		$remora->{'quantity'} = 1;
#		$sangoma_card->{'price'} += ($remora->{'subtotal'} = $base_card->{'price'});
#		push(@{$vars->{'ORDER_ITEMS'}}, $remora);
#    }
#    
#    $sangoma_fxo->{'quantity'} = $num_FXO_ports;
#    $sangoma_card->{'price'} += ($sangoma_fxo->{'subtotal'} = $sangoma_fxo->{'price'} * $sangoma_fxo->{'quantity'});
#    push(@{$vars->{'ORDER_ITEMS'}}, $sangoma_fxo);
#
#    $sangoma_card->{'subtotal'} = $sangoma_card->{'price'};
#    push(@{$vars->{'ORDER_ITEMS'}}, $sangoma_card);
#
#    $vars->{'QUOTE_TOTAL'} += $sangoma_card->{'subtotal'};
}

##########################
# Function: taxes
# Compute shipping & taxes based on state and zip code and adds it to the total 
# args: CGIobject, TT variable hash reference, database reference 
######################### 
sub taxes
{
	my $q    = shift(@_);
	my $vars = shift(@_);
	my $dbh  = shift(@_);

	# subtotal is quote total BEFORE taxes and shipping
	$vars->{'SUBTOTAL'} = F::Util::format_comma(sprintf("%.2f",$vars->{'QUOTE_TOTAL'}));

	my $href = {};
	$href->{'items'} = $vars->{'ORDER_ITEMS'};
	map { $_->{'item_price'} = $_->{'price'} } @{$href->{'items'}};
	$href->{'shipping_country'} = $vars->{'COUNTRY'};
	$href->{'shipping_state'}   = $vars->{'STATE'} = $vars->{'SHIPPING_STATE'};
	$href->{'shipping_zip'}     = $vars->{'ZIP_CODE'};

	# We have to fix the shipping country for UPS
	if (F::Country::get_country_by_abbrev($href->{'shipping_country'}) ne $href->{'shipping_country'})
	{
#		$href->{'shipping_country'} = F::Country::get_country_by_abbrev($href->{'shipping_country'});
	}

	# first shipping
	F::Order::get_pbxtra_shipping($dbh,$q,$vars,$href,undef,"quote");
# removed FEB 2010
#	# find the cheapest shipping
#	my ($shipping_service, $shipping_price) = (undef,0);
#	# search from lowest to highest value
#	foreach my $key (sort { $vars->{$a} <=> $vars->{$b} } (keys %$vars))
#	{
#		next unless ($key =~ /^UPS_/);
#		$shipping_service = $key;
#		$shipping_price   = $vars->{$key};
#		# format in sentence format except for words AM and UPS
#		# too many assumptions, always requires hacking!
#		(undef,$vars->{'PAUL_SHIPPING_SERVICE'}) = split(/_/, $shipping_service, 2);
#		$vars->{'SHIPPING_SERVICE'} = join(" ", map { if($_ ne 'AM' && $_ ne 'UPS') {$_ = lc($_); ucfirst($_); } else { $_; } } split(/_/,$shipping_service));
#		$vars->{'SHIPPING_COST'}    = format_comma(sprintf("%.2f",$shipping_price));
#		$vars->{'QUOTE_TOTAL'}     += $shipping_price;
#		last;
#	}
	# just set the default to UPS_GROUND
	my $shipping_service = 'UPS_GROUND';
	my $shipping_price = $vars->{'UPS_GROUND'} || $vars->{'UPS_STANDARD'};
	$vars->{'SHIPPING_SERVICE'} = join(" ", map { if($_ ne 'AM' && $_ ne 'UPS') {$_ = lc($_); ucfirst($_); } else { $_; } } split(/_/,$shipping_service));
	$vars->{'ALLCAPS_SHIPPING_SERVICE'} = $shipping_service;
	$vars->{'SHIPPING_COST'} = F::Util::format_comma(sprintf("%.2f",$shipping_price));
	$vars->{'QUOTE_TOTAL'} += $shipping_price;
	

	# now taxes
	my $taxes = F::Order::get_sales_tax($vars->{'STATE'}, $vars->{'ZIP_CODE'});
	$vars->{'SALES_TAX'} = sprintf("%.2f",F::Order::get_pbxtra_taxable_amt($vars,$href) * $taxes);
	# only used for display now. Set it in percentage form
	$vars->{'SALES_TAX_ENGLISH'}    = F::Util::format_comma($taxes*100,1);

	$vars->{'QUOTE_TOTAL'}         += $vars->{'SALES_TAX'}; 	

	# format with a comma after ADDING to total -- otherwise commas break the math operators
	$vars->{'SALES_TAX'} = F::Util::format_comma($vars->{'SALES_TAX'});
}


##########################
# Function: create_quote
# Creates a quote with proposal items and adds it to the database
# args: CGIobject, TT variable hash reference, database reference
# returns: proposal id 
# usage: $proposal_id = create_quote($q, $hash_ref, $dbh);
######################### 
sub create_quote 
{
	my $q    = shift(@_);
	my $vars = shift(@_);
	my $dbh  = shift(@_);
	my $proposal_id = shift(@_) || undef;
	my $quote_total = $vars->{'QUOTE_TOTAL'};

	# get the referring site from a cookie
	my $request_url   = F::Cookies::get_cookie_from_browser($q,'requesturl')    or '';
	my $referringsite = F::Cookies::get_cookie_from_browser($q,'referringsite') or '';
	my ($ref_date,$ref_site) = split(/\r/,$referringsite);

# death to SPAMmers
use Data::Dumper;
my @input_params=$q->param;
foreach my $param_name (@input_params){print STDERR "$param_name: ".$q->param($param_name)."\n";}
print STDERR Dumper(\%ENV);

	$proposal_id = F::Order::add_quote($dbh, 0, $ref_site, $ref_date, $request_url) if(!defined $proposal_id);

	my $item_group_list = F::Order::kITEM_GROUP_LIST;
	foreach my $group (@$item_group_list)
	{
		foreach my $item (@{$vars->{'ORDER_ITEMS'}}) 
		{
	    	if ($item->{'group_name'} =~ /^$group$/i)
	    	{
				my $quantity = $item->{'quantity'};
				my $item_id  = $item->{'item_id'};
				my $price    = $item->{'price'};
				next if($item_id !~ /\d/);
				F::Order::add_item_to_quote($dbh, $proposal_id, $item_id, $quantity, $price);
	    	}
		}
	}

	my $ref_hash = {
						quote_id         => $proposal_id, 
						total            => $quote_total,
						email            => $vars->{'EMAIL'},
						name             => $vars->{'NAME'},
						phone            => $vars->{'CUST_PHONE'},
						shipping_country => $vars->{'COUNTRY'},
						shipping_state   => $vars->{'SHIPPING_STATE'},
						shipping_zip     => $vars->{'ZIP_CODE'},
						shipping_cost    => $vars->{'SHIPPING_COST'},
						shipping_service => $vars->{'ALLCAPS_SHIPPING_SERVICE'}
	};
	if ($vars->{'UNBOUND'})
	{
		$ref_hash->{'rental_phones'} = 1;
	}
	F::Order::update_quote_header($dbh, $ref_hash);

	return $proposal_id;
}


##########################
# Function: email_quote
# Sends proposal message to a Sugar sales person
# args: CGIobject, TT variable hash ref, database ref, opportunity ref id, 
#       proposal hash ref, proposal id
# returns: void 
# usage: email_quote($q, $vars, $dbh, $prop_href, $prop_id);
######################### 
sub email_quote
{
	my ($email_msg, $proposal_msg, $error, $htmlmsg);
	my $q             = shift(@_);
	my $vars          = shift(@_);
	my $dbh           = shift(@_);
	my $proposal_href = shift(@_);
	my $proposal_id   = shift(@_);

	my $email_template    = 'order_email_quote_msg.tt';
	my $random_string     = $proposal_href->{'random_proposal_string'};
	my $proposal_file     = "pbxtra_proposal_downloads/p$random_string.pdf";
	my $proposal_template = 'pbxtra_quote.tt';

	$vars->{'PROPOSAL_ID'} = $proposal_id;

	# specify the subject
	my $subject = $vars->{'NAME'} . "'s PBXtra Proposal #$proposal_id";
	if ($vars->{'UNBOUND'})
	{
		$subject = $vars->{'NAME'} . "'s UNBOUND Proposal #$proposal_id";
		#$proposal_template = 'unbound_proposal.tt';
		$proposal_template = 'unbound_quote.tt';
	}

	# create the tt_obj (can't use the main one because it has a pre_config and a wrapper)
	my $tt_email    = Template->new({ POST_CHOMP => 1, TRIM => 1, PRE_CHOMP => 1, INCLUDE_PATH => "./$vars->{'TT_DIR'}" });
	my $tt_proposal = Template->new({ POST_CHOMP => 1, TRIM => 1, PRE_CHOMP => 1, INCLUDE_PATH => './pbxtra_proposal_files' });

	# add additional partner info if the proposal phone area-code is within a sales-team's region (DIRECT SALES only)
	$vars->{'TEAM_LOCATION_INSERT'} = "";
	$vars->{'TEAM_LOCATION_INSERT_PRESENT'} = 0;

# CBeyond Location Inserts Removed on Dec 1st, 2007 -Paul
#	my $area_code = $proposal_href->{'phone'} || $q->param('cust_phone');
#	$area_code =~ s/^\D*1?\D*(\d{3})\D*\d{3}\D*\d{4}.*$/$1/;
#	if ($area_code =~ /^\d\d\d$/)
#	{
#	    my $team_location = F::Sugar::get_sugar_team_location($dbh,$area_code);
#	    if (defined $team_location)
#	    {
#			$vars->{'TEAM_LOCATION_INSERT'} = $team_location->{'proposal_html_insert'};
#			$vars->{'TEAM_LOCATION_INSERT_PRESENT'} = 1;
#	    }
#	}

	# load the email body from the TT
	$tt_proposal->process($proposal_template,$vars,\$proposal_msg) or $tt_proposal->error($error); 

	#	create the proposal - a .pdf file to be downloaded by the customer
	my $htmldoc = new HTML::HTMLDoc();
	$htmldoc->path('pbxtra_proposal_files');
	$htmldoc->set_bodyfont('Arial');
	$htmldoc->set_fontsize('10');
	$htmldoc->set_page_size('letter');
	$htmldoc->set_left_margin(0,'mm');
	$htmldoc->set_bottom_margin(5,'mm');
	$htmldoc->set_top_margin(0,'mm');
	$htmldoc->set_right_margin(0,'mm');
		
	$htmldoc->set_footer('.','/','');	# page X of Y in the bottom right of each page
	$htmldoc->set_html_content($proposal_msg);

	my $pdf = $htmldoc->generate_pdf();
	my $pdf_string = $pdf->to_string($pdf);
	my $pdf_result;
	eval { $pdf_result = $pdf->to_file($proposal_file) };
	
	#PDF MERGE - pgoddard. started 2010-02-18
	
	# Which pdf to use?
	# 1. Determine software type decided by form
	# 2. Match with appropriate pdf and set value
	
	# create temporary quote page
	
	# set a default
	my $static_pdf_path = cwd() . '/pbxtra_proposal_files/pdf/';
	my $static_pdf = $static_pdf_path . 'hosted-se.pdf';
	
	# available pdfs
	my $hosted_cce 	= 'hosted-cce.pdf';		# UNBOUND Call Center Edition PDF
	my $hosted_pe 	= 'hosted-pe.pdf';	 	# UNBOUND Professional Edition PDF
	my $hosted_se 	= 'hosted-se.pdf';  	# UNBOUND Standard Edition PDF
	
	# 1080	= UNBOUND Standard Edition
	#	1082 	= UNBOUND Professional Edition
	# 1279 	= UNBOUND Call Center Edition
	
	
	if ($vars->{'SOFT_SELECTED'} == 1080) {
		
		$static_pdf = $static_pdf_path . $hosted_se;
		
	} elsif ($vars->{'SOFT_SELECTED'} == 1082) {
		
		$static_pdf = $static_pdf_path . $hosted_pe;
		
	} elsif ($vars->{'SOFT_SELECTED'} == 1279) {
		
		$static_pdf = $static_pdf_path . $hosted_cce;		
		
	}
	else
	{
		# PBXtra all versions
		$static_pdf = $static_pdf_path . 'FonalityPBXtra-datasheet_061611.pdf';
	}
	
	# edition $vars->{'EDITIONS'}
	print STDERR "edition: " . $vars->{'SOFT_SELECTED'} . "\n";
	print STDERR "unbound: " . $vars->{'UNBOUND'} . "\n";
	
	prFile("/nfs/www/pbxtra_proposal_downloads/temp$random_string.pdf");
	#prFile('/nfs/www/' . $proposal_file);
	prDoc($static_pdf);
	prDoc('/nfs/www/' . $proposal_file);
	prEnd();
	
	prFile('/nfs/www/' . $proposal_file);
	prDoc("/nfs/www/pbxtra_proposal_downloads/temp$random_string.pdf");
	prEnd();
	
	# clean up
	unlink("/nfs/www/pbxtra_proposal_downloads/temp$random_string.pdf");
	
		
	#print STDERR "Creating $proposal_file for quote_header_id #$proposal_id [result: $pdf_result $@]\n";
	
	# send the email with a link to the proposal
	$tt_email->process($email_template,$vars,\$email_msg) or $tt_email->error($error); 

	# replace with spaces and line breaks
	$email_msg =~ s/\&\#32\;/ /g;
	$email_msg =~ s/\&\#13\;/\n/g;

	# always add trailing carriage returns - multipart emails require them
	$email_msg .= "\n";

	# who to send the email to
	my $to = $q->param('email');
	my $from = 'Fonality Proposal <sales@fonality.com>';

	# Felix Nilam - 10/08/2009
	# send email to reseller if specified
	if($q->param('email_to_reseller') eq 'on')
	{
		if($vars->{'RESELLER_EMAIL'} ne '')
		{
			$to = $vars->{'RESELLER_EMAIL'};
			$vars->{'EMAIL'} = $vars->{'RESELLER_EMAIL'};
		}
	}

	# send the email to the user who built the proposal
	eval
	{
		my $sender = new Mail::Sender({ bypass_outlook_bug => 1 });
		$sender->OpenMultipart(
		{
			smtp    => 'localhost',
			to      => $to,
			subject => $subject,
			from    => $from
		} );
		$sender->Body(
		{
			ctype => 'text/html',
			msg   => $email_msg
		} );
		# this is for attachments
		$sender->Attach(
		{
			ctype       => 'image/png',
			file        => 'images/fonality_logo_header3.png',
			name        => 'fonality_logo_header3.png',
			encoding    => 'base64',
			disposition => "inline; filename=\"fonality_logo_header3.png\";\r\nContent-ID: <fonality_logo_header3.png>",
		} );

		$sender->Close();
	};
}   

	
##########################
# Function: set_random_pdf_name
# Creates random pdf name for proposal
# args: CGIobject, database ref, proposal hash ref, proposal id
# returns: void 
# usage: set_random_pdf_name($q, $dbh, $prop_href, $prop_id);
######################### 
sub set_random_pdf_name
{
	my $q             = shift(@_);
	my $dbh           = shift(@_);
	my $proposal_href = shift(@_);
	my $proposal_id   = shift(@_);

	my $random_string = $proposal_href->{'random_proposal_string'};

	if ($random_string !~ /\w/)
	{
		$random_string = F::Order::return_random_string(20);
		# save the random string for any additional quotes the customer may request
		# update the quote_header with the RT Ticket ID
		F::Order::update_quote_header($dbh,	{ 
												quote_id               => $proposal_id,
												random_proposal_string => $random_string
											}); # or err();
		$proposal_href->{'random_proposal_string'} = $random_string;
	}
}


##########################
# Function: validate
# Adds values selected by customer, ie HUD, PBXtra Edition, Phones, etc. to the 
# order list in the TT variable hash ref
# args: CGIobject, TT variable hash ref, database ref
# returns: void 
# usage: validate($q, $vars, $dbh)
#########################     
sub validate 
{
	my $q    = shift(@_);
	my $vars = shift(@_);
	my $dbh  = shift(@_);

	# validate num calls
	$vars->{'NUM_CALLS'} = $q->param('num_calls');
	$vars->{'QUOTE_TOTAL'} = 0;
	# remove leading or trailing whitespace
	$vars->{'NUM_CALLS'} =~ s/^(\s+)|(\s+)$//g;

	my $per_seat_licensing_fee = get_item($dbh, kPER_SEAT_LICENSING_ITEM_ID);
	$vars->{'LICENSE_FEE'} = 0;
	my $added_phones = 0;
	unless ($vars->{'UNBOUND'})
	{
		$vars->{'PER_SEAT_LICENSING_FEE'} = $per_seat_licensing_fee->{'price'};	# PBXtra UNBOUND has a separate licensing plan
	}

	# validate phone numbers
	my $temp_phone_list;
	if ($vars->{'UNBOUND'}) {
		$temp_phone_list = $vars->{'UNBOUND_PHONES'};
	} else {
		$temp_phone_list = $vars->{'PBXTRA_PHONES'};
	}
	foreach my $temp_phone (@$temp_phone_list)
	{
		my $quantity = $q->param($temp_phone->{'mnemonic'});
		$quantity =~ s/^(\s+)|(\s+)$//g;	# get rid of white space
		$quantity =~ s/^0+//;	# get rid of trailing zeros
	
		if($quantity > 0) 
		{
	    	$temp_phone->{'quantity'} = $quantity;
	    	$temp_phone->{'subtotal'} = $quantity * $temp_phone->{'price'};
	    	$vars->{'QUOTE_TOTAL'} += $temp_phone->{'subtotal'};
	    	$vars->{'LICENSE_FEE'} += $quantity * $per_seat_licensing_fee->{'price'};
	    	push(@{$vars->{'ORDER_ITEMS'}}, $temp_phone);
	    	$added_phones += $quantity;
			if ($vars->{'UNBOUND'})
			{
				$temp_phone->{'subtotal'} = sprintf("%0.2f", $temp_phone->{'subtotal'});	# dollar values must end in 2 decimal places
			}
		}
	}

	$vars->{'SUPPORT_SELECTED'} = $q->param('annual_support');
	$vars->{'SUPPORT_SELECTED'} = 0 unless($vars->{'SUPPORT_SELECTED'});
	$vars->{'AUTO_SUPPORT'}     = $vars->{'SUPPORT_SELECTED'};

	# add support if there are phones and no PBXtra UNBOUND
	if($added_phones and !$vars->{'UNBOUND'})
	{
		if($vars->{'SUPPORT_SELECTED'})
		{
	    	for (my $i = 0; $i < @{$vars->{'SUPPORT_TIERS'}}; $i++)
	    	{
				last if(!$vars->{'SUPPORT_SELECTED'});
				if($vars->{'SUPPORT_SELECTED'} == $vars->{'SUPPORT_TIERS'}[$i]->{'item_id'})
				{
		    		$vars->{'SUPPORT_TIERS'}[$i]->{'quantity'} = $added_phones;
		    		$vars->{'SUPPORT_TIERS'}[$i]->{'subtotal'} = $added_phones * $vars->{'SUPPORT_TIERS'}[$i]->{'price'};
		    		$vars->{'QUOTE_TOTAL'} += $vars->{'SUPPORT_TIERS'}[$i]->{'subtotal'};
		    		push(@{$vars->{'ORDER_ITEMS'}}, $vars->{'SUPPORT_TIERS'}[$i]);
		    		last;
				}
	    	}
		}

		# phone licensing
		$per_seat_licensing_fee->{'quantity'} = ($vars->{'LICENSE_FEE'} / $per_seat_licensing_fee->{'price'});
		$per_seat_licensing_fee->{'subtotal'} = $vars->{'LICENSE_FEE'};
		push(@{$vars->{'ORDER_ITEMS'}}, $per_seat_licensing_fee);

		$vars->{'QUOTE_TOTAL'} += $vars->{'LICENSE_FEE'};
	}

	$vars->{'PHONE_CNT'} = $added_phones;

	# validate customer information
	$vars->{'NAME'}          = $q->param('name');
	$vars->{'NAME'}          =~ s/^(\s+)|(\s+)$//g;
	$vars->{'EMAIL'}         = $q->param('email');
	$vars->{'EMAIL'}         =~ s/^(\s+)|(\s+)$//g;
	$vars->{'CONFIRM_EMAIL'} = $q->param('email');
	$vars->{'CONFIRM_EMAIL'} =~ s/^(\s+)|(\s+)$//g;
	$vars->{'CUST_PHONE'}    = $q->param('cust_phone');
	$vars->{'CUST_PHONE'}    =~ s/^(\s+)|(\s+)$//g;
	$vars->{'COUNTRY'}         = $q->param('country');
	$vars->{'SHIPPING_STATE'}  = $q->param($vars->{'COUNTRY'} eq 'United States' ? 'state' : 'province');
	$vars->{'ZIP_CODE'}        = $q->param('zip_code') || 90230;
	$vars->{'ZIP_CODE'}        =~ s/^(\s+)|(\s+)$//g;
	$vars->{'ON_SITE_SUPPORT'} = $q->param('onsite_support');
	$vars->{'ON_SITE_SUPPORT'} =~ s/^(\s+)|(\s+)$//g;
	$vars->{'INDUSTRY'} 			 = $q->param('industry');
	$vars->{'INDUSTRY'}				 =~ s/^(\s+)|(\s+)$//g;
	$vars->{'TITLE_ROLE'} 		 = $q->param('title_role');
	$vars->{'TITLE_ROLE'}			 =~ s/^(\s+)|(\s+)$//g;
		
	# validate main software edition
	$vars->{'SOFT_SELECTED'} = $q->param($vars->{'EDITIONS'}[0]->{'group_name'});
	my $cce_quote = 0;	# this should only be set in PBXtra quotes for Small Server Discounts
	if ($vars->{'UNBOUND'})
	{
		# add software edition for PBXtra UNBOUND proposal
		my %map_pbxtra_to_unbound =	(
										30		=> '1080',	# Standard Edition
										144		=> '1082',	# Professional Edition
										58		=> '1279',	# Call Center Edition
										1027	=> '1279',	# Unified Agent Edition (maps to UNBOUND CCE for now)
									);
		$vars->{'SOFT_SELECTED'} = $map_pbxtra_to_unbound{$vars->{'SOFT_SELECTED'}};
		my $unbound_edition_item = F::Order::get_item($dbh, $vars->{'SOFT_SELECTED'});
		$unbound_edition_item->{'quantity'} = $added_phones;
		$unbound_edition_item->{'subtotal'} = $added_phones * $unbound_edition_item->{'price'};
		$vars->{'QUOTE_TOTAL'} += $unbound_edition_item->{'subtotal'};
		$unbound_edition_item->{'subtotal'} = sprintf("%0.2f", $unbound_edition_item->{'subtotal'});	# dollar values must end in 2 decimal places
		push(@{$vars->{'ORDER_ITEMS'}}, $unbound_edition_item);

		# also add the regulatory recovery fee
		my $regulatory_recovery_fee = sprintf("%0.2f", $unbound_edition_item->{'subtotal'} * 0.06);
		my $recover_fee_item_id = 1112;
		my $recover_fee_item = F::Order::get_item($dbh, $recover_fee_item_id);
		$recover_fee_item->{'quantity'} = 1;
		$recover_fee_item->{'price'}    = $regulatory_recovery_fee;
		$recover_fee_item->{'subtotal'} = $regulatory_recovery_fee;
		$vars->{'QUOTE_TOTAL'} += $regulatory_recovery_fee;
		push(@{$vars->{'ORDER_ITEMS'}}, $recover_fee_item);
	}
	else
	{
		# add software edition for PBXtra proposal
		for (my $i = 0; $i < @{$vars->{'EDITIONS'}}; $i++) 
		{
			if($vars->{'EDITIONS'}[$i]->{'item_id'} == $vars->{'SOFT_SELECTED'}) 
			{
	    		$vars->{'EDITIONS'}[$i]->{ 'quantity' } = 1;
	    		$vars->{'EDITIONS'}[$i]->{ 'subtotal' } = $vars->{'EDITIONS'}[$i]->{'price'};
	    		$vars->{'QUOTE_TOTAL'} += $vars->{'EDITIONS'}[$i]->{'subtotal'};

	    		$cce_quote = 1 if($vars->{'EDITIONS'}[$i]->{'item_id'} == kSOFTWARE_CCE_ITEM_ID);
	    		push(@{$vars->{'ORDER_ITEMS'}}, $vars->{'EDITIONS'}[$i]);
	    		last;
			}
		}
	}

	if ($vars->{'UNBOUND'})
	{
		# add PBXtra UNBOUND setup fees
		my %map_edition_to_setup = (
										1080	=> '1088',	# Standard Edition
										1082	=> '1090',	# Professional Edition
										1279	=> '1292',	# Call Center Edition
									);
		my $setup_item_id = $map_edition_to_setup{$vars->{'SOFT_SELECTED'}};
		my $setup_item = F::Order::get_item($dbh, $setup_item_id);
		$setup_item->{'quantity'} = $added_phones;
		$setup_item->{'subtotal'} = $added_phones * $setup_item->{'price'};
		$vars->{'QUOTE_TOTAL'} += $setup_item->{'subtotal'};
		$setup_item->{'subtotal'} = sprintf("%0.2f", $setup_item->{'subtotal'});	# prices must have 2 decimals
		push(@{$vars->{'ORDER_ITEMS'}}, $setup_item);
	}

	# we don't need to add HUD or anything else after this point if this is a PBXtra UNBOUND proposal
	return if ($vars->{'UNBOUND'});


	# validate the HUD software edition
	$vars->{'HUD_SELECTED'} = $q->param($vars->{'HUD'}[0]->{'group_name'});

	my $hud_agent_quote = 0;
	for (my $i = 0; $i < @{$vars->{'HUD'}}; $i++) 
	{
		if($vars->{'HUD'}[$i]->{'item_id'} == $vars->{'HUD_SELECTED'}) 
		{
	    	$vars->{'HUD'}[$i]->{ 'quantity' } = 1;
	    	$vars->{'HUD'}[$i]->{ 'subtotal' } = $vars->{'HUD'}[$i]->{'price'};
	    	$vars->{'QUOTE_TOTAL'} += $vars->{'HUD'}[$i]->{'subtotal'};

	    	$hud_agent_quote = 1 if ($vars->{'HUD'}[$i]->{'item_id'} == kHUD_AGENT_ITEM_ID);
	    	push(@{$vars->{'ORDER_ITEMS'}}, $vars->{'HUD'}[$i]);
	    	last;
		}
	}    

	$vars->{'USE_VOIP'} = $q->param('use_voip');

	$vars->{'UPSELL_UAE'} = $q->param('up_uae');
	
	# Small Server Discount - becomes zero (0) if this discount does not apply
	$vars->{'SMALL_SERVER_DISCOUNT'} = F::Order::get_small_server_discount($dbh,'',$added_phones,$cce_quote,$hud_agent_quote);
}


##########################
# Function: create_sugar_opportunity
# Creates a sugar opportunity
# args: TT variable hash ref, database ref, prop id, prop hash ref
# returns: void 
# usage: create_sugar_opportunity($vars, $dbh, $prop_id, $prop_href);
######################### 
sub create_sugar_opportunity
{
	my $vars = shift(@_);
	my $dbh  = shift(@_);
	my $proposal_id   = shift(@_);
	my $proposal_href = shift(@_);
	my $q = shift(@_);

	# opportunity data from form
	my $name     				= $vars->{'NAME'};
	my $email   				= $vars->{'EMAIL'};
	my $phone    				= $vars->{'CUST_PHONE'};
	my $total    				= $vars->{'QUOTE_TOTAL'};
	my $on_site_support	= $vars->{'ON_SITE_SUPPORT'};
	my $industry 				= $vars->{'INDUSTRY'};
	my $title_role 			= $vars->{'TITLE_ROLE'};

	#
	#	this is for the incrementing asterisks that may appear in the proposal .pdf
	#
	my $asterisks = '';

	if ($vars->{'UNBOUND'})
	{
		# save the recurring/non-recurring group_name lists and sub-totals
		F::Order::save_unbound_recurring_subtotals($vars);
		$asterisks .= '*';
		$vars->{'UNBOUND_MONTHLY_TAXES_ASTERISKS'} = $asterisks;
	}

	if ($vars->{'SALES_TAX'} > 0)
	{
		$asterisks .= '*';
		$vars->{'SALES_TAX_ASTERISKS'} = $asterisks;
	}

	# always add the asterisks for the QUOTE WIZARD
	$asterisks .= '*';
	$vars->{'WIZARD_ASTERISKS'} = $asterisks;

	# specify the subject
	my $subject = $name . "'s PBXtra Simple Quote Proposal #$proposal_id";	
	if ($vars->{'UNBOUND'})
	{
		$subject = $name . "'s UNBOUND Simple Quote Proposal #$proposal_id";
	}
	
	# SUGAR LOGIN via SOAP
	my $soap       = new F::SOAP::Lite( uri => kSUGAR_NAMESPACE, proxy => kSUGAR_URL );
	my $result     = $soap->login({ user_name => kSUGAR_USERNAME, password => kSUGAR_PASSWORD })->result;
	my $session_id = $result->{'id'};
	# Access to SUGAR DB
	my $sugar_dbh  = F::Database::sugarcrm_dbconnect();	


	my $assigned_user_id      = '';
	my $contact_id            = '';
	my $created_new_contact   = '';
	my $opportunity_reference = '';
	my $sales_team = 'Elephant Hunter';
	my $team_location = undef;
	# get the total seat count
	if ($vars->{'PHONE_CNT'} < 26)
	{
		$sales_team = 'Ant Hunter';
	}
	elsif ($vars->{'PHONE_CNT'} < 51)
	{
		$sales_team = 'Rhino Hunter';
	}

	# Felix Nilam - 11/02/2009
	# new rule to the opp assignment with the following order:
	# NB: if any assigned_user_id exists on the following, use that otherwise continue on to the next rule
	#
	# 1. find existing contact in SugarCRM by email address
	# 2. find if it is a valid salesperson
	# 2.a. if this is a reseller opp, do not use normal round robin, assign to owner of reseller account
	# 3. if on_site_supprt = yes, assign to special On-site Support team
	# 3.a. special hard coded assignments
	# 4. if it is a small opp, less than the threshold size defined in SugarCRM, assign it to Ant Hunter
	# 5. if it is a big opp, more than the threshold size defined in SugarCRM, assign it to Elephant Hunter
	# 6. round robin to Sales Quote Team

	# we now create the contact before the Opportunity
	# check to see if a contact already exists -- create one if it doesn't
	($created_new_contact,$contact_id,$assigned_user_id) = create_sugar_contact($soap,$session_id,$email,$name,$phone,$title_role);

	# Felix Nilam - 06/04/2009
	# if there is a matching contact, find out if the assigned user id
	# exists in the sugar_salesperson table.
	# if it does not exist, do not use this.
	if($assigned_user_id ne '')
	{
		my $test_sales_person = get_sugar_salesperson_by_sugarid($dbh,$assigned_user_id);
		if($test_sales_person->{'name'} eq '')
		{
			$assigned_user_id = '';
		}
	}
	#Anti spam
	# form field "rickscaptcha" must in form and have value in order to bypass this
	if ( !$q->param('rickscaptcha'))
	{
		$assigned_user_id = '9b830201-b960-28da-9968-446902877b08'; #chris v
	}

	# Felix Nilam - 01/21/2010
	# for reseller opps, do not use normal round robin if contact not found
	# store this assigned_user_id for later use
	my $found_auid = $assigned_user_id;

	# this precedes all other conditions
	# Reseller installation? Assign it to Lead Qualifier team
	# if not already assigned to someone, ergo a new customer, and requires onsite installation for >= 20 phones - Andre
	# 9/23/09 - Removed limit of 20 seats - all opps with on_site_support = yes go to the lq team
	if(!$assigned_user_id && $on_site_support eq 'yes' ) {
		$sales_team = 'On-site Support';
		$assigned_user_id = F::Sugar::assign_round_robin($sugar_dbh, $sales_team);
		# make a cookie, expires in a week. Use this value, to display Epic Fail message
		F::Cookies::create_cookie_in_browser($q, "f_fail", 1, '+7d', 'fonality.com');
		$vars->{EPIC_FAIL} = 1;
		# display error message: Epic Fail! (Corey named it that, and that is what it shall be called - Andre)
	}

	# All UAE opps go directly to John Kent
	if ( !$assigned_user_id )
	{
	    foreach my $item (@{$vars->{'ORDER_ITEMS'}})
		{
			if ($item->{'netsuite_id'} eq F::Order::kPBXTRA_UNIFIED_AGENT_NETSUITE_ID )
			{
				$assigned_user_id = 'b53000d8-7cf8-5c8e-4b41-45ad496684ee';         # John Kent
			}
		}
	}

	# Felix Nilam - 11/02/2009
	# if it falls under the "special opp" (Elephant or Ant Hunter)
	my $opp_size = 0;
	foreach my $item (@{$vars->{'ORDER_ITEMS'}})
	{
		if ($item->{'group_name'} eq 'PBXtra UNBOUND User Licenses' || $item->{'group_name'} eq 'Annual Support Group')
		{
			$opp_size = $item->{'quantity'};
			last;
		}
	}

	# Felix Nilam - 10/22/2009
	# only do special assign if not reseller opp
	my $reseller_cookie = 'FONALITYreseller';
	my $reseller_cookie_val = F::Cookies::get_cookie_from_browser($q, $reseller_cookie);
	my $cookie = F::Cookies::get_reseller_id_from_cookie($dbh,$q,$reseller_cookie_val,1) if(defined $reseller_cookie_val);
	my $reseller = 0;

	if(defined $cookie)
	{
		my $href = F::Resellers::get_reseller($dbh,$cookie->{'reseller_id'},'reseller_id');
		if($href->{'certified'} eq 'on')
		{
			$reseller = 1;
		}
	}

	# Felix Nilam - 10/29/2009
	# only do special opp if assigned user id is still empty
	if(!$reseller and $assigned_user_id eq '')
	{
		my $special_assigned_user_id = F::Sugar::special_assign_opp($sugar_dbh, $opp_size, $phone, $subject, $assigned_user_id);
		if($special_assigned_user_id ne '')
		{
			$assigned_user_id = $special_assigned_user_id;
		}
	}

	# Felix Nilam - 04/16/2009
	# do another round robin here if assigned user id is still empty at this point
	if($assigned_user_id eq ''){
		$assigned_user_id = (F::Sugar::assign_round_robin_by_active_agents($sugar_dbh, $sales_team));
	}

	# create a message for the new ticket
	my $content = "<br><p>$name (<a href='mailto:$email'>$email</a>) has created a proposal in the amount of (*";
	$content .= "*" if($vars->{'SUPPORT_SELECTED'} && $vars->{'PHONE_CNT'});
	$content .= "): \$$total</p>";

	# Sugar munges anything it "thinks" is an href
	$content   .= "<br>Recall Quote Page: ";
	
	$content   .= "<br>http://$ENV{'HTTP_HOST'}/q.cgi?";
	if ($vars->{'UNBOUND'})
	{
		$content .= "unbound_quote=1&";
	}
	$content   .= "src=$vars->{'TT_DIR'}&" if($vars->{'TT_DIR'});
	$content   .= "recall=$proposal_id&email=$email <br>";

	$content   .= "<br>Proposal pdf: ";
	$content   .= "<br>http://$ENV{'HTTP_HOST'}/pbxtra_proposal_downloads/p" . $proposal_href->{'random_proposal_string'} . ".pdf <br>";

	$content   .= "<br>Place Order: ";
	$content   .= "<br>http://$ENV{'HTTP_HOST'}/q.cgi?";
	if ($vars->{'UNBOUND'})
	{
		$content .= "src=unbound&";
	}
	else
	{
		$content .= "src=$vars->{'TT_DIR'}&" if($vars->{'TT_DIR'});
	}
	$content .= "convert=$proposal_id&eml=$email <br>";

	$content   .= "<br>Phone number is: $phone";

	if($vars->{'USE_VOIP'} =~ /yes/i)
	{
		$content .= "<br>VoIP: $name has VoIP phone service.";
	}
	elsif($vars->{'USE_VOIP'} =~ /no/i || $vars->{'USE_VOIP'} eq '')
	{
		$content .= "<br>VoIP: $name does not have VoIP phone service.";
	}
	else
	{
		$content .= "<br>VoIP: $name does not know if currently using a VoIP phone service.";
	}

	if($vars->{'UPSELL_UAE'} =~ /yes/i)
	{
		$content .= "<br>$name uses Salesforce.com or is interested in CRM integration. $name is a potential UAE Customer.";
	}

	$content   .= "</p><pre>";
	$content   .= "Description                                                 Price  Qty    Sub Total<br>";
	$content   .= "-----------------------------------------------------+-----------+----+------------<br>";

	my $item_group_list = F::Order::kITEM_GROUP_LIST;
	foreach my $group (@$item_group_list)
	{
		foreach my $item (@{$vars->{'ORDER_ITEMS'}})
		{
	    	if ($item->{'group_name'} =~ /^$group$/i)
	    	{
				$content .= sprintf("%-53s", $item->{'name'});
				$content .= '| $' . sprintf("%9s",$item->{'price'});
				$content .= '|'   . sprintf("%4s",$item->{'quantity'});
				$content .= '| $' . sprintf("%10s",$item->{'subtotal'});
				$content .= "<br>";
	    	}
		}
	}
	$content .= "<p>";

	if ($vars->{'SMALL_SERVER_DISCOUNT'})
	{
		$content .= "<br>      Limited Time Promotion for 10 Seats or Less: \$ ";
		$content .= sprintf("%10s", '-' . F::Util::format_comma($vars->{'SMALL_SERVER_DISCOUNT'}));
	}

	# SUB-TOTAL
	$content .= '<br>                                        SUB TOTAL: $ ';
	$content .= sprintf("%10s", F::Util::format_comma($vars->{'SUBTOTAL'}));

	if ($vars->{'SALES_TAX'} > 0)
	{
		my $sales_tax_content = $vars->{'SALES_TAX_ASTERISKS'} . ' Estimated ' . $vars->{'SHIPPING_STATE'};
		$sales_tax_content   .= ' Sales Tax (' . $vars->{'SALES_TAX_ENGLISH'} . '%)';
		$sales_tax_content = sprintf("%50s",$sales_tax_content);
		$content .= "<br>$sales_tax_content \$ " . sprintf("%10s", F::Util::format_comma($vars->{'SALES_TAX'}));
	}
	
	if ($vars->{'SHIPPING_COST'} > 0)
	{
		my $shipping_and_handling = "Shipping and Handling (" . $vars->{'SHIPPING_SERVICE'} . ')';
		$shipping_and_handling = sprintf("%50s",$shipping_and_handling);
		$content .= "<br>$shipping_and_handling \$ " . sprintf("%10s",$vars->{'SHIPPING_COST'});
	}

	if ($vars->{'UNBOUND'})
	{
		my $first_month_total = $vars->{'WIZARD_ASTERISKS'} . " FIRST MONTH'S TOTAL:";
		$first_month_total = sprintf("%50s",$first_month_total);
		$content .= "<br>$first_month_total \$ " . sprintf("%10s", $vars->{'QUOTE_TOTAL'});

		my $monthly_recurring_text = "$vars->{UNBOUND_MONTHLY_TAXES_ASTERISKS} Recurring Monthly Charges:";
		$monthly_recurring_text = sprintf("%50s",$monthly_recurring_text);
		$content .= "<br>$monthly_recurring_text \$ " . sprintf("%10s", F::Util::format_comma($vars->{'RECURRING_TOTAL'}));
	}
	else
	{
		my $my_total = $vars->{'WIZARD_ASTERISKS'} . ' TOTAL:';
		$my_total = sprintf("%50s",$my_total);
		$content .= "<br>$my_total \$ " . sprintf("%10s", $vars->{'QUOTE_TOTAL'});
	}

	$content .= "</pre><br>";

#    if($vars->{'SUPPORT_SELECTED'} && $vars->{'PHONE_CNT'})
#    {
#		$vars->{'SHOW_SUPPORT_MSG'} = 1;
#		$vars->{'PORT_CNT'} = 0;
#		$vars->{'SUPPORT_NAME_WITHOUT_STARS'} = "Software & Support Agreement";
#		$vars->{'SUPPORT_NAME_WITHOUT_STARS'} .= "s" if($vars->{'PHONE_CNT'} != 1);
#
#		$content .= "*($vars->{PHONE_CNT} Phone";
#		$content .= "s" unless ($vars->{'PHONE_CNT'} == 1);
#		$content .= " + 0 Phone Ports";
#		$content .= ") = $vars->{PHONE_CNT} Software & Support Agreement";
#		$content .= "s" unless ($vars->{'PHONE_CNT'} == 1);
#    }
	$content .= "<br>";

	if ($vars->{'UNBOUND'})
	{
		$content .= "$vars->{UNBOUND_MONTHLY_TAXES_ASTERISKS} State and Local Taxes not included.<BR>";
	}

	if ($vars->{'SALES_TAX'} > 0)
	{
		$content .= "$vars->{SALES_TAX_ASTERISKS} This is an estimate based on your state. This amount may vary slightly based on your ";
		$content .= "exact tax jurisdiction and will be confirmed in your final invoice.<BR>";
	}

	$content .= "$vars->{WIZARD_ASTERISKS} This is a simple quote estimate based on the preliminary information $name provided";
	$content .= "</p>";
	$content = escapeHTML($content);

	# save the PRODUCT name
	my $product_name = 'PBXtra';
	if ($vars->{'UNBOUND'})
	{
		$product_name = 'UNBOUND';
	}

	# prepare values for a NEW OPPORTUNITY
	my $name_value_pairs = 	[
								{
									'name'  => 'name',
									'value' => $subject
								},
								{
									'name'  => 'description',
									'value' => $content
								},
								{
									'name'  => 'amount',
									'value' => $total
								},
								{
									'name'  => 'team_id',
									'value' => 1
								},
								{
									'name'  => 'sales_stage',
									'value' => 'New'
								},
								{
									'name'  => 'opportunity_type',
									'value' => 'New Business'
								},
								{
									'name'  => 'last_email_c',
									'value' => 'Customer'
								},
								{
									'name'  => 'opp_product_c',
									'value' => $product_name
								},
								{
									'name'  => 'on_site_support_c',
									'value' => $on_site_support
								},
								{
									'name'  => 'industry_c',
									'value' => $industry
								}
							];

	my $lead_source = "Web Quote - Simple";	# DEFAULT - overwrite as necessary;
	my $referrer_site   = 'referringsite';
	my $request_cookie  = 'requesturl';
	my $request_url  = F::Cookies::get_cookie_from_browser($q,$request_cookie) or '';
	my $referringsite= F::Cookies::get_cookie_from_browser($q,$referrer_site)  or '';
	if ($request_url =~ /\Wsource=([^&]+)/)
	{
		$lead_source = $1;
		unless ($request_url =~ /\Wdontmodsource=1/)
		{
			$lead_source = "Web Quote $lead_source";
		}

		if ($request_url =~ /\Wuserid=([^&]+)/)
		{
			$assigned_user_id = $1;
		}
	}

	if ($lead_source eq 'Web Quote CJ')
	{
		# Commission Junction leads
		$sales_team  = "Commission Junction Sales";
		$lead_source = "Web Quote CJ";
	}
	
	if(($lead_source ne '' && $lead_source ne 'Web Quote - Simple' ) && ($vars->{'TT_DIR'} == 'sta' || $vars->{'TT_DIR'} == 'sim2')){
		push(@$name_value_pairs, { 'name' => 'lead_source', 'value' => $lead_source });
	} else {
	if($vars->{'LEAD_SOURCE'})
	{
		# SOME VERSIONS OF OUR QUOTE PAGE (TMC SO FAR) WILL USE THIS AND TAKE PRECEDENCE OVER OTHER VALUES
			push(@$name_value_pairs, { 'name' => 'lead_source', 'value' => $vars->{'LEAD_SOURCE'} });
	}
	elsif($lead_source)
	{
			push(@$name_value_pairs, { 'name' => 'lead_source', 'value' => $lead_source });
	}	
	}
	# save the ROUND ROBIN TEAM
	push(@$name_value_pairs, { 'name' => 'round_robin_team', 'value' => $sales_team });

	# save the ASSIGNED USER ID if there is one
	unless ($assigned_user_id eq '')
	{	
		push (@$name_value_pairs, { 'name'=>'assigned_user_id', 'value'=>$assigned_user_id });
	}
	
	# if this is a pbxtra quote, add this opportunity value
	push(@$name_value_pairs, { 'name' => 'pbxtra_com_c', 'value' => 1 }) if($vars->{'PBXTRA'});
	
	# Felix Nilam - 08/12/2009
	# set reseller details
	my $reseller_cookie = 'FONALITYreseller';
	my $reseller_cookie_val = F::Cookies::get_cookie_from_browser($q, $reseller_cookie);
	my $cookie = F::Cookies::get_reseller_id_from_cookie($dbh,$q,$reseller_cookie_val,1) if(defined $reseller_cookie_val);
	my $reseller;

	if(defined $cookie)
	{
		my $href = F::Resellers::get_reseller($dbh,$cookie->{'reseller_id'},'reseller_id');
		if($href->{'certified'} eq 'on')
		{
			# Felix Nilam - 01/21/2010
			# for WTG-Agent, BD-Agent and Fonality-Affiliate
			# just assign the opp to owner of reseller account
			my $new_assigned_user_id = '';
			my $res_acc = F::Sugar::get_sugar_account_by_id($sugar_dbh,$href->{'sugar_account_id'});
			my @special_reseller_type = qw/WTG-Agent BD-Agent Fonality-Affiliate/;
			if(grep { $_ eq $href->{'status'} } @special_reseller_type)
			{
				$new_assigned_user_id = $res_acc->{'assigned_user_id'};
			}
			else
			{
				# for other resellers, only assign to account owner if contact was not found yet
				if($found_auid eq '')
				{
					$new_assigned_user_id = $res_acc->{'assigned_user_id'};
				}
			}
			
			# override the lead source
			my $ind = 0;
			foreach my $thispair (@$name_value_pairs)
			{
				if($thispair->{'name'} eq 'lead_source')
				{
					delete @$name_value_pairs[$ind];
					@$name_value_pairs[$ind] = {'name' => 'lead_source', 'value' => 'Web Quote - Simple - Reseller'};
				}
				if($thispair->{'name'} eq 'opportunity_type')
				{
					delete @$name_value_pairs[$ind];
					@$name_value_pairs[$ind] = {'name' => 'opportunity_type', 'value' => 'UC Authorized Reseller'};
				}
				if($new_assigned_user_id ne '')
				{
					if($thispair->{'name'} eq 'assigned_user_id')
					{
						delete @$name_value_pairs[$ind];
						@$name_value_pairs[$ind] = {'name' => 'assigned_user_id', 'value' => $new_assigned_user_id};
					}
				}
				$ind++;
			}
			
			my $reseller_account_id;
			my $reseller_contact_id;

			$reseller_account_id = $href->{sugar_account_id};

			# find the matching sugar contact based on the email address
			my $reseller_contact = F::Sugar::get_sugar_contact_by_email($sugar_dbh,$href->{email});
			if (ref($reseller_contact) eq "ARRAY" && ref($reseller_contact->[0]) eq "HASH")
			{
				$reseller_contact_id = $reseller_contact->[0]->{'id'};
			}

			if(defined($reseller_account_id))
			{
				push(@$name_value_pairs, { 'name' => 'account_id', 'value' => $reseller_account_id});
			}
			if(defined($reseller_contact_id))
			{
				push(@$name_value_pairs, { 'name' => 'contact_id_c', 'value' => $reseller_contact_id});
			}
		}
	}

	#
	# now create the NEW OPPORTUNITY
	#
	$result = $soap->set_entry( $session_id, 'Opportunities', $name_value_pairs )->result;
	my $sugar_opportunity_id = $result->{'id'};

	# get the salesperson assigned to the Opportunity
	$result = $soap->get_entry(	$session_id,
							'Opportunities',
							$sugar_opportunity_id,
							[
								'id',
								'assigned_user_id',
								'opportunity_reference_c'
							]
	)->result;
	
	foreach my $name_value (@{$result->{'entry_list'}->[0]->{'name_value_list'}})
	{
		if ($name_value->{'name'} eq 'assigned_user_id')
		{
	    	$assigned_user_id = $name_value->{'value'};
		}
		elsif ($name_value->{'name'} eq 'opportunity_reference_c')
		{
	    	$opportunity_reference = $name_value->{'value'};
		}
	}
	
	# update the quote_header with the RT Ticket ID 
	F::Order::update_quote_header($dbh,	{
											quote_id             => $proposal_id,
											sugar_opportunity_id => $sugar_opportunity_id,
											salesperson_id       => $assigned_user_id
	});

	# add a fake "email" to the Opportunity so the sales staff can use it to easily reply to the requestor
	$result = $soap->set_entry(	$session_id,
								'Emails',
								[
									{
										'name'  => 'name',
										'value' => "[#$opportunity_reference] $subject"
									},
									{
										'name'  => 'from_addr',
										'value' => $email
									},
									{
										'name'  => 'description',
										'value' => "Re: Proposal # $name"
									},
									{
										'name'  => 'from_name',
										'value' => $name
									},
									{
										'name'  => 'type',
										'value' => 'Archived'
									},
									{
										'name'  => 'status',
										'value' => 'read'
									},
									{
										'name'  => 'parent_type',
										'value' => 'Opportunities'
									},
									{
										'name'  => 'parent_id',
										'value' => $sugar_opportunity_id
									},
									{
										'name'  => 'assigned_user_id',
										'value' => $assigned_user_id
									},
									{
										'name'  => 'team_id',
										'value' => 1	# Global team
									}
								]
	)->result;

	my $email_id = $result->{'id'};

	$result = $soap->set_relationship(	$session_id,
										{
											'module1'    => 'Opportunities',
											'module1_id' => $sugar_opportunity_id,
											'module2'    => 'Emails',
											'module2_id' => $email_id
										}
	)->result;

	# add a note to the Opportunity -- the Description will be overwritten every time
	# a proposal is modified, but notes will save an historical record of all proposals

	$result = $soap->set_entry(	$session_id,
								'Notes',
								[
									{
										'name'  => 'name',
										'value' => "\$$total proposal"
									},
									{
										'name'  => 'team_id',
										'value' => 1	# Global team
									},
									{
										'name'  => 'description',
										'value' => $content
									},
									{
										'name'  => 'parent_type',
										'value' => 'Opportunities'
									},
									{
										'name'  => 'parent_id',
										'value' => $sugar_opportunity_id
									}
								]
	)->result;

	if ($created_new_contact)
	{
		# set the Contact's assigned user (salesperson)
		# so new opportunities generated by this email address will be assigned to the same salesperson
		$result = $soap->set_entry(	$session_id,
						'Contacts',
						[
						 {
						     'name'  => 'id',
						     'value' => $contact_id
						 },
						 {
						     'name'  => 'assigned_user_id',
						     'value' => $assigned_user_id
						 }
						]
		)->result;
	}

	# associate the Contact with the new Opportunity
	$result = $soap->set_relationship(	$session_id,
										{
											'module1'    => 'Contacts',
											'module1_id' => $contact_id,
											'module2'    => 'Opportunities',
											'module2_id' => $sugar_opportunity_id
										}
	)->result;

	# end of NEW OPPORTUNITY


	# get the salesperson info using the Sugar assigned ID
	my $sales_person = get_sugar_salesperson_by_sugarid($dbh,$assigned_user_id);
	$vars->{'SALES_PERSON_NAME'}  = $sales_person->{'name'};
	$vars->{'SALES_PERSON_TITLE'} = $sales_person->{'title'};
	$vars->{'SALES_PERSON_PHONE'} = $sales_person->{'phone'};
	$vars->{'SALES_PERSON_EMAIL'} = $sales_person->{'email'};

	return $opportunity_reference;
}


##########################
# Function: create_sugar_contact
# Creates a new Sugar Contact in CRM if it does not exist already
# args: SOAP hook, session id, customer email address string, customer name string,
#       customer phone string
# returns: new contact boolean, contact id, assigned sales person id
# usage: ($new_contact, $contact_id, $assigned_user_id) = 
#         create_sugar_contact($soap, $ses_id, $email, $name, $phone);
######################### 
sub create_sugar_contact
{
	my $soap       = shift(@_);
	my $session_id = shift(@_);
	my $email      = shift(@_);
	my $name       = shift(@_);
	my $phone      = shift(@_);
	my $title_role = shift(@_);
	my $contact_id          = '';
	my $assigned_user_id    = '';
	my $created_new_contact = 0;

	# look for a Contact in Sugar matching the customer's email address
	my $sugar_dbh = F::Database::sugarcrm_dbconnect();
	my $result    = F::Sugar::get_sugar_contact_by_email($sugar_dbh, $email);

	if (ref($result) eq "ARRAY" && ref($result->[0]) eq "HASH")
	{
		#
		#   the Contact already exists
		#
		$contact_id       = $result->[0]->{'id'}; 
		$assigned_user_id = $result->[0]->{'assigned_user_id'};

	}
	else
	{
		#
		#   create a new Contact
		#
		$created_new_contact = 1;
		$result = $soap->set_entry(	$session_id,
									'Contacts',
									[
										{
											'name'  => 'last_name',
											'value' => $name
										},
										{
											'name'  => 'email1',
											'value' => $email
										},
										{
											'name'  => 'phone_work',
											'value' => $phone
										},
										{
											'name'  => 'title',
											'value' => $title_role
										}
									]
		)->result;

		$contact_id = $result->{'id'};
	}

	return ($created_new_contact,$contact_id,$assigned_user_id);
}


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
	
	if($ttpath eq 'tmc')
	{
		$vars->{'NO_NAV'}      = 1;
		$vars->{'TMC'}         = 1;
		$vars->{'LEAD_SOURCE'} = "TMCnet.com";
	}
	elsif($ttpath eq 'pbxtra')
	{
		$vars->{'BASE_DIR'}    = cwd() . '/';
		$vars->{'PBXTRA'}      = 1;
	}
	
	# new, refreshed simple quote launched around 2009-01-13
	# pgoddard
	elsif($ttpath eq 'sim2')
	{
		$ttpath             = 'pbxtra';
		$vars->{'BASE_DIR'} = cwd() . '/';
		#$vars->{'PBXTRA'}   = 1;
		$vars->{'LEAD_SOURCE'} = "Simple Quote sim2";
	}
	elsif($ttpath eq 'sta')
	{
		$ttpath             = 'pbxtra';
		$vars->{'BASE_DIR'} = cwd() . '/';
		#$vars->{'PBXTRA'}   = 1;
		$vars->{'LEAD_SOURCE'} = "Simple Quote sta";
	}
	elsif($ttpath eq 'sta-old')
	{
		$ttpath             = 'pbxtra';
		$vars->{'BASE_DIR'} = cwd() . '/';
		#$vars->{'PBXTRA'}   = 1;
		$vars->{'LEAD_SOURCE'} = "Simple Quote sta";
	}

	# mag360 obsolete. pgoddard 04.08.2009
	# note: if a child is obsolete, simply delete it
	# it will default to pbxtra. andre 04.29.2009
	else
	{
		$ttpath             = 'pbxtra';
		$vars->{'BASE_DIR'} = cwd() . '/';
		$vars->{'PBXTRA'}   = 1;
	}


	$vars->{'TT_FULL_DIR'} = cwd() . '/' . $ttpath;
	$vars->{'TT_DIR'}      = $ttpath;
	$vars->{'TT_CONSTANTS_DIR'} = cwd() . '/';

	return $ttpath;
}

##############################################################################
## is_exclusive_customer: checks to see if this customer is associated with Dell, PCMall, or Fonality
## by looking in the SugarCRM (matching email and phone number)
## Handles customer mutual exclusion
##    Args: CGIobj,TT vars hash
## Returns: returns quote tool id
##############################################################################
sub is_exclusive_customer
{
	my $q         = shift(@_);
	my $vars      = shift(@_);
	
	my $lead_email = $q->param('email');
	my $lead_phone = $q->param('cust_phone');

	my $this_is_fon = -1;
	my $this_is_dell = 1;
	my $this_is_mall = 2;
	
	my $sugar_dbh = F::Database::sugarcrm_dbconnect();

	# Does lead already exist in CRM?
	my ($lead_email_found, $lead_phone_found, $lead_contact_id, $assigned_user_id);

	# look for LEAD CONTACT by email address
	($lead_email, $lead_email_found, $assigned_user_id, $lead_contact_id) = F::Sugar::is_email_contact($sugar_dbh, $lead_email);

	# look for LEAD CONTACT by phone number
	($lead_phone,$lead_phone_found,$assigned_user_id,$lead_contact_id) = F::Sugar::is_phone_contact($sugar_dbh,$lead_phone) if(!$lead_email_found);

	# is this lead associated with a Dell Voip Specialist?
	my $is_which_quote = 0;
	if(defined $assigned_user_id && ($lead_phone_found || $lead_email_found))
	{
		my $dell_sales_people = F::Sugar::get_sugar_users_by_team($sugar_dbh, "Dell_Sales");
		foreach my $person (@$dell_sales_people)
		{
		    if($person->{'id'} eq $assigned_user_id)
		    {
				$is_which_quote = $this_is_dell;
				last;
		    }
		}
		# if it is, set cookie to 1 = Dell
		if($is_which_quote == $this_is_dell)
		{
		    my $cookie_name = "f_error";
		    F::Cookies::create_cookie_in_browser($q, $cookie_name, $is_which_quote, '+10y', 'fonality.com');      
		}
		# else -1 = Fonality, 2 = PC Mall (cookie does not like setting value to 0)
		else
		{
			# Is this a PC Mall customer (would be assigned to Dan Jackman)
			my $djackman = F::Sugar::get_sugar_user_by_email($sugar_dbh, 'djackman@fonality.com');
			my ($djackman_id, $cookie_value);
			$djackman_id = $djackman->{id} if(ref($djackman) eq "HASH");
			
			$is_which_quote = $this_is_fon;
			if($vars->{'PCMALL'} && $assigned_user_id eq $djackman_id)
			{
				$is_which_quote = $this_is_mall;
			}
			
			my $cookie_name = "f_error";
	    	F::Cookies::create_cookie_in_browser($q, $cookie_name, $is_which_quote, '+10y', 'fonality.com');
		}
	
	}
	else
	{
		$is_which_quote = $this_is_fon if($vars->{'PBXTRA'} || $vars->{'TMC'});
		$is_which_quote = $this_is_mall if($vars->{'PCMALL'});
	}
	
	return $is_which_quote;
}

##############################################################################
## which_quote_type: checks to see which tool this customer can use
##    Args: CGIobj,TT vars hash, salesperson hash, reseller hash
## Returns: 1|0 (customer => tool (1) | customer !=> tool (0)), template TT error page
##############################################################################
sub quote_type
{
	my $q                 = shift(@_);
	my $vars              = shift(@_);
	my $sales_or_reseller = shift(@_);
	my $tmpl_name         = shift(@_);
	my $lookup_sugar      = shift(@_) || 0;

	# assigned
	my $this_is_fon  = -1;
	my $this_is_dell = 1;
	my $this_is_mall = 2;
	
	# unassigned
	my $quote_value = 0;

	# Does a cookie exist?
	$quote_value = has_quote_cookie($q, $vars, $sales_or_reseller);
	# if a customer cookie exists
	if($quote_value != 0)
	{
		# is this customer not supposed to be using this tool?
		if( ($vars->{'PCMALL'} && $quote_value != $this_is_mall) || ($vars->{'PBXTRA'} || $vars->{'TMC'}) && $quote_value != $this_is_fon)
		{
	 		my $error_msg_disguised_as_completion_msg = "<img src='images/icon_warning_big.gif' style='margin-right: 10px;' align=absmiddle>";
	    	$error_msg_disguised_as_completion_msg   .= "<font class='order_top_heading'>Sorry, we cannot create your quote!</font>";
			push (@{$vars->{MSG_COMPLETED}}, $error_msg_disguised_as_completion_msg);
	    	$vars->{'LOGIN_ERROR'} = 1;
			
			return (1, 'order_error_dell.tt') if($quote_value == $this_is_dell);
			return (1, 'order_error_pcmall.tt')  if($quote_value != $this_is_fon && ($vars->{'PBXTRA'} || $vars->{'TMC'}));
			return (1, 'order_error_fon.tt') if($quote_value != $this_is_mall && $vars->{'PCMALL'});
		}
	}

	# this must be a new customer (not a reseller or a sales person)
	if($lookup_sugar && !defined $sales_or_reseller)
	{
		# is this customer already exclusively assigned to one of the other tools?
		$quote_value = is_exclusive_customer($q, $vars);
	
		if( ($vars->{'PCMALL'} && $quote_value != $this_is_mall) || $vars->{'PBXTRA'} && $quote_value != $this_is_fon)
		{
			my $error_msg_disguised_as_completion_msg = "<img src='images/icon_warning_big.gif' style='margin-right: 10px;' align=absmiddle>";
	    	$error_msg_disguised_as_completion_msg   .= "<font class='order_top_heading'>Sorry, we cannot create your quote!</font>";
			push (@{$vars->{MSG_COMPLETED}}, $error_msg_disguised_as_completion_msg);
	    	
			return (1, 'order_error_dell.tt') if($quote_value == $this_is_dell);
			return (1, 'order_error_pcmall.tt')  if($quote_value != $this_is_fon && ($vars->{'PBXTRA'} || $vars->{'TMC'}));
			return (1, 'order_error_fon.tt') if($quote_value != $this_is_mall && $vars->{'PCMALL'});
		}
	}

	# new situation. Epic fail message is displayed, if cookie f_fail is true
	my $fail_value = has_quote_cookie($q, $vars, $sales_or_reseller, "f_fail");
	return (1, 'qwiz_error_fail.tt') if($fail_value);
	
	return (0, $tmpl_name);
}

##############################################################################
## has_quote_cookie: checks to see if this customer has the quote id cookie
## allows/denies access based on cookie value
## Dell and Fonality require mutual exclusion
##    Args: CGIobj,TT vars hash
## Returns: 1 (customer => tool (1) | customer !=> tool (0))
##############################################################################
sub has_quote_cookie
{
	my $q                 = shift(@_);
	my $vars              = shift(@_);
	my $sales_or_reseller = shift(@_);
	my $is_quote_cookie   = shift(@_) || "f_error";

	if(defined $sales_or_reseller)
	{
		F::Cookies::create_cookie_in_browser($q, $is_quote_cookie, 'dummy', '-1d', 'fonality.com');
	}
	# this is a customer or not logged in salesperson (can't tell)
	# if they have the "Can't Use Quote Tool" cookie, print error screen on loading of Quote Tool
	else
	{
		my $cookie_value = F::Cookies::get_cookie_from_browser($q, $is_quote_cookie);
		return $cookie_value if(defined $cookie_value);
	}

	return 0;
}

#############################################################################
# USER ERROR!
# form_repop: if MSG_ERROR then re-populate $vars with data from $q->param
#
#    Args: CGIobj, Template Toolkit "$vars" reference
# Returns: $vars
#############################################################################
sub form_repop
{
	my $q    = shift(@_);
	my $vars = shift(@_);

	if ($vars->{'MSG_ERROR'})
	{
		foreach ($q->param())
		{
			$vars->{$_} = $q->param($_);
			# also save UPPER case version of the values
			my $key = uc($_);
			$vars->{$key} = $q->param($_);
		}
	}

	return $vars;
}
