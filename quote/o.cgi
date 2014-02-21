#!/usr/bin/perl

use strict;
use lib '/html/pbxtra';
#use lib '/opt/rt3/lib'; # for RT ticketing system
use Apache::Request();
#use Template ();
use Data::Dumper;
use F::Database qw(mysql_connect);
use F::Order;
use F::Mail;
use F::Resellers qw(get_reseller);
use Mail::Sender;
use F::Sugar;
use F::Cookies qw(get_cookie_from_browser get_reseller_id_from_cookie);
use F::Customer qw(update_customer);
use F::BlueHornet;
use F::Country;
use F::IntranetSupport;
use Apache::Cookie();
use Date::Calc qw(Date_to_Days Days_in_Month);
use F::Billing;
use F::Address qw(add);
use F::Contact qw(add);
use F::Support;
use F::PBXtraAnnualSupport;
use F::Extensions;
use CGI qw(escapeHTML);
use Cwd;
use Business::CreditCard;
eval('use CGI::Carp qw(fatalsToBrowser);');

#use Data::Dumper;
#warn Dumper \@INC;
use MIME::Entity;
# Sugar CRM
use F::SOAP::Lite;

use F::RT;
use F::NetSuite;
use F::NetSuite::Customer;
use F::NetSuite::CashSale;
use F::NetSuite::Utils;
#trace;
#debug_lvl(dMETHOD);
#debug_lvl(dLVL1);
#debug_lvl(dLVL2);
#debug_lvl(dXML);
# used for this instance of o.cgi so we can relate error emails with messages displayed to the user
use constant ERRID  => int(rand(10000));
# we present the user with a common error - the real error is sent to the email specified below
use constant COMMON_ERROR => 'There was an error while processing your order.<br>Please contact billing@fonality.com for assistance. (' . ERRID .')';
# this is the email where errors are sent
use constant err_email => 'errors@fonality.com';
#use constant err_email => 'pmadison@fonality.com';


# THIS DIRECTORY IS USED BY RT TO RETURN TO THE WORKING DIRECTORY
my $working_dir = `pwd`;
$working_dir =~ s/^\s+|\s+$//g;


{
main(@_);
exit;
}


sub main
{ 
	my @orig = @_;

	# UPS shipping constants
	my $ups_access_key   = 'CBF152279E575CC0';

	# GLOBAL VARIABLES
	my $reseller_cookie = 'FONALITYreseller';
	my $reseller_id     = undef;
	my $valid_reseller  = 0;
	my $order_id        = undef;

	# current year, month and day
	my ($current_year,$current_month0,$current_day0) = get_current_date();

	my $q = new Apache::Request(@orig, DISABLE_UPLOADS => 0, POST_MAX => (10 * (1024 * 1024))); 
	my($dbh) = mysql_connect() or die "Unable to connect to database; $!"; # Connect to the db
	my $vars = {};

	# STORE THE ROOT DIRECTORY OF THE TEMPLATE TOOLKIT FILES HERE
	my $template_dir = get_template_dir($q);
	if ($template_dir eq 'unbound')
	{
		$vars->{'UNBOUND'} = 1;
	}

	$vars->{'TT_DIR'}   = $template_dir;
	$vars->{'TT_FULL_DIR'} = cwd() . '/' . $template_dir;
	$vars->{'BASE_DIR'} = cwd() . '/';
	$vars->{'TT_CONSTANTS_DIR'} = $vars->{'BASE_DIR'};

	my $tt_object = Template->new({
		ABSOLUTE  => 1,
		EVAL_PERL => 1,
		PRE_PROCESS  => $vars->{'BASE_DIR'} . 'config.tt',
		WRAPPER => 'wrapper2_order.tt',
		INCLUDE_PATH => $template_dir, 
		PRE_CHOMP => 1, TRIM => 1, POST_CHOMP => 1
	});

	$vars->{'SERVER_NAME'} = $ENV{'HTTP_HOST'};

	# set the global order ID if it exists - it should
	$order_id        = $q->param('oid') or undef;
	$vars->{'OID'}   = $order_id;
	$vars->{'ADDON'} = $q->param('addon') or undef;
	$vars->{'SID'}   = $q->param('sid')   or undef;
	$vars->{'HOST'}  = '/';
	$vars->{'SCRIPT_URL'} = 'https://' . $ENV{'HTTP_HOST'} . $ENV{'SCRIPT_NAME'}; 
#$vars->{'SCRIPT_URL'}='http://'.$ENV{'HTTP_HOST'}.$ENV{'SCRIPT_NAME'};	# DEV ONLY

	# these details might be absent in some cases with addons - make sure of them
	my $order_to_get_addon_details = F::Order::get_order($dbh,$order_id);
	if ($order_to_get_addon_details->{'order_type'} eq 'addon')
	{
		$vars->{'ADDON'} = 1;
		$vars->{'SID'} = $order_to_get_addon_details->{'server_id'};
		my $server_info = F::Server::get_server_info($dbh,$vars->{'SID'}) or err($q);
		$vars->{'CP_VERSION'} = $server_info->{'cp_version'};
	}


	#
	#	INTRANET
	#
	my (undef, $intranet_id, $intranet_name) = F::IntranetSupport::get_cookie($dbh);
	if ($intranet_id)
	{
		if ($intranet_name eq 'pmadison' or
		    $intranet_name eq 'dkim@fonality.com' or
		    $intranet_name eq 'dconant@fonality.com' or
		    $intranet_name eq 'jwalling@fonality.com' or
		    $intranet_name eq 'astinnett@fonality.com' or
		    $intranet_name eq 'rick' or
		    $intranet_name eq 'jjenkins@fonality.com')
		{
			$vars->{'VALID_INTRANET_USER'} = 1;
		}
	}


	# Map our order back to a quote so we can check our referrer information, setting it if necessary -mstofko
	if ($order_id and !$intranet_id)
	{
		# First get our order entry
		my $order_entry = F::Order::get_order($dbh, $order_id);

		if (ref($order_entry) eq 'HASH')
		{
			# Then our quote entry
			my $quote_entry = F::Order::get_quote($dbh, $order_entry->{'quote_header_id'});

			if (ref($quote_entry) eq 'HASH')
			{
				# Then our user's browser cookies
				my $referrer = F::Cookies::get_cookie_from_browser($q, 'referringsite')  || ''; 
				my (undef, $r_url) = split(/\r/, $referrer);
				my $requested = F::Cookies::get_cookie_from_browser($q, 'requesturl') || ''; 

				# If our quote entry has a blank referrer or a first_requesturl with less info update our quote entry...
				if ($quote_entry->{'referral_site'} eq '' or $quote_entry->{'referral_date'} eq '' or (length($requested) > length($quote_entry->{'first_requesturl'}) and $requested !~ /\.cgi/i))
				{
					# Update it with our cookie data
					update_quote_header($dbh, {'quote_id' => $order_entry->{'quote_header_id'}, 'referral_site' => $r_url, 'first_requesturl' => $requested});
				}
			}
		}
	}


	# - PBXtra UNBOUND does NOT use resellers
	unless ($vars->{'UNBOUND'})
	{
		# Set the RESELLER_ID in TT so we can remove the google analytics js if it's a reseller (in wrapper.tt)
		$vars->{'RESELLER_ID'} = get_cookie($q, $reseller_cookie);

		# get cookie - reseller's ID and discount
		# these values are actually in the database but derived from a random string in the cookie
		if (my $reseller_cookie_val = get_cookie($q, $reseller_cookie))
		{
			my $cookie = F::Cookies::get_reseller_id_from_cookie($dbh,$q,$reseller_cookie_val,1) or err($q);
			if (defined $cookie)
			{
				my $href = F::Resellers::get_reseller($dbh,$cookie->{'reseller_id'},'reseller_id') or err($q);
				$vars->{'RESELLER_ORDER'} = 1;
				$vars->{'RESELLER_NAME'}  = $href->{'company'};
				$reseller_id              = $href->{'reseller_id'};
				$vars->{'RESELLER_STATUS'} = $href->{'status'};
				$vars->{'RESELLER_NETSUITE_ID'} = $href->{'netsuite_id'};
				if($href->{'certified'} eq 'on')
				{
					$vars->{'VALID_RESELLER'} = 1;
					$vars->{'FONALITY_INSTALL_REQUIRED'} = $href->{'fonality_install_required'};
					$valid_reseller           = 1;
				}
				else
				{
					$vars->{'INVALID_RESELLER'} = 1;
				}
			}
		}
		elsif (	$q->param('possible_reseller') =~ /^on$/i or
				$q->param('reseller') == 1 or
				$q->param('reseller_proposal') == 1 )
		{
			# reseller ID should be defined but false
			$vars->{'RESELLER_PROPOSAL'} = 1;
			$reseller_id = 0;
		}
	}

	# get dynamic item ID values; global variables can now be retrieved from the dynamic_item_xref table
	my $dynamic_item_IDs = F::Order::get_dynamic_items();

	# CONSULT THE 'act' PARAM TO DETERMINE WHAT ROUTINE TO GO TO NEXT
	my $action = $q->param('act');
	my $next_page = '';

	if ($action eq 'Confirm Order')
	{
		my $order_href = get_order($dbh,$order_id) or err($q);
		# get PBXtra 5.0 License Upgrades if necessary
		addon_order_init($dbh,$vars,$order_href);
		if ($vars->{'ADDING_USER_LICENSES'} and $order_href->{'netsuite_salesorder_id'} =~ /\d+/)
		{
			# CashSale orders should NEVER be processed a second time
			$vars->{'TICKET_ID'} = $order_href->{'ticket_id'};
			$vars->{'ADDON'} = 1;
		}
		else
		{
			# process confirmed order
			unless ($q->param('terms') eq 'on')
			{
				push (@{$vars->{MSG_ERROR}}, "Terms and conditions must be checked to continue");
			}
			# SAVE THE USER'S IP ADDRESS AS A CONFIRMATION OF THE ACCEPTANCE OF THE TERMS & CONDITIONS
			save_customer_ip($q,$dbh,$order_id,$ENV{'REMOTE_ADDR'},$ENV{'REMOTE_PORT'});

			$vars->{'SHIPPING_REQUIRED'} = $order_href->{'shipping_cost'} ? 1 : 0;
			$vars->{'ORDER_TYPE'} = $order_href->{'order_type'};
			if ($vars->{'ORDER_TYPE'} eq 'addon')
			{
				$vars->{'SERVER_ID'} = $order_href->{'server_id'};
			}
			get_deduction($vars,$order_href,$dbh,$reseller_id,$q,$dynamic_item_IDs);
			$vars->{'TICKET_ID'} = $order_href->{'ticket_id'};
			unless ($vars->{'TICKET_ID'} or $vars->{MSG_ERROR})
			{
				# create a new ticket
				$vars->{'TICKET_ID'} = create_rt_ticket($q,$vars,$dbh,$order_href,$order_id);
				F::Order::update_order_header($dbh,	{
														order_id  => $order_id,
														ticket_id => $vars->{'TICKET_ID'}
													}
				) or (push (@{$vars->{MSG_ERROR}}, "Couldn't update order ID #$order_id"));
			}

			F::Order::extension_interview_init($dbh,$vars,$order_href,$dynamic_item_IDs);

			F::Order::get_final_order_totals($vars,$dbh,$order_href,$valid_reseller,$dynamic_item_IDs) unless $vars->{MSG_ERROR};

			#
			#	send email address to the BlueHornet email tool
			#
			my $netsuite_country   = F::Country::get_netsuite_name_by_country($order_href->{'billing_country'});
			my $regional_group     = F::BlueHornet::get_regional_group($netsuite_country);
			my @group_names        = ($regional_group,'Fonality Customers','PBXtra - Technical Updates');
			my @remove_group_names = ('PBXtra Prospect - Quote');
			# create the BlueHornet contact or modify it if it already exists
			my $subscriber_info = {};
			$subscriber_info->{'email'}         = $order_href->{'admin_email'};
			$subscriber_info->{'firstname'}     = $order_href->{'admin_first_name'};
			$subscriber_info->{'lastname'}      = $order_href->{'admin_last_name'};
			$subscriber_info->{'company'}       = $order_href->{'customer_name'};
			$subscriber_info->{'address'}       = $order_href->{'billing_address1'} . ' ' . $order_href->{'billing_address2'};
			$subscriber_info->{'city'}          = $order_href->{'billing_city'};
			$subscriber_info->{'state'}         = $order_href->{'billing_state'};
			$subscriber_info->{'postal_code'}   = $order_href->{'billing_zip'};
			$subscriber_info->{'country'}       = F::Country::get_country_by_netsuite_name($order_href->{'billing_country'});
			$subscriber_info->{'phone_wk'}      = $order_href->{'admin_phone'};
			$subscriber_info->{'full_name'}     = $order_href->{'admin_first_name'} . ' ' . $order_href->{'admin_last_name'};
			$subscriber_info->{'grp'}           = F::BlueHornet::get_group_ids(\@group_names);
			$subscriber_info->{'grpremove'}     = F::BlueHornet::get_group_ids(\@remove_group_names);
			$subscriber_info->{'subscriber_ip'} = $ENV{'REMOTE_ADDR'};
			$subscriber_info->{'signup_page'}   = 'http://' . $ENV{'HTTP_HOST'} . $ENV{'SCRIPT_URL'};
			$subscriber_info->{'double_opt_in'} = 0; # this will send an opt-in email to the customer or not
												 	# currently it seems broken - either value has the same effect
												 	# I think BlueHornet has forced the issue one way or another
												 	# call their tech support to change
			F::BlueHornet::manage_subscriber($subscriber_info);

			# NOW THAT THE EMAIL HAS BEEN CALCULATED -- ADD AN INVOICE TO THE RT TICKET
			submit_order($q,$vars,$dbh,$order_href,$order_id,$reseller_id,$valid_reseller,$intranet_id,$dynamic_item_IDs) unless $vars->{MSG_ERROR};
			email_order($dbh,$vars,$order_href) unless $vars->{MSG_ERROR};
		}
		if ($vars->{MSG_ERROR})
		{
			# an ERROR occurred -- redisplay the Order Confirmation
			$next_page = 'order_confirm.tt';
			form_repop($q,$vars);
			# prepare some values for the Order Confirmation page
			my $order_href = get_order($dbh,$order_id);
			get_deduction($vars,$order_href,$dbh,$reseller_id,$q,$dynamic_item_IDs);
			order_confirm_init($dbh,$order_href,$vars,$q,$order_id,$reseller_id,$valid_reseller,$dynamic_item_IDs);
		}
		else
		{
			$next_page = 'order_complete.tt';
			$vars->{'PRICE_TOTAL_INT'} = $order_href->{'total'};
			$vars->{'PRICE_TOTAL'} = format_comma(sprintf("%.2f", $order_href->{'total'}));
			$vars->{'PRICE_TOTAL'} .= '0' if($vars->{'PRICE_TOTAL'} =~ /\.\d$/); # add a zero if there is only one digit after the decimal
			$vars->{'ORDER_ID'}    = $order_href->{'ticket_id'};
			# remove the credit card CVV ID number from our local DB
			F::Billing::remove_cvv_info($dbh, $order_href->{'cc_id'});
		}
	}

	elsif ($action eq 'Continue to Step 7')
	{
		my $order_href = get_order($dbh,$order_id) or err($q);
		# update the PAYMENT METHOD
		my $order_href = update_payment($dbh,$q,$vars,$order_id,$dynamic_item_IDs);
		if ($vars->{MSG_ERROR})
		{
			form_repop($q,$vars);
			init_payment_info($dbh,$vars,$order_href,$dynamic_item_IDs);
			$next_page = 'order_paymethod.tt';
		}
		else
		{
			get_deduction($vars,$order_href,$dbh,$reseller_id,$q,$dynamic_item_IDs);
			order_confirm_init($dbh,$order_href,$vars,$q,$order_id,$reseller_id,$valid_reseller,$dynamic_item_IDs);
			F::Order::extension_interview_init($dbh,$vars,$order_href,$dynamic_item_IDs);
			$vars->{'SHIPPING_REQUIRED'} = $order_href->{'shipping_cost'} ? 1 : 0;
			$vars->{'SHIPPING_PRICE'} = $order_href->{'shipping_cost'} if $vars->{'SHIPPING_PRICE'} !~ /\d/;
			$next_page = 'order_confirm.tt';
		}
	}

	elsif ($action eq 'Change Payment Method')
	{
		# the user has requested a change in the Payment Method before confirming the order
		my $order_href = get_order($dbh,$order_id) or err($q);
		init_payment_info($dbh,$vars,$order_href,$dynamic_item_IDs);
		$next_page = 'order_paymethod.tt';
	}

	elsif ($action eq 'Continue to Step 6')
	{
		# update additional services: Professional Installation & Expedite Provisioning
		my $order_href = get_order($dbh,$order_id) or err($q);
		my $shipping_cost = $order_href->{'shipping_cost'};
		get_deduction($vars,$order_href,$dbh,$reseller_id,$q,$dynamic_item_IDs);
		$order_href = update_additional_services($q,$vars,$dbh,$order_id,$reseller_id,$valid_reseller,$dynamic_item_IDs);
		if ($vars->{MSG_ERROR})
		{
			form_repop($q,$vars);
			F::Order::get_pbxtra_shipping($dbh,$q,$vars,$order_href,$reseller_id,"order",$dynamic_item_IDs);
			$vars->{'ORDER_TYPE'} = $order_href->{'order_type'};
			$next_page = 'order_additional.tt';
		}
		else
		{
			init_payment_info($dbh,$vars,$order_href,$dynamic_item_IDs);
			$next_page = 'order_paymethod.tt';
		}
	}

	elsif ($action eq 'Change Additional Services')
	{
		# the user has requested a change in the Additional Services before confirming the order
		# update additional services: Professional Installation & Expedite Provisioning
		$next_page = 'order_additional.tt';
		my $order_href = get_order($dbh,$order_id) or err($q);
		F::Order::get_pbxtra_shipping($dbh,$q,$vars,$order_href,$reseller_id,"order",$dynamic_item_IDs);
		my ($price_total,$qty_phone_ports,$qty_phones) = get_order_subtotals($dbh,$order_href,$dynamic_item_IDs);
		additional_services_init($dbh,$q,$vars,$price_total,$qty_phones,$qty_phone_ports,$order_href,$reseller_id,$dynamic_item_IDs);
	}

	elsif ($action eq 'Continue to Step 5')
	{
		# EXTENSION INTERVIEW SUBMITTED
		my $order_href = get_order($dbh,$order_id) or err($q);
		process_extension_devices($vars,$dbh,$q,$order_id,$order_href,$reseller_id,$dynamic_item_IDs);
		if ($vars->{MSG_ERROR})
		{
			# an error occurred -- redisplay the Extension Interview
			F::Order::extension_interview_init($dbh,$vars,$order_href,$dynamic_item_IDs);
			form_repop($q,$vars);
			$next_page = 'order_interview.tt';
		}
		else
		{
			# MOVE ON TO THE SHIPPING AND ADDITIONAL SERVICES PAGE
			F::Order::get_pbxtra_shipping($dbh,$q,$vars,$order_href,$reseller_id,"order",$dynamic_item_IDs);
			if ($vars->{'SHIPPING_REQUIRED'})
			{
				my ($price_total,$qty_phone_ports,$qty_phones) = get_order_subtotals($dbh,$order_href,$dynamic_item_IDs);
				additional_services_init($dbh,$q,$vars,$price_total,$qty_phones,$qty_phone_ports,$order_href,$reseller_id,$dynamic_item_IDs);
				$next_page = 'order_additional.tt';
			}
			else
			{
				# nothing to ship - move onto the payment method page
				init_payment_info($dbh,$vars,$order_href,$dynamic_item_IDs);
				$next_page = 'order_paymethod.tt';
			}
		}
	}

	elsif ($action eq 'Save Extension Changes')
	{
		# the user has made changes to the EXTENSION LIST before confirming the order
		my $order_href = get_order($dbh,$order_id) or err($q);
		process_extension_devices($vars,$dbh,$q,$order_id,$order_href,$reseller_id,$dynamic_item_IDs);
		if ($vars->{MSG_ERROR})
		{
			# an error occurred -- redisplay the Extension Interview
			F::Order::extension_interview_init($dbh,$vars,$order_href,$dynamic_item_IDs);
			form_repop($q,$vars);
			$next_page = 'order_interview.tt';
		}
		else
		{
			# prepare values for the Order Confirmation page
			$vars->{'SHIPPING_REQUIRED'} = $order_href->{'shipping_cost'} ? 1 : 0;
			get_deduction($vars,$order_href,$dbh,$reseller_id,$q,$dynamic_item_IDs);
			order_confirm_init($dbh,$order_href,$vars,$q,$order_id,$reseller_id,$valid_reseller,$dynamic_item_IDs);
			F::Order::extension_interview_init($dbh,$vars,$order_href,$dynamic_item_IDs);
			$next_page = 'order_confirm.tt';
		}
	}

	elsif ($action eq 'Change Extensions')
	{
		# the user has requested a change in the EXTENSION LIST before confirming the order
		my $order_href = get_order($dbh,$order_id) or err($q);
		F::Order::extension_interview_init($dbh,$vars,$order_href,$dynamic_item_IDs);
		$vars->{'PRE_CONFIRM_CHANGE_EXTENSIONS'} = 1;
		$next_page = 'order_interview.tt';
	}

	elsif ($action eq 'Continue to Step 4')
	{
		# SAVE CHANGES TO THE ORDERED ITEMS
		my $order_href = undef;
		if ($vars->{'ADDON'} and $q->param('product_choice') eq "change_other")
		{
			# this is a request for something we don't yet sell online - create an RT ticket and be done with it
			$order_href = get_order($dbh,$order_id) or err($q);
			addon_other_rt_ticket($dbh,$q,$vars,$order_href);
		}
		else
		{
			$order_href = update_order($q,$vars,$dbh,$valid_reseller,$reseller_id,$order_id,$dynamic_item_IDs);
		}
		if ($vars->{MSG_ERROR})
		{
			# an error occurred -- redisplay the order form
			form_repop($q,$vars);
			if ($vars->{'UNBOUND'})
			{
				$vars->{'RENTAL_PHONES'} = $order_href->{'rental_phones'} ? 1 : 0;	# get customer's option of renting/purchasing or default to rent
			}
			addon_server_info($dbh,$q,$vars,$order_href,$dynamic_item_IDs) if($vars->{'ADDON'});
			$vars->{'ORDER_ITEMS'} = $order_href->{'items'};
			$vars->{'ORDER_TYPE'}  = $order_href->{'order_type'};
			order_form_init($dbh,$q,$vars,$valid_reseller,$reseller_id,$dynamic_item_IDs);
			addon_order_init($dbh,$vars,$order_href);
			get_deduction($vars,$order_href,$dbh,$reseller_id,$q,$dynamic_item_IDs);
			$next_page = 'order_items.tt';
			$vars->{'THIS_IS_AN_ORDER'} = 1;    # this is to distinguish o.cgi's use of order_items.tt from q.cgi
		}
		elsif ($vars->{'ADDON'} and $q->param('product_choice') eq "change_other")
		{
			$next_page = 'order_addon_other_complete.tt';
		}
		else
		{
			# order_items.tt successfully processed
			F::Order::extension_interview_init($dbh,$vars,$order_href,$dynamic_item_IDs);
			if ($vars->{'NUM_OF_EXTENSIONS'})
			{
				# MOVE ON TO THE ORDER INTERVIEW PROCESS
				$next_page = 'order_interview.tt';
			}
			else
			{
				# nothing to get an extension for
				F::Order::get_pbxtra_shipping($dbh,$q,$vars,$order_href,$reseller_id,"order",$dynamic_item_IDs);
				if ($vars->{'SHIPPING_REQUIRED'})
				{
					# move onto the shipping and expediting page
					my ($price_total,$qty_phone_ports,$qty_phones) = get_order_subtotals($dbh,$order_href,$dynamic_item_IDs);
					additional_services_init($dbh,$q,$vars,$price_total,$qty_phones,$qty_phone_ports,$order_href,$reseller_id,$dynamic_item_IDs);
					$next_page = 'order_additional.tt';
				}
				else
				{
					# nothing to ship - move onto the payment method page
					init_payment_info($dbh,$vars,$order_href,$dynamic_item_IDs);
					$next_page = 'order_paymethod.tt';
				}
			}
		}
	}

	elsif ($action eq 'Change Order')
	{
		# the user has requested a change in the ORDERED ITEMS before confirming the order
		$next_page = 'order_items.tt';
		$vars->{'THIS_IS_AN_ORDER'} = 1;	# this is to distinguish o.cgi's use of order_items.tt from q.cgi
		$vars->{'PRE_CONFIRM_MODIFY_ORDER'} = 1;
		# get the list of ordered items for display
		my $order_href = get_order($dbh,$order_id);
		get_deduction($vars,$order_href,$dbh,$reseller_id,$q,$dynamic_item_IDs);
		$vars->{'ORDER_TYPE'}  = $order_href->{'order_type'};
		$vars->{'ORDER_ITEMS'} = $order_href->{'items'};
		if ($vars->{'UNBOUND'})
		{
			$vars->{'RENTAL_PHONES'} = $order_href->{'rental_phones'} ? 1 : 0;	# get customer's option of renting/purchasing or default to rent
		}
		addon_server_info($dbh,$q,$vars,$order_href,$dynamic_item_IDs) if($order_href->{'order_type'} eq 'addon');
		order_form_init($dbh,$q,$vars,$valid_reseller,$reseller_id,$dynamic_item_IDs);
		addon_order_init($dbh,$vars,$order_href);
	}

	elsif ($action eq 'Save Buyer Info Changes')
	{
		# save changes made after customer returned to BUYER ADDRESS AND CONTACT INFO from the Order Confirmation page
		update_customer_info($q,$vars,$dbh,$order_id,$reseller_id);
		my $order_href = get_order($dbh,$order_id) or err($q);
		# can we ship to this address?
		F::Order::get_pbxtra_shipping($dbh,$q,$vars,$order_href,$reseller_id,"order",$dynamic_item_IDs) unless $vars->{MSG_ERROR};
		if ($vars->{MSG_ERROR})
		{
			form_repop($q,$vars);
			$vars->{'ORDER_TYPE'} = $order_href->{'order_type'};
			$next_page = 'order_place.tt';
		}
		else
		{
			if ($vars->{'SHIPPING_REQUIRED'})
			{
				my ($price_total,$qty_phone_ports,$qty_phones) = get_order_subtotals($dbh,$order_href,$dynamic_item_IDs);
				additional_services_init($dbh,$q,$vars,$price_total,$qty_phones,$qty_phone_ports,$order_href,$reseller_id,$dynamic_item_IDs);
				$next_page = 'order_additional.tt';
			}
			else
			{
				# nothing to ship - move onto the Order Confirmation page
				get_deduction($vars,$order_href,$dbh,$reseller_id,$q,$dynamic_item_IDs);
				order_confirm_init($dbh,$order_href,$vars,$q,$order_id,$reseller_id,$valid_reseller,$dynamic_item_IDs);
				F::Order::extension_interview_init($dbh,$vars,$order_href,$dynamic_item_IDs);
				$next_page = 'order_confirm.tt';
			}
		}
	}

	elsif ($action eq 'Continue to Step 3')
	{
		# SAVE ORDER HEADER DETAILS FROM STEP 1
		update_customer_info($q,$vars,$dbh,$order_id,$reseller_id);
		my $order_href = get_order($dbh,$order_id) or err($q);
		$vars->{'ORDER_TYPE'} = $order_href->{'order_type'};
		# can we ship to this address?
		F::Order::get_pbxtra_shipping($dbh,$q,$vars,$order_href,$reseller_id,"order",$dynamic_item_IDs) unless $vars->{MSG_ERROR};
		if ($vars->{MSG_ERROR})
		{
			form_repop($q,$vars);
			$vars->{'ORDER_TYPE'} = $order_href->{'order_type'};
			$next_page = 'order_place.tt';
		}
		else
		{
			if ($vars->{'UNBOUND'})
			{
				$vars->{'RENTAL_PHONES'} = $order_href->{'rental_phones'} ? 1 : 0;	# get customer's option of renting/purchasing or default to rent
				$vars->{'HAVE_UNBOUND_REPROV'} = grep({ $_->{item_id} == $dynamic_item_IDs->{'UNBOUND_REPROVISIONING'} } @{ $order_href->{items} }) ? 1 : 0;
			}
			addon_server_info($dbh,$q,$vars,$order_href,$dynamic_item_IDs) if($vars->{'ADDON'});
			order_form_init($dbh,$q,$vars,$valid_reseller,$reseller_id,$dynamic_item_IDs);
			addon_order_init($dbh,$vars,$order_href);
			my $order_href = get_order($dbh,$order_id) or err($q);
			get_deduction($vars,$order_href,$dbh,$reseller_id,$q,$dynamic_item_IDs);
			$next_page = 'order_items.tt';
			$vars->{'THIS_IS_AN_ORDER'} = 1;	# this is to distinguish o.cgi's use of order_items.tt from q.cgi
		}
	}

	elsif ($action eq 'Change Addresses or Contacts')
	{
		# going back to change customer contact/shipping/billing info before final order confirmation
		$vars = order_start($q,$vars,$dbh,$action,$order_id);
		my $order_href = get_order($dbh,$order_id) or err($q);
		reinit_customer($dbh,$vars,$order_href);
		$vars->{'ORDER_TYPE'} = $order_href->{'order_type'};
		$next_page = 'order_place.tt';
	}

	elsif ($action eq 'Continue to Step 2' or $action eq 'new')
	{
		# Step 1
		# create a new customer or recall an existing one
		$vars = order_start($q,$vars,$dbh,$action,$order_id);
		if ($vars->{MSG_ERROR})
		{
			form_repop($q,$vars);
			$next_page = 'order_get_customer.tt';
			$vars->{'DISPLAY_TYPE'} = 'customer_login' unless ($vars->{'GET_SERVER'});
		}
		elsif ($vars->{'ADDON'})
		{
			# send back to order_get_customer if no server ID has been selected yet
			$next_page = ($vars->{'SID'} ? 'order_place.tt' : 'order_get_customer.tt')
		}
		else
		{
			#$next_page = 'order_get_customer.tt';
			$next_page = 'order_place.tt';
		}
	}

	elsif ($action eq 'get')
	{
		$next_page = 'order_get_customer.tt';
		$vars->{'DISPLAY_TYPE'} = 'customer_login';
	}

	else
	{
		$next_page = 'order_get_customer.tt';
		# if no order id, and no action, we assume this is an add-on. If so, have the customer login.
		$vars->{'DISPLAY_TYPE'} = 'customer_login' unless($order_id);
	}

	# print out the appropriate TT page determined in the segment above
	show_template($q,$vars,$next_page,undef,$tt_object);
	return 1;
}
	


#######################################################################
# order_start: create an empty $vars for new orders
#              populate $vars for recalled orders
#######################################################################
sub order_start
{
	my $q        = shift(@_);
	my $vars     = shift(@_);
	my $dbh      = shift(@_);
	my $action   = shift(@_);
	my $order_id = shift(@_);
	my $customer = {};

	# get order and quote references
	my ($order_href, $proposal_id, $quote_href);

	if($order_id)
	{
		# this means the param oid has been passed.
		$order_href  = get_order($dbh,$order_id) or err($q);
		$proposal_id = $order_href->{'quote_header_id'};
		$quote_href  = get_quote($dbh,$proposal_id);
	}
	else
	{
		# If not, let's see if this customer, just wants an add-on order
		$vars->{'ADDON'} = 1;
	}

	if ($action eq 'Continue to Step 2' or $action eq 'Change Addresses or Contacts')
	{
		# an existing customer placing an addon order
		if ($action eq 'Continue to Step 2')
		{
			$customer = F::Order::get_ordering_customer($dbh,$q->param('username'),$q->param('password'));
			addon_start($q,$vars,$dbh,$customer) if($vars->{'ADDON'});
		}
		else
		{
			# new order - use the customer ID directly
			$customer = F::Order::get_ordering_customer($dbh,'','',$q->param('customer_id'));
			# save this value so the template will know to send the user directly to the Order Confirmation when finished here
			$vars->{'ORDER_CONFIRMATION'} = 1;
		}
		unless (defined $customer)
		{
			push (@{$vars->{MSG_ERROR}}, "Invalid Control Panel Admin login");
		}
		$vars->{'ADDITIONAL_ORDER'} = 1;
		$vars->{'CUSTOMER_ID'}  = $customer->{'customer_id'};
		$vars->{'COMPANY_NAME'} = $customer->{'company_name'};
		# billing address
		$vars->{'BILL_ADD1'}     = $customer->{'billing_address1'};
		$vars->{'OLD_ADD1'}      = $customer->{'billing_address1'};
		$vars->{'BILL_ADD2'}     = $customer->{'billing_address2'};
		$vars->{'OLD_ADD2'}      = $customer->{'billing_address2'};
		$vars->{'BILL_CITY'}     = $customer->{'billing_city'};
		$vars->{'OLD_CITY'}      = $customer->{'billing_city'};
		$vars->{'BILL_STATE'}    = $customer->{'billing_state'};
		$vars->{'BILL_PROVINCE'} = '';
		$vars->{'BILL_COUNTRY'}  = $customer->{'billing_country'};
		$vars->{'BILL_ZIP'}      = $customer->{'billing_zip'};
		$vars->{'OLD_ZIP'}       = $customer->{'billing_zip'};
		unless ($vars->{'BILL_STATE'} =~ /^[A-Z][A-Z]$/)
		{
			$vars->{'BILL_PROVINCE'} = $vars->{'BILL_STATE'};
			$vars->{'BILL_STATE'}    = '';
		}
		# shipping address
		$vars->{'SHIP_COMPANY_NAME'} = $customer->{'ship_company_name'};
		$vars->{'SHIP_ADD1'}     = $customer->{'shipping_address1'};
		$vars->{'OLD_SHIP_ADD1'} = $customer->{'shipping_address1'};
		$vars->{'SHIP_ADD2'}     = $customer->{'shipping_address2'};
		$vars->{'OLD_SHIP_ADD2'} = $customer->{'shipping_address2'};
		$vars->{'SHIP_CITY'}     = $customer->{'shipping_city'};
		$vars->{'OLD_SHIP_CITY'} = $customer->{'shipping_city'};
		$vars->{'SHIP_STATE'}    = $customer->{'shipping_state'};
		$vars->{'SHIP_PROVINCE'} = '';
		$vars->{'SHIP_COUNTRY'}  = $customer->{'shipping_country'};
		$vars->{'SHIP_ZIP'}      = $customer->{'shipping_zip'};
		$vars->{'OLD_SHIP_ZIP'}      = $customer->{'shipping_zip'};
		unless ($vars->{'SHIP_STATE'} =~ /^[A-Z][A-Z]$/)
		{
			$vars->{'SHIP_PROVINCE'} = $vars->{'SHIP_STATE'};
			$vars->{'SHIP_STATE'}    = '';
		}
		# administrator contact info
		$vars->{'ADMIN_FIRST_NAME'}     = $customer->{'admin_first_name'};
		$vars->{'OLD_ADMIN_FIRST_NAME'} = $customer->{'admin_first_name'};
		$vars->{'ADMIN_LAST_NAME'}      = $customer->{'admin_last_name'};
		$vars->{'OLD_ADMIN_LAST_NAME'}  = $customer->{'admin_last_name'};
		$vars->{'ADMIN_EMAIL'}          = $customer->{'admin_email'};
		$vars->{'OLD_ADMIN_EMAIL'}      = $customer->{'admin_email'};
		my $admin_phone                 = $customer->{'admin_phone'};
		$admin_phone =~ s/^(1?)(\d\d\d)(\d\d\d)(\d\d\d\d)/$1($2) $3-$4/;
		$vars->{'ADMIN_PHONE'}     = $admin_phone;
		$vars->{'OLD_ADMIN_PHONE'} = $admin_phone;
	}
	else
	{
		# a new customer
		my ($admin_first_name, $admin_last_name) = $quote_href->{'name'} =~ /^(.*)\s(\S*)$/;
		$vars->{'ADDITIONAL_ORDER'} = 0;
		$vars->{'ADMIN_FIRST_NAME'} = $admin_first_name;
		$vars->{'ADMIN_LAST_NAME'}  = $admin_last_name;
		$vars->{'ADMIN_EMAIL'}      = $quote_href->{'email'};
		$vars->{'ADMIN_PHONE'}      = $quote_href->{'phone'};
		$vars->{'WEBSITE'}          = $quote_href->{'website'};
		$vars->{'INDUSTRY'}         = $quote_href->{'industry'};
		$vars->{'TELECOMMUTERS'}    = $quote_href->{'telecommuters'};
		$vars->{'BRANCH_OFFICES'}   = $quote_href->{'branch_offices'};
		# get shipping info from the quote
		$vars->{'SHIP_CITY'}    = $quote_href->{'shipping_city'};
		$vars->{'SHIP_STATE'}   = $quote_href->{'shipping_state'};
		$vars->{'SHIP_COUNTRY'} = $quote_href->{'shipping_country'};
		$vars->{'SHIP_ZIP'}     = $quote_href->{'shipping_zip'};
		# use the shipping info from the quote as default billing values
		$vars->{'BILL_CITY'}    = $quote_href->{'shipping_city'};
		$vars->{'BILL_STATE'}   = $quote_href->{'shipping_state'};
		$vars->{'BILL_COUNTRY'} = $quote_href->{'shipping_country'};
		$vars->{'BILL_ZIP'}     = $quote_href->{'shipping_zip'};
	}

	# get the customer information saved in the proposal
	$vars->{'WEBSITE'}        = $customer->{'website'}        || $quote_href->{'website'};
	$vars->{'INDUSTRY'}       = $customer->{'industry'}       || $quote_href->{'industry'};
	$vars->{'TELECOMMUTERS'}  = $customer->{'telecommuters'}  || $quote_href->{'telecommuters'};
	$vars->{'BRANCH_OFFICES'} = $customer->{'branch_offices'} || $quote_href->{'branch_offices'};
	$vars->{'RESELLER_PROPOSAL'} = $quote_href->{'reseller'};

	return $vars;
}


#######################################################################
# order_start: create an empty $vars for new orders
#              populate $vars for recalled orders
#######################################################################
sub addon_start
{
	my $q         = shift(@_);
	my $vars      = shift(@_);
	my $dbh       = shift(@_);
	my $customer  = shift(@_);

	my $server_id = '';
	my $get_unbound_server = $q->param('get_unbound_server');
	if ($get_unbound_server)
	{
		# the admin username owns more than one Unbound server and were asked to select one
		$server_id = $q->param('unbound_server_id');
	}
	elsif ($q->param('get_pbxtra_server'))
	{
		# the admin username owns more than one PBXtra server and were asked to select one
		$server_id = $q->param('pbxtra_server_id');
	}
	if ($server_id eq '')
	{
		# use the admin username to get the server ID
		# get the customer details with servers and the admin usernames that belong to them
		my $customer_details = F::Customer::get_customer_info_detailed($dbh,$customer->{'customer_id'});
		my @servers;
		foreach my $server (@{$customer_details->{'server_list'}})
		{
			foreach my $admin (@{$server->{'admin_list'}})
			{
				if ($admin->{'user_id'} eq $customer->{'user_id'})
				{
					next if ($vars->{'UNBOUND'} and ! $server->{'mosted'});
					push @servers, $server->{'server_id'};
				}
			}
		}

		# how many servers does the admin login own?
		if (@servers > 1)
		{
			# more than one server found - return an error and ask customer to choose from the servers
			$vars->{'GET_SERVER'} = 1;
			$vars->{'SERVER_IDS'} = \@servers;
			$vars->{'USERNAME'} = $q->param('username');
			$vars->{'PASSWORD'} = $q->param('password');

			if ($get_unbound_server)
			{
				push (@{$vars->{MSG_ERROR}}, "Please select a server.");
			}
			return $vars;
		}
		elsif (@servers < 1)
		{
			# no servers found
			if ($vars->{'UNBOUND'})
			{
				push (@{$vars->{MSG_ERROR}}, $q->param('username') . " has no UNBOUND servers.");
			}
			else
			{
				push (@{$vars->{MSG_ERROR}}, $q->param('username') . " has no servers.");
			}
			return $vars;
		}
		else
		{
			# only one server found
			$server_id = $servers[0];
		}
	}

	# get the original order ID that this is an add-on for
	my $original_order_id = F::Order::get_original_order($dbh,$server_id);
	unless ($original_order_id)
	{
		push (@{$vars->{MSG_ERROR}}, "We cannot find an order for server # $server_id. Please contact your salesperson or call Fonality to place an add-on order.");
		return $vars;
	}

	# we CANNOT prorate support for multiyear contracts -- let orders with less than a year or no support go thru
	my $has_support = F::Support::get_support_quick($dbh,$server_id);
	if ($has_support && !$vars->{UNBOUND})
	{
		my $prorated_percentage = F::Order::get_prorated_annual_support($has_support->{'expire_date'});
		if (!$prorated_percentage)
		{
			push (@{$vars->{MSG_ERROR}}, "We cannot place an automated addon order for your server's support contract. Please contact Fonality's billing department.");
			return $vars;
		}
	}

	# get the original order's proposal ID
	my $original_order  = F::Order::get_order($dbh,$original_order_id);
	if ($original_order->{'order_type'} eq 'unbound')
	{
		# remember this is an UNBOUND add-on if we do not already know it
		$vars->{'UNBOUND'} = 1;
	}
	# Find some contact details if we do not have them already
	print STDERR "original_order_id: $original_order_id\n";
	$customer->{'admin_email'} ||= $original_order->{'admin_email'};
	$customer->{'admin_first_name'} ||= $original_order->{'admin_first_name'};
	$customer->{'admin_last_name'} ||= $original_order->{'admin_last_name'};
	$customer->{'admin_phone'} ||= $original_order->{'admin_phone'};
	# create a new Add-On Order
	$vars->{'OID'} = F::Order::create_order_header($dbh,$customer->{'customer_id'},$customer->{'admin_email'},$customer->{'reseller_id'},'addon');
	# now add the server ID to the order_header table
	F::Order::update_order_header($dbh,	{
											order_id        => $vars->{'OID'},
											server_id       => $server_id,
											original_order  => $original_order_id,
											quote_header_id => $original_order->{'quote_header_id'}
										});
	$vars->{'SID'} = $server_id;
}


sub addon_server_info
{
	my $dbh        = shift(@_);
	my $q          = shift(@_);
	my $vars       = shift(@_);
	my $order_href = shift(@_);
	my $dynamic_item_IDs = shift(@_);
	$vars->{'ADDON'} = 1;	# force this - this subroutine may be called without having set this

	unless (defined $vars->{'SID'})
	{
		$vars->{'SID'} = $order_href->{'server_id'};
	}

	my $server_info = F::Server::get_server_info($dbh, $vars->{'SID'}) or err($q);
	$vars->{'CURRENT_DID_TOTAL'} = F::Unbound::unbound_map_rows($dbh, $vars->{'SID'});

	# set the feature components to the vars, and assign it its Netsuite IDs
	map { $vars->{'FC_REF'}->{uc($_)} = eval 'F::Order::kUNBOUND_' . uc($_) . '_NETSUITE_ID'; } keys %{$server_info->{'fc_ref'}};

	if ($vars->{'UNBOUND'})
	{
		# find what type of phones (purchase/rental) in the last order with this server_id
		# (this will override anything set previously, as it should since a previous order will limit the type of phones available)
		my $order_href = F::Order::get_last_provisioned_order($dbh, $vars->{'SID'});
		$vars->{'HAVE_UNBOUND_REPROV'} = grep({ $_->{item_id} == $dynamic_item_IDs->{'UNBOUND_REPROVISIONING'} } @{ $order_href->{items} }) ? 1 : 0;
		$vars->{'RENTAL_PHONES'} = $order_href->{'rental_phones'} ? 1 : 0;
	}
}


sub reinit_customer
{
	my $dbh        = shift(@_);
	my $vars       = shift(@_);
	my $order_href = shift(@_);

	my $customer = get_ordering_customer($dbh,'','',$order_href->{'customer_id'});

	# save this value so the template will know to send the user directly to the Order Confirmation when finished here
	$vars->{'ORDER_CONFIRMATION'} = 1;
	$vars->{'ADDITIONAL_ORDER'} = 1;
	$vars->{'CUSTOMER_ID'}       = $customer->{'customer_id'};
	$vars->{'COMPANY_NAME'}      = $customer->{'company_name'};
	$vars->{'WEBSITE'}           = $customer->{'website'};
	$vars->{'INDUSTRY'}          = $customer->{'industry'};
	$vars->{'TELECOMMUTERS'}     = $customer->{'telecommuters'};
	$vars->{'BRANCH_OFFICES'}    = $customer->{'branch_offices'};
	$vars->{'RESELLER_PROPOSAL'} = $customer->{'reseller'};

	# billing address
	$vars->{'BILL_ADD1'}     = $order_href->{'billing_address1'};
	$vars->{'OLD_ADD1'}      = $order_href->{'billing_address1'};
	$vars->{'BILL_ADD2'}     = $order_href->{'billing_address2'};
	$vars->{'OLD_ADD2'}      = $order_href->{'billing_address2'};
	$vars->{'BILL_CITY'}     = $order_href->{'billing_city'};
	$vars->{'OLD_CITY'}      = $order_href->{'billing_city'};
	$vars->{'BILL_STATE'}    = $order_href->{'billing_state'};
	$vars->{'BILL_PROVINCE'} = '';
	$vars->{'BILL_COUNTRY'}  = $order_href->{'billing_country'};
	$vars->{'BILL_ZIP'}      = $order_href->{'billing_zip'};
	$vars->{'OLD_ZIP'}       = $order_href->{'billing_zip'};
	unless ($vars->{'BILL_STATE'} =~ /^[A-Z][A-Z]$/)
	{
		$vars->{'BILL_PROVINCE'} = $vars->{'BILL_STATE'};
		$vars->{'BILL_STATE'}    = '';
	}
	# shipping address
	$vars->{'SHIP_COMPANY_NAME'} = $order_href->{'ship_company_name'};
	$vars->{'SHIP_ADD1'}     = $order_href->{'shipping_address1'};
	$vars->{'OLD_SHIP_ADD1'} = $order_href->{'shipping_address1'};
	$vars->{'SHIP_ADD2'}     = $order_href->{'shipping_address2'};
	$vars->{'OLD_SHIP_ADD2'} = $order_href->{'shipping_address2'};
	$vars->{'SHIP_CITY'}     = $order_href->{'shipping_city'};
	$vars->{'OLD_SHIP_CITY'} = $order_href->{'shipping_city'};
	$vars->{'SHIP_STATE'}    = $order_href->{'shipping_state'};
	$vars->{'SHIP_PROVINCE'} = '';
	$vars->{'SHIP_COUNTRY'}  = $order_href->{'shipping_country'};
	$vars->{'SHIP_ZIP'}      = $order_href->{'shipping_zip'};
	$vars->{'OLD_SHIP_ZIP'}      = $order_href->{'shipping_zip'};
	unless ($vars->{'SHIP_STATE'} =~ /^[A-Z][A-Z]$/)
	{
		$vars->{'SHIP_PROVINCE'} = $vars->{'SHIP_STATE'};
		$vars->{'SHIP_STATE'}    = '';
	}
	# administrator contact info
	$vars->{'ADMIN_FIRST_NAME'}     = $order_href->{'admin_first_name'};
	$vars->{'OLD_ADMIN_FIRST_NAME'} = $order_href->{'admin_first_name'};
	$vars->{'ADMIN_LAST_NAME'}      = $order_href->{'admin_last_name'};
	$vars->{'OLD_ADMIN_LAST_NAME'}  = $order_href->{'admin_last_name'};
	$vars->{'ADMIN_EMAIL'}          = $order_href->{'admin_email'};
	$vars->{'OLD_ADMIN_EMAIL'}      = $order_href->{'admin_email'};
	my $admin_phone                 = $order_href->{'admin_phone'};
	$admin_phone =~ s/^(1?)(\d\d\d)(\d\d\d)(\d\d\d\d)/$1($2) $3-$4/;
	$vars->{'ADMIN_PHONE'}     = $admin_phone;
	$vars->{'OLD_ADMIN_PHONE'} = $admin_phone;

	if ($vars->{'SHIP_ADD1'}     eq $vars->{'BILL_ADD1'}     and
		$vars->{'SHIP_ADD2'}     eq $vars->{'BILL_ADD2'}     and
		$vars->{'SHIP_CITY'}     eq $vars->{'BILL_CITY'}     and
		$vars->{'SHIP_STATE'}    eq $vars->{'BILL_STATE'}    and
		$vars->{'SHIP_PROVINCE'} eq $vars->{'BILL_PROVINCE'} and
		$vars->{'SHIP_COUNTRY'}  eq $vars->{'BILL_COUNTRY'}  and
		$vars->{'SHIP_ZIP'}      eq $vars->{'BILL_ZIP'})
	{
		$vars->{'SHIP_TO_BILLING'} = 1;
	}
}



sub email_order
{
	my $dbh        = shift(@_);
	my $vars       = shift(@_);
	my $order_href = shift(@_);

	$vars->{'ORDER_ID'}    = $order_href->{'order_header_id'};
	$vars->{'ADMIN_EMAIL'} = $order_href->{'admin_email'};

	# make sure email address is not blank and is valid
	my $email = $order_href->{'admin_email'};
	unless (F::Mail::check_email_address($email))
	{
		push (@{$vars->{MSG_ERROR}}, "Invalid email address to send notices to: $email");
		return undef;
	}

	# create the tt_obj (can't use the main one because it has a pre_config and a wrapper)
	# This template will be used to form the content of the email sent to the customer/reseller
	my $template_file = 'order_email_msg.tt';
	my $msg = '';
	my $tt_email_object = Template->new({ RELATIVE => 1, INCLUDE_PATH => "$vars->{TT_DIR}:.", POST_CHOMP => 1, TRIM => 1, PRE_CHOMP => 1 });
	$tt_email_object->process($template_file,$vars,\$msg) or $tt_email_object->error(); 
	# garbage collection
	$tt_email_object = undef;

	# replace with spaces and line breaks
	$msg =~ s/\&\#32\;/ /g;
	$msg =~ s/\&\#13\;/\n/g;

	# always add trailing carriage returns - multipart emails require them
	$msg .= "\n";

	# who to send the email to
	my $to = $order_href->{'admin_email'};

	# the from 
	my $from = 'orders@ticket.fonality.com';
	
	# specify the subject
	my $subject = "[Fonality Ticket #" . $vars->{'TICKET_ID'} . "] " . $vars->{'NAME'};
	if ( $vars->{'UNBOUND'} ) {
		$subject .= "'s UNBOUND Order";
	} else {
		$subject .= "'s PBXtra Order";
	}
	if ($vars->{'ADDON'})
	{
		$subject .= " (addon for server $order_href->{server_id})";
	}
	
	# initiate mail object and specify smtp server and sender
	eval {
		my $sender = new Mail::Sender({ bypass_outlook_bug => 1 });
		$sender->OpenMultipart(
		{
			smtp=> 'localhost',
			to => $to,
			subject => $subject,
			from => $from,
		} );
		$sender->Body(
		{
			ctype => 'text/html',
			msg => $msg,
		} );
		$sender->Attach(
		{
			ctype => 'image/png',
			file  => 'images/fonality_logo_header3.png',
			name     => 'fonality_logo_header3.png',
			encoding => 'base64',
			disposition => "inline; filename=\"fonality_logo_header3.png\";\r\nContent-ID: <fonalitylogo>",
		} );
		$sender->Close();
		$sender = undef;	# garbage collection
	} or err("Email error: $@");
	if (defined $Mail::Sender::Error)
	{
		push (@{$vars->{MSG_ERROR}}, "Unable to send email: $@ $Mail::Sender::Error");
	}
}



#
#	initialize the PAYMENT METHOD if a previous credit card was entered
#	CC info is encrypted internally
#
sub init_payment_info
{
	my $dbh        = shift(@_);
	my $vars       = shift(@_);
	my $order_href = shift(@_);
	my $dynamic_item_IDs = shift(@_);

	$vars->{'PAYMENT_METHOD'} = $order_href->{'payment_method'};
	$vars->{'ORDER_TYPE'}     = $order_href->{'order_type'};

	if ($vars->{'PAYMENT_METHOD'} eq "VISA" or
		$vars->{'PAYMENT_METHOD'} eq "MASTERCARD" or
		$vars->{'PAYMENT_METHOD'} eq "American Express" or
		$vars->{'PAYMENT_METHOD'} eq "Discover Card")
	{
		# get customer's encrypted credit card info from local DB -- this is for modified orders
		my $cc_info = F::Billing::get_cc_info($dbh, $order_href->{'customer_id'}, 1);
		my $cc_number = $cc_info->[0]->{'card_number'};
		$cc_number =~ s/\s//g;
		my $last_numbers = $cc_number;
		$last_numbers =~ s/^.+?(\d{4})$/$1/;
		$cc_number =~ s/\d{4}$//;
		$cc_number =~ s/\d/X/g;
		$vars->{'CC_NUMBER'}       = $cc_number . $last_numbers;
		$vars->{'CC_NAME'}         = $cc_info->[0]->{'first_name'} . ' ' . $cc_info->[0]->{'last_name'};
		$vars->{'CC_CODE'}         = $cc_info->[0]->{'cvv2'};
		$vars->{'CC_EXPIRE_MONTH'} = $cc_info->[0]->{'expiration'};
		$vars->{'CC_EXPIRE_MONTH'} =~ s/\d\d$//;    # remove the year
		$vars->{'CC_EXPIRE_MONTH'} =~ s/^0//;   # remove the year
		$vars->{'CC_EXPIRE_YEAR'}  = $cc_info->[0]->{'expiration'};
		$vars->{'CC_EXPIRE_YEAR'}  =~ s/^\d\d//;    # remove the month
		$vars->{'CC_EXPIRE_YEAR'}  = '20' . $vars->{'CC_EXPIRE_YEAR'};
	}

	# only allow credit cards when the TOTAL is below a certain amount
	if ($order_href->{'total'} < 10000)
	{
		$vars->{'CAN_USE_CREDITCARD'} = 1;
	}
	else
	{
		$vars->{'CAN_USE_CREDITCARD'} = 0;
	}

	# if the TOTAL is below a certain amount -- allow customers to pay for their server in 60 days
	my $real_total = 0;
	foreach my $item (@{$order_href->{'items'}})
	{
		next if ($item->{'item_id'} eq $dynamic_item_IDs->{'PROMO_60_DAYS'});	# don't bother to count the 60-day payment promo if there is one
		my $item_price = $item->{'item_price'};
		$item_price =~ s/,//g;
		$real_total += ($item_price * $item->{'quantity'});
	}
	$real_total += $order_href->{'shipping_cost'} + $order_href->{'sales_tax'};
	if ($real_total < 15000)
	{
		$vars->{'PROMO_60_DAY_NETSUITE_ID'} = $dynamic_item_IDs->{'PROMO_60_DAYS'};
		$vars->{'PROMO_60_DAY_PAYMENT'}     = 1;
		$vars->{'ORDER_ITEMS'}              = $order_href->{'items'};
	}
	else
	{
		$vars->{'PROMO_60_DAY_PAYMENT'} = 0;
	}

	addon_order_init($dbh,$vars,$order_href);

	# check for PBXtra 5.0 User License upgrades
	if ($vars->{'ADDING_USER_LICENSES'})
	{
		# PBXtra 5.0 User License addons or upgrades MUST be paid by credit card
		$vars->{'CASH_SALE'}             = 1;
		$vars->{'CREDITCARD_ONLY'}       = 1;
		$vars->{'CAN_USE_CREDITCARD'}    = 1;
		$vars->{'PROMO_60_DAY_PAYMENT'}  = 0;
		$vars->{'ADDON_LICENSE_UPGRADE'} = 1;
		$vars->{'ORDER_APPROVED'}        = 1;
	}
	else
	{
		$vars->{'CASH_SALE'}      = 0;
		$vars->{'ORDER_APPROVED'} = 0;
	}
}


#
#	update the PAYMENT METHOD info
#
sub update_payment
{
	my $dbh      = shift(@_);
	my $q        = shift(@_);
	my $vars     = shift(@_);
	my $order_id = shift(@_);
	my $dynamic_item_IDs = shift(@_);

	my $order_href = get_order($dbh,$order_id) or err($q);

	#
	#	get input parameters from the input form
	#
	# get the PAYMENT METHOD
	my $payment_method = $q->param('payment_method');
	$order_href->{'payment_method'} = $payment_method;
	# credit card SECURITY CODE
	my $cc_code = $q->param('cc_code');
	# credit card NUMBER
	my $cc_number = $q->param('cc_number');
	if ($cc_number =~ /^X+/ and $cc_number eq $q->param('cc_number_old'))
	{
		# user didn't change the card number - get value from DB
		my $cc_info = F::Billing::get_cc_info($dbh, $order_href->{'customer_id'}, 1);
		if ($cc_info->[0]->{'card_number'})
		{
			$cc_number = $cc_info->[0]->{'card_number'};
		}
	}
	$cc_number =~ s/\D//g;  # remove anything that isn't a digit from the credit card number
	# credit card EXPIRATION DATE
	my $cc_expire_month = $q->param('cc_expire_month');
	my $cc_expire_year  = $q->param('cc_expire_year');
	#validate the expire date
	my ($current_year,$current_month0,$current_day0) = get_current_date();
	$current_month0 =~ s/^0//;
	if ( ($payment_method eq "VISA" or $payment_method eq "MASTERCARD" or $payment_method eq "American Express" or $payment_method eq "Discover")
	and $current_year == $cc_expire_year and $cc_expire_month < $current_month0)
	{
		push (@{$vars->{MSG_ERROR}}, "Your credit card has expired.");
	}
	$cc_expire_year  =~ s/^20//;        # year should be last TWO NUMBERS
	$cc_expire_month =~ s/^(\d)$/0$1/;  # month should always be TWO NUMBERS
	my $cc_expire_date = $cc_expire_month . $cc_expire_year;
	# split the NAME into first and last
	my ($first_name, $last_name) = ('', '');
	my $full_name = $q->param('cc_name');
	$full_name =~ s/^\s+|\s+$//g;
	if ($full_name =~ /\S\s+\S/o)
	{
		($first_name, $last_name) = $full_name =~ /^(.*)\s(\S*)$/o;
	}
	else
	{
		($first_name, $last_name) = ($full_name, '');
	}

	# CREDIT CARD data validation
	unless ($payment_method =~ /\w/) {
		push (@{$vars->{MSG_ERROR}}, "Payment Method is required.");
	}
	if ($payment_method eq 'VISA' or $payment_method eq 'MASTERCARD' or $payment_method eq 'American Express' or $payment_method eq 'Discover') {
		unless ($cc_number =~ /\d/) {
			push (@{$vars->{MSG_ERROR}}, "Credit Card Number is required.");
		}
		else
		{
			if (!Business::CreditCard::validate($cc_number)) {
				push (@{$vars->{MSG_ERROR}}, "Credit Card Number is invalid.");
			}
			elsif ($payment_method eq 'VISA' and Business::CreditCard::cardtype($cc_number) ne 'VISA card') {
				push (@{$vars->{MSG_ERROR}}, "Credit Card Number is not a VISA card.");
			}
			elsif ($payment_method eq 'MASTERCARD' and Business::CreditCard::cardtype($cc_number) ne 'MasterCard') {
				push (@{$vars->{MSG_ERROR}}, "Credit Card Number is not a MasterCard.");
			}
			elsif ($payment_method eq 'American Express' and Business::CreditCard::cardtype($cc_number) ne 'American Express card') {
				push (@{$vars->{MSG_ERROR}}, "Credit Card Number is not an American Express card.");
			}
			elsif ($payment_method eq 'Discover' and Business::CreditCard::cardtype($cc_number) ne 'Discover card') {
				push (@{$vars->{MSG_ERROR}}, "Credit Card Number is not a Discover Card.");
			}
		}
		unless ($first_name =~ /\w/) {
			push (@{$vars->{MSG_ERROR}}, "Name on Credit Card is required.");
		}
		unless ($cc_expire_date =~ /\d{4}/) {
			push (@{$vars->{MSG_ERROR}}, "Credit Card Expiration date required.");
		}
		unless ($cc_code =~ /\d+/) {
			push (@{$vars->{MSG_ERROR}}, "The security code on the back of the Credit Card is required.");
		}
	}

	my $cc_id = '';
	if ($payment_method eq "VISA" or $payment_method eq "MASTERCARD" or $payment_method eq "American Express" or $payment_method eq "Discover")
	{
		$cc_id = F::Billing::set_cc_info($dbh, $order_href->{'customer_id'},	{
																					card_number => $cc_number,
																					first_name  => $first_name,
																					last_name   => $last_name,
																					address     => $order_href->{'billing_address1'},
																					city        => $order_href->{'billing_city'},
																					state       => $order_href->{'billing_state'},
																					zip         => $order_href->{'billing_zip'},
																					expiration  => $cc_expire_date,
																					cvv2        => $cc_code,
																					cc_type     => $payment_method
																				}
		);
	}


	#
	#	did the customer ask to pay for this order in 60 days?
	#
	my $promo_60daypay = 0;
	# get the 60-day promo NetSuite item
	my $promo_60daypay_item = F::Order::get_item($dbh,$dynamic_item_IDs->{'PROMO_60_DAYS'});
	# remove any previously existing 60-day promos so we don't duplicate it - and so it is gone if updating and the customer no longer wants it
	foreach my $order_item (@{$order_href->{'items'}})
	{
		if ($order_item->{'item_id'} eq $promo_60daypay_item->{'item_id'})
		{
			F::Order::remove_item_from_order($dbh,$order_href->{'order_header_id'},$order_item->{'order_trans_id'}) or err($q);
			last;
		}
	}
	if ($q->param("promo_60daypay") =~ /on/i)
	{
		$promo_60daypay = 1;
		# get the total
		my $price_total = 0;
		foreach my $order_item (@{$order_href->{'items'}})
		{
			next if($order_item->{'item_id'} eq $promo_60daypay_item->{'item_id'});
			$price_total += ($order_item->{'item_price'} * $order_item->{'quantity'});
		}
		$price_total += $order_href->{'sales_tax'};
		$price_total += $order_href->{'shipping_cost'};
		# calculate the price of the 60-day payment promo -- 5% of the total
		my $promo_60daypay_price = $price_total * 0.05;
		# add the NetSuite item for the promo
		F::Order::add_item_to_order($dbh,$order_href->{'order_header_id'},$promo_60daypay_item->{'item_id'},1,$promo_60daypay_price) or err($q);
	}
	# END 60-day payment promo


	#
	#	save the payment method to the order_header table
	#
	F::Order::update_order_header($dbh, {
											order_id       => $order_href->{'order_header_id'},
											payment_method => $payment_method,
											promo_60daypay => $promo_60daypay,
											cc_id          => $cc_id
							    		}) or err($q);

	# reloaded the order
	$order_href = F::Order::get_order($dbh,$order_href->{'order_header_id'}) or err($q);
	$vars->{'ORDER_ITEMS'} = $order_href->{'items'};
	return $order_href;
}



#############################################################################
# update_customer_info
# - Update the order header table with:
# company 
# billing address
# shipping address
# payment method
#############################################################################
sub update_customer_info 
{
	my $q              = shift(@_);
	my $vars           = shift(@_);
	my $dbh            = shift(@_);
	my $order_id       = shift(@_);
	my $reseller_id    = shift(@_);

	my $additional_order = $q->param('additional_order') || $vars->{'ADDON'};
	my $company_name = $q->param('company_name');
	# set the global customer ID if it exists - it won't in the first step, even if it's an order for an existing customer
	my $customer_id = $q->param('customer_id') or undef;

	# billing address
	my $bill_add1     = $q->param('bill_add1');
	$bill_add1       =~ s/^\s+|\s+$//g;
	my $bill_add2     = $q->param('bill_add2');
	$bill_add2       =~ s/^\s+|\s+$//g;
	my $bill_city     = $q->param('bill_city');
	$bill_city       =~ s/^\s+|\s+$//g;
	my $bill_state    = $q->param('bill_state');
	$bill_state      =~ s/^\s+|\s+$//g;
	my $bill_province = $q->param('bill_province');
	$bill_province   =~ s/^\s+|\s+$//g;
	my $bill_country  = $q->param('bill_country');
	$bill_country    =~ s/^\s+|\s+$//g;
	my $bill_zip      = $q->param('bill_zip');
	$bill_zip        =~ s/^\s+|\s+$//g;
	unless ($bill_country eq 'United States')
	{
		$bill_state = $bill_province;
	}
	my $old_add1    = $q->param('old_add1');
	my $old_add2    = $q->param('old_add2');
	my $old_city    = $q->param('old_city');
	my $old_zip     = $q->param('old_zip');

	# shipping address
	my ($ship_company_name, $ship_add1, $ship_add2, $ship_city, $ship_state, $ship_country, $ship_zip) = ('', '', '', '', '', '');
	my $ship_to_billing = $q->param('ship_to_billing');
	if ($ship_to_billing =~ /on/i)
	{
		$ship_company_name = $company_name;
		$ship_add1    = $bill_add1;
		$ship_add2    = $bill_add2;
		$ship_city    = $bill_city;
		$ship_state   = $bill_state;
		$ship_country = $bill_country;
		$ship_zip     = $bill_zip;
	}
	else
	{
		# customer wants us to ship to a different address
		$ship_company_name = $q->param('ship_company_name');
		$ship_company_name =~ s/^\s+|\s+$//g;
		$ship_add1         = $q->param('ship_add1');
		$ship_add1        =~ s/^\s+|\s+$//g;
		$ship_add2         = $q->param('ship_add2');
		$ship_add2        =~ s/^\s+|\s+$//g;
		$ship_city         = $q->param('ship_city');
		$ship_city        =~ s/^\s+|\s+$//g;
		$ship_state        = $q->param('ship_state');
		$ship_state       =~ s/^\s+|\s+$//g;
		$ship_country      = $q->param('ship_country');
		$ship_country     =~ s/^\s+|\s+$//g;
		$ship_zip          = $q->param('ship_zip');
		$ship_zip         =~ s/^\s+|\s+$//g;
		my $ship_province  = $q->param('ship_province');
		$ship_province    =~ s/^\s+|\s+$//g;
		unless ($ship_country eq 'United States')
		{
			$ship_state = $ship_province;
		}
	}
	my $old_ship_company_name = $q->param('old_ship_company_name');
	$old_ship_company_name    =~ s/^\s+|\s+$//g;
	my $old_ship_add1    = $q->param('old_ship_add1');
	$old_ship_add1      =~ s/^\s+|\s+$//g;
	my $old_ship_add2    = $q->param('old_ship_add2');
	$old_ship_add2      =~ s/^\s+|\s+$//g;
	my $old_ship_city    = $q->param('old_ship_city');
	$old_ship_city      =~ s/^\s+|\s+$//g;
	my $old_ship_zip     = $q->param('old_ship_zip');
	$old_ship_zip       =~ s/^\s+|\s+$//g;

	# admin contact info
	my $admin_first_name  = $q->param('admin_first_name');
	$admin_first_name    =~ s/^\s+|\s+$//g;
	my $admin_last_name   = $q->param('admin_last_name');
	$admin_last_name     =~ s/^\s+|\s+$//g;
	my $admin_email       = $q->param('admin_email');
	$admin_email         =~ s/^\s+|\s+$//g;
	my $admin_phone       = $q->param('admin_phone');
	$admin_phone         =~ s/^\s+|\s+$//g;
	my $old_admin_first_name = $q->param('old_admin_first_name');
	my $old_admin_last_name  = $q->param('old_admin_last_name');
	my $old_admin_email      = $q->param('old_admin_email');
	my $old_admin_phone      = $q->param('old_admin_phone');

	my $website        = $q->param('website');
	my $industry       = $q->param('industry');
	my $telecommuters  = $q->param('telecommuters');
	my $branch_offices = $q->param('branch_offices');

	# input verification
	unless ($company_name =~ /\w/) {
		push (@{$vars->{MSG_ERROR}}, "Company Name is required.");
	}
	if ($company_name =~ /\&/) {
		push (@{$vars->{MSG_ERROR}}, "Company Name cannot contain the character '&'.");
		$company_name =~ s/\&/and/g;
		$q->param('company_name', $company_name);
	}
	unless ($ship_company_name =~ /\w/) {
		push (@{$vars->{MSG_ERROR}}, "Shipping Address Company Name is required.");
	}
	if ($ship_company_name =~ /\&/) {
		push (@{$vars->{MSG_ERROR}}, "Shipping Company Name cannot contain the character '&'.");
		$ship_company_name =~ s/\&/and/g;
		$q->param('ship_company_name', $ship_company_name);
	}
	unless ($admin_phone =~ /\w/) {
		push (@{$vars->{MSG_ERROR}}, "Administrator Phone Number is required.");
	}
	unless ($admin_email =~ /\w/) {
		push (@{$vars->{MSG_ERROR}}, "Administrator Email Address is required.");
	}
	unless (F::Mail::check_email_address($admin_email)) {
		push (@{$vars->{MSG_ERROR}}, "Email Address is invalid.");
	}
	unless ($admin_first_name =~ /\w/) {
		push (@{$vars->{MSG_ERROR}}, "Administrator First Name is required.");
	}
	unless ($admin_last_name =~ /\w/) {
		push (@{$vars->{MSG_ERROR}}, "Administrator Last Name is required.");
	}
	unless ($bill_add1 =~ /\w/) {
		push (@{$vars->{MSG_ERROR}}, "Billing Address is required.");
	}
	unless ($bill_city =~ /\w/) {
		push (@{$vars->{MSG_ERROR}}, "Billing City is required.");
	}
	unless ($bill_state =~ /\w/) {
		push (@{$vars->{MSG_ERROR}}, "Billing State/Province is required.");
	}
	unless ($bill_country =~ /\w/) {
		push (@{$vars->{MSG_ERROR}}, "Billing Country is required.");
	}
	unless ($bill_zip =~ /\w/) {
		push (@{$vars->{MSG_ERROR}}, "Billing Zip/Postal Code is required.");
	}
	unless ($ship_add1 =~ /\w/) {
		push (@{$vars->{MSG_ERROR}}, "Shipping Address is required.");
	}
	unless ($ship_city =~ /\w/) {
		push (@{$vars->{MSG_ERROR}}, "Shipping City is required."); 
	}
	unless ($ship_country =~ /\w/) {
		push (@{$vars->{MSG_ERROR}}, "Shipping Country is required.");
	}
	unless ($ship_state =~ /\w/) {
		push (@{$vars->{MSG_ERROR}}, "Shipping State/Province is required.");
	}
	unless ($ship_zip =~ /\w/) {
		push (@{$vars->{MSG_ERROR}}, "Shipping Zip/Postal Code is required.");
	}

	if ($vars->{'MSG_ERROR'})
	{
		return undef;
	}

	if ($additional_order == 0)
	{
		# make sure the user hasn't returned here after already creating a new customer once
		my $order_href = F::Order::get_order($dbh,$order_id);
		if ($customer_id || $order_href->{'customer_id'} =~ /\d/)
		{
			# user has returned to this page or reloaded after creating a new customer
			$customer_id = $customer_id || $order_href->{'customer_id'};
		}
		else
		{
			#
			#	create a NEW Customer
			#
			my $customer_data = {name => $company_name};
			my $customers_reseller_id = $reseller_id;
			unless ($customers_reseller_id)
			{
				# a reseller isn't logged in - try to get a reseller from the order header, it'll have been transferred from the quote
				$customers_reseller_id = $order_href->{'reseller_id'};
				if ($customers_reseller_id)
				{
					# a reseller was found - but we need to get the reseller name
					my $reseller_href = F::Resellers::get_reseller($dbh,$customers_reseller_id,'reseller_id') or err($q);
					$vars->{'RESELLER_NAME'} = $reseller_href->{'company'};
				}
			}
			if ($customers_reseller_id)
			{
				# a reseller ID was detected
				$customer_data->{'reseller_id'} = $customers_reseller_id;
				$customer_data->{'name'}        = "$company_name (" . $vars->{'RESELLER_NAME'} . ")";
			}
			# set the Order Date to today
			my ($current_year,$current_month0,$current_day0) = get_current_date();
			$customer_data->{'order_date'} = "$current_year-$current_month0-$current_day0";
			# create a NEW CUSTOMER
			$customer_id = F::Customer::add_customer($dbh,$customer_data);
		}
	}
	else
	{
		# this is an add-on order for an existing customer
		# the customer ID will have been passed by the previous step from template order_get_customer.tt
	}

	# update the existing_order_header with the Shipping Address and Customer ID
	F::Order::update_order_header($dbh,	{ 
									order_id          => $order_id,
									customer_id       => $customer_id,
									billing_address1  => $bill_add1,
									billing_address2  => $bill_add2,
									billing_city      => $bill_city,
									billing_state     => $bill_state,
									billing_country   => $bill_country,
									billing_zip       => $bill_zip,
									ship_company_name => $ship_company_name,
									shipping_address1 => $ship_add1,
									shipping_address2 => $ship_add2,
									shipping_city     => $ship_city,
									shipping_state    => $ship_state,
									shipping_country  => $ship_country,
									shipping_zip      => $ship_zip,
									admin_phone       => $admin_phone,
									admin_email       => $admin_email,
									admin_first_name  => $admin_first_name,
									admin_last_name   => $admin_last_name
								}
	) or err($q);


	if ($vars->{'MSG_ERROR'})
	{
		return undef;
	}


	# update the customer info
	F::Customer::update_customer($dbh, $customer_id, 	{
															'website'        => $website,
															'industry'       => $industry,
															'telecommuters'  => $telecommuters,
															'branch_offices' => $branch_offices
														}
	);

	# remove all non-digits - the data type for these values are bigint
	foreach ($admin_phone, $old_admin_phone) #, $tech_phone, $old_tech_phone)
	{
		s/\D//g;
	}


	#	save CUSTOMER ADDRESS info
	#	do this IF this is a new order/customer or if info changed
	if ($additional_order == 0 or ($bill_add1    ne $old_add1)
							   or ($bill_add2    ne $old_add2)
							   or ($bill_city    ne $old_city)
							   or ($bill_zip     ne $old_zip))
	{
		F::Address::add($dbh,	{
									'customer_id' => $customer_id,
									'line1'       => $bill_add1,
									'line2'       => $bill_add2,
									'city'        => $bill_city,
									'state_prov'  => $bill_state,
									'zip'         => $bill_zip,
									'country'     => $bill_country
								}
		);
	}

	# don't add the shipping address if it's the same as the billing address
	unless ($ship_to_billing =~ /on/i)
	{
		#	save SHIPPING ADDRESS
		#	do this IF this is a new order/customer or if info changed
		if ($additional_order == 0  or ($ship_add1         ne $old_ship_add1)
									or ($ship_add2         ne $old_ship_add2)
									or ($ship_city         ne $old_ship_city)
									or ($ship_zip          ne $old_ship_zip)	)
		{
			F::Address::add($dbh,   {
										'customer_id'   => $customer_id,
										'shipping_only' => 1,
										'company_name'  => $ship_company_name,
										'line1'         => $ship_add1,
										'line2'         => $ship_add2,
										'city'          => $ship_city,
										'state_prov'    => $ship_state,
										'zip'           => $ship_zip,
										'country'       => $ship_country
									}
			);
		}
	}

	#	save ADMIN CONTACT info
	#	do this IF this is a new order/customer or if info changed
	if ($additional_order == 0 or ($admin_first_name ne $old_admin_first_name)
							   or ($admin_last_name  ne $old_admin_last_name)
							   or ($admin_email      ne $old_admin_email)
							   or ($admin_phone      ne $old_admin_phone) )
	{
		F::Contact::add($dbh,	{
									'customer_id'          => $customer_id,
									'want_tech_updates'    => 1,
									'want_general_updates' => 1,
									'first_name'           => $admin_first_name,
									'last_name'            => $admin_last_name,
									'email1'               => $admin_email,
									'phone1'               => $admin_phone
								}
		);
	}

	# get the list of ordered items for display in the next step
	my $order_href = get_order($dbh,$order_id);
	$vars->{'ORDER_ITEMS'} = $order_href->{'items'};
	return 1;
}



#############################################################################
# Update the order_trans table to add Expedited Provisioning & Professional Installation
#############################################################################
sub update_additional_services 
{
	my $q                = shift(@_);
	my $vars             = shift(@_);
	my $dbh              = shift(@_);
	my $order_id         = shift(@_);
	my $reseller_id      = shift(@_);
	my $valid_reseller   = shift(@_);
	my $dynamic_item_IDs = shift(@_);

	# get the expedited fee
	my $expedite_id  = $dynamic_item_IDs->{'EXPEDITED_PROVISIONING'};
	my $expedite_fee = $q->param('expedite_fee');

	# get the install fee
	my $qty_phones      = $q->param('qty_phones');
	my $qty_phone_ports = $q->param('qty_phone_ports');

	# load the order from the db
	my $order_href  = F::Order::get_order($dbh,$order_id) or err($q);

	#
	#	EXPEDITE PROVISIONING
	#
	# remove any previously existing Expedited Provisioning fee
	foreach my $order_item (@{$order_href->{'items'}})
	{
		# search all items in the order - if there's another expedite fee, save the fee and remove it
		if ($order_item->{'item_id'} == $expedite_id)
		{
			# remove the old fee
			F::Order::remove_item_from_order($dbh,$order_id,$order_item->{'order_trans_id'}) or err($q);
			last;
		}
	}
	# update Expedite Fee if necessary
	if ($q->param('expedite') =~ /on/i)
	{
		# add the expedite fee to the order_trans table
		F::Order::add_item_to_order($dbh,$order_id,$expedite_id,1,$expedite_fee) or err($q); 
	}

	# UPDATE THE SHIPPING OPTION
	my $estimated_box_weights = $q->param('estimated_box_weights');
	my ($shipping_service,$shipping_price) = split(/:/, $q->param('shipping_service_price'));
	$shipping_service =~ s/^UPS_//;
	F::Order::update_order_header($dbh, {
											shipping_weight_estimated => $estimated_box_weights,
											shipping_service          => $shipping_service,
											shipping_cost             => $shipping_price,
											order_id                  => $order_id
							  			}
	) or err($q) if $q->param('vieworder') ne '1'; # don't update the order if we are just viewing it

	# get a new order_href and send it back
	$order_href = F::Order::get_order($dbh,$order_id) or err($q);
	return $order_href;
}


################################################################################################
# order_confirm_init: prepare these values for the order confirmation. This is used after adding
# 					  Additional Services and when repopulating the form in case of ERROR
################################################################################################
sub order_confirm_init
{
	my $dbh              = shift(@_);
	my $order_href       = shift(@_);
	my $vars             = shift(@_);
	my $q                = shift(@_);
	my $order_id         = shift(@_);
	my $reseller_id      = shift(@_);
	my $valid_reseller   = shift(@_);
	my $dynamic_item_IDs = shift(@_);

	# add additional info per order item
	foreach my $order_item (@{$order_href->{'items'}})
	{
		unless ($order_item->{'group_name'} =~ /\w/ or $order_item->{'netsuite_id'} =~ /\d/)
		{
			# get group_name, etc. for each selected item
			my $item_ref = F::Order::get_reseller_item($dbh,$order_item->{'item_id'},$reseller_id) or err($q);
			$order_item->{'name'}         = $item_ref->{'name'};
			$order_item->{'weight'}       = $item_ref->{'weight'};
			$order_item->{'mnemonic'}     = $item_ref->{'mnemonic'};
			$order_item->{'group_name'}   = $item_ref->{'group_name'};
			$order_item->{'netsuite_id'}  = $item_ref->{'netsuite_id'};
			$order_item->{'retail_price'} = $item_ref->{'price'};
		}
	}

	# does this quote have a Live Back-up Server?
	# If it does we'll double the quantities of server upgrades & defaults
	# and add an asterisk on the proposal to explain the double quantities
	my ($backup_server_selected,$backup_server_ref) = F::Order::is_live_backup_server_selected($order_href->{'items'});
	F::Order::update_live_backup_server_item_quantities($order_href->{'items'},$dynamic_item_IDs) if($backup_server_selected);

	# track if CCE or HUD Agent are in the order for a possible discount
	my $cce_order       = 0;
	my $hud_agent_order = 0;
	my $total_phones    = 0;

	# this is so we can find the number of Phone Ports
	my %item_hash = ();

	# reset the total because we'll add the price of server upgrades/defaults if a LIVE BACK-UP SERVER was selected
	$order_href->{'total'} = 0;

	# If we're upgrading editions, find editions that we do NOT want to show the customer for MRC
	if ($vars->{'ADDON'} and $vars->{'UNBOUND'})
	{
		# Find if they're upgrading editions (more than 1 edition will show up in the items, one downgrade, one upgrade)
		my @editions = sort { $a <=> $b } map { $_->{'item_id'} } grep {
			$_->{'item_id'} == $dynamic_item_IDs->{'UNBOUND_SOFTWARE_STANDARD'}   ||
			$_->{'item_id'} == $dynamic_item_IDs->{'UNBOUND_SOFTWARE_PRO'}        ||
			$_->{'item_id'} == $dynamic_item_IDs->{'UNBOUND_SOFTWARE_CALLCENTER'} ||
			$_->{'item_id'} == $dynamic_item_IDs->{'UNBOUND_SOFTWARE_OLD_CCE'}
		} @{ $order_href->{'items'} };
		if (@editions > 1)
		{
			# We're abusing the fact that currently edition netsuite ids are in sorted order (se/pe/cce)
			# If this changes, so will this section of code.
			$vars->{'AVOID_MRC'} = [ @editions ];
			pop @{ $vars->{'AVOID_MRC'} };
		}
	}

	$vars->{'PRORATED_SUPPORT'} = 0;	# this might be set in the next loop
	foreach my $order_item (@{$order_href->{'items'}})
	{
		if ($order_item->{'group_name'} eq '' or $order_item->{'netsuite_id'} eq '')
		{
			my $item_ref = F::Order::get_reseller_item($dbh,$order_item->{'item_id'},$reseller_id) or err($q);
			$order_item->{'name'}         = $item_ref->{'name'};
			$order_item->{'weight'}       = $item_ref->{'weight'};
			$order_item->{'mnemonic'}     = $item_ref->{'mnemonic'};
			$order_item->{'group_name'}   = $item_ref->{'group_name'};
			$order_item->{'netsuite_id'}  = $item_ref->{'netsuite_id'};
			$order_item->{'retail_price'} = $item_ref->{'price'};
		}

		my $subtotal = $order_item->{'item_price'} * $order_item->{'quantity'};
		$order_item->{'subtotal'}   = format_comma(sprintf("%.2f", $subtotal));
		$order_item->{'item_price'} = format_comma(sprintf("%.2f", $order_item->{'item_price'}));
		$vars->{'PROVISIONING_PRICE'} = $order_item->{'item_price'} if($order_item->{'item_id'} eq $dynamic_item_IDs->{'EXPEDITED_PROVISIONING'});

		# if support is prorated this is an addon and should be noted on the confirm page
		if ($order_item->{'prorate_memo'} =~ /\w/)
		{
			$order_item->{'name'} .= ' *';
			$vars->{'PRORATED_SUPPORT'} = 1;
			$vars->{'PRORATED_TEXT'} = $order_item->{'prorate_memo'};
		}

		# re-tally the total
		$order_href->{'total'} += $subtotal;
	}

	# ADD SHIPPING SERVICE TO THE ORDER CONFIRMATION
	my $shipping_service = $order_href->{'shipping_service'};
	my @shipping_service = split(/_/, $shipping_service);
	$shipping_service = 'UPS';
	foreach my $word (@shipping_service)
	{
		$word = lc($word);
		$word = ucfirst($word);
		$word = 'AM' if($word eq 'Am');
		$shipping_service .= ' ' . $word;
	}
	$vars->{'SHIPPING_SERVICE'} = $shipping_service;
	$vars->{'SHIPPING_PRICE'} = format_comma(sprintf("%.2f", $order_href->{'shipping_cost'}));
	$order_href->{'total'} += $order_href->{'shipping_cost'};

	# save the SUB-TOTAL and format the total
	my $sub_total   = $order_href->{'total'};
	my $price_total = sprintf("%.2f", $order_href->{'total'});

	# save the array of hashes that holds all the ordered items
	$vars->{'ORDER_ITEMS'} = $order_href->{'items'};
	$vars->{'PRORATED'} = grep { $_->{'prorated'} } @{ $vars->{'ORDER_ITEMS'} };

	# save the name of the Additional Services
	my $provisioning = F::Order::get_reseller_item($dbh,$dynamic_item_IDs->{'EXPEDITED_PROVISIONING'},$reseller_id) or err($q);
	$vars->{'PROVISIONING_NAME'} = $provisioning->{'name'};

	#
	#	a deduction from the Sales Director
	#
	if ($vars->{'DEDUCTION_EXISTS'})
	{
		$vars->{'PRICE_TOTAL'} = $price_total - $vars->{'DEDUCTION_VALUE'};
		$order_href->{'total'} -= $vars->{'DEDUCTION_VALUE'};
	}
	else
	{
		$vars->{'PRICE_TOTAL'} = $price_total;
	}

	#
	#	Promo Code
	#
	if ($vars->{'PROMO_CODE'})
	{
		my $promo_discount = $vars->{'PROMO_CODE_DISCOUNT'};
		$promo_discount =~ s/,//g;   # remove commas from the discount before subtraction
		$vars->{'PRICE_TOTAL'} -= $promo_discount;
		$order_href->{'total'} -= $promo_discount;
	}

	# format the final sales tax
	my $total_tax = 0;
	my $floating_sales_tax_percentage = F::Order::get_sales_tax($order_href->{'shipping_state'},$order_href->{'shipping_zip'});
	if ($floating_sales_tax_percentage and !$valid_reseller)
	{
		$total_tax = F::Order::get_pbxtra_taxable_amt($vars,$order_href) * $floating_sales_tax_percentage;
		$total_tax = sprintf("%.2f", $total_tax);	# round to the nearest penny
		$price_total += $total_tax;
		$vars->{'PRICE_TOTAL'} += $total_tax;
		$order_href->{'total'} += $total_tax;
	}
	$price_total = sprintf("%.2f", $price_total);

	# save these values to the order_header table
	F::Order::update_order_header($dbh, {
									total     => $price_total,
									balance   => $price_total,
									sales_tax => $total_tax,
									order_id  => $order_id
							  }
	) or err($q);

	# format values for the template
	$vars->{'PRICE_TOTAL'}       = format_comma(sprintf("%.2f", $vars->{'PRICE_TOTAL'}));
	$vars->{'SUBTOTAL'}          = format_comma(sprintf("%.2f", $sub_total));
	$vars->{'SALES_TAX'}         = format_comma(sprintf("%.2f", $total_tax));
	$vars->{'CUSTOMER_ID'}       = $order_href->{'customer_id'};
	$vars->{'CUSTOMER_NAME'}     = $order_href->{'customer_name'};
	$vars->{'CUSTOMER_NAME'}     =~ s/\s+\(.+$//;	# remove the appended reseller name from the company name
	$vars->{'SHIP_COMPANY_NAME'} = $order_href->{'ship_company_name'};
	$vars->{'SHIPPING_ADDRESS1'} = $order_href->{'shipping_address1'};
	$vars->{'SHIPPING_ADDRESS2'} = $order_href->{'shipping_address2'};
	$vars->{'SHIPPING_CITY'}     = $order_href->{'shipping_city'};
	$vars->{'SHIPPING_STATE'}    = $order_href->{'shipping_state'};
	$vars->{'SHIPPING_COUNTRY'}  = $order_href->{'shipping_country'};
	$vars->{'SHIPPING_ZIP'}      = $order_href->{'shipping_zip'};
	$vars->{'BILLING_ADDRESS1'}  = $order_href->{'billing_address1'};
	$vars->{'BILLING_ADDRESS2'}  = $order_href->{'billing_address2'};
	$vars->{'BILLING_CITY'}      = $order_href->{'billing_city'};
	$vars->{'BILLING_STATE'}     = $order_href->{'billing_state'};
	$vars->{'BILLING_COUNTRY'}   = $order_href->{'billing_country'};
	$vars->{'BILLING_ZIP'}       = $order_href->{'billing_zip'};
	$vars->{'ADMIN_FIRST_NAME'}  = $order_href->{'admin_first_name'};
	$vars->{'ADMIN_LAST_NAME'}   = $order_href->{'admin_last_name'};
	$vars->{'ADMIN_EMAIL'}       = $order_href->{'admin_email'};
	$vars->{'ADMIN_PHONE'}       = $order_href->{'admin_phone'};
	$vars->{'ORDER_TYPE'}        = $order_href->{'order_type'};

	# get customer's payment info
	init_payment_info($dbh,$vars,$order_href,$dynamic_item_IDs);

	# get PBXtra 5.0 License Upgrades if appropriate
	addon_order_init($dbh,$vars,$order_href);

	return 1;
}


#############################################################################
# update_order: Update the order table or insert a new record if this is a new order
#############################################################################
sub update_order 
{
	my $q              = shift(@_);
	my $vars           = shift(@_);
	my $dbh            = shift(@_);
	my $valid_reseller = shift(@_);
	my $reseller_id    = shift(@_);
	my $order_id       = shift(@_);
	my $dynamic_item_IDs = shift(@_);

	my $order_href      = {};
	my $price_total     = 0;
	my $qty_phones      = 0;
	my $qty_phone_ports = 0;
	my $item_hash       = {};
	my $price_hash      = {};
	my $prorated        = {};

	# avoid updating the order if a discount has been applied
	unless ($q->param('deduction_exists'))
	{
		($price_total,$qty_phones,$qty_phone_ports,$item_hash,$price_hash,$prorated) = F::Order::get_invoice_totals($dbh,$q,$vars,$valid_reseller,$reseller_id,'',$dynamic_item_IDs);

		# update the order_header table
		my $update_order_header_values = { order_id => $order_id, total => $price_total };
		if ($vars->{'UNBOUND'})
		{
			$update_order_header_values->{'rental_phones'} = $vars->{'RENTAL_PHONES'};
		}
		my $addon_product_choice = $q->param("product_choice");
		if ($addon_product_choice =~ /\w/)
		{
			$update_order_header_values->{'addon_type'} = $addon_product_choice;
		}
		F::Order::update_order_header($dbh,$update_order_header_values) or err($q);

		# get the order as it was before making changes... so we can remove the old order item
		$order_href = F::Order::get_order($dbh,$order_id) or err($q);
		foreach my $item (@{$order_href->{'items'}})
		{
			# don't remove the Additional Services - we need to save them in case the user has
			# already selected them and is making modifications before confirming the order
			next if ($item->{'item_id'} eq $dynamic_item_IDs->{'EXPEDITED_PROVISIONING'});
			F::Order::remove_item_from_order($dbh,$order_id,$item->{'order_trans_id'}) or err($q);
		}

		# create all of the order_trans
		while( my ($item_id, $quantity) = each(%$item_hash) ) 
		{
			next if $item_id !~ /\d/ or $quantity < 1;
			F::Order::add_item_to_order($dbh, $order_id, $item_id, $quantity, $price_hash->{$item_id}, undef, $prorated->{$item_id}) or err($q); 
		}

		# reload the order
		$order_href = F::Order::get_order($dbh,$order_id) or err($q);

		if ($vars->{'ADDON'})
		{
			# PRORATE SUPPORT if necessary
			if ($order_href->{'addon_type'} eq 'change_devices')
			{
				my $has_support = F::Support::get_support_quick($dbh,$order_href->{'server_id'});
				if ($has_support)
				{
					my $number_of_seats = 0;
					foreach my $item (@{$order_href->{'items'}})
					{
						if ( ($item->{'group_name'} eq 'IP Phones' or
						      $item->{'item_id'} eq $dynamic_item_IDs->{'REPROVISIONED_PHONE'} or
						      $item->{'item_id'} eq $dynamic_item_IDs->{'REMOTE_REPROVISIONED_PHONE'}
						    ) and
					    	$item->{'item_id'} ne $dynamic_item_IDs->{'AASTRA_CT_HANDSET'} and
							$item->{'item_id'} ne $dynamic_item_IDs->{'POLYCOM_650_SIDECAR'}	)
						{
							$number_of_seats += $item->{'quantity'};
						}
					}
					if ($number_of_seats)
					{
						my $prorated_percentage = F::Order::get_prorated_annual_support($has_support->{'expire_date'});
						if ($prorated_percentage)
						{
							# server support contract expires sometime within the next year, not including today
							# first find out how many DEVICES the server CURRENTLY has
							my $annual_support = F::PBXtraAnnualSupport->new();
							my $device_cnt = $annual_support->get_num_devices($order_href->{'server_id'});
							# get the new SUPPORT TIER
							my $new_devices = $qty_phones + $qty_phone_ports;
							my $total_device_cnt = $device_cnt + $new_devices;
							my $item_id = F::Order::get_support_tier_id($total_device_cnt);
							# calculate the price
							my $support_item = F::Order::get_reseller_item($dbh, $item_id, $reseller_id) or err($q);
							my $price = sprintf("%.2f", ($support_item->{'price'} * $prorated_percentage));
							# figure out how many days prorated -- this ONLY works with 1 YEAR SUPPORT
							my $prorate_memo = $prorated_percentage * 365;
							$prorate_memo = "prorated $prorate_memo/365 days";
							# add this support item
							F::Order::add_item_to_order($dbh, $order_id, $item_id, $new_devices, $price, undef, $price, $prorate_memo) or err($q);
						}
					}
				}
			}

			# there may be nothing to ship - nullify some values in case the order has been modified from something that needed shipping
			my $total_shipment_weight = 0;
			my $expedited_shipping_trans_id = 0;
			foreach my $item (@{$order_href->{'items'}})
			{
				if ($item->{'weight'})
				{
					$total_shipment_weight += $item->{'weight'} * $item->{'quantity'};
				}
				if ($item->{'item_id'} == $dynamic_item_IDs->{'REPROVISIONED_PHONE'})
				{
					# reprovisioned phones have to be shipped to us and back, assume each one weighs 7 lbs
					$total_shipment_weight += 7 * $item->{'quantity'};
				}
				if ($item->{'item_id'} == $dynamic_item_IDs->{'EXPEDITED_PROVISIONING'})
				{
					$expedited_shipping_trans_id = $item->{'order_trans_id'};
				}
			}
			unless ($total_shipment_weight)
			{
				# nothing to ship - make sure these are NULL
				F::Order::update_order_header($dbh, {
														shipping_weight_estimated => '',
														shipping_service          => '',
														shipping_cost             => '',
														order_id                  => $order_id
													});
				if ($expedited_shipping_trans_id)
				{
					F::Order::remove_item_from_order($dbh,$order_id,$expedited_shipping_trans_id);
				}
			}
		}

	}
	else
	{
		# A DEDUCTION EXISTS - THE CUSTOMER SHOULD NOT HAVE BEEN GIVEN A MODIFY ORDER PAGE - GET THESE VALUES MANUALLY
		$order_href = F::Order::get_order($dbh,$order_id) or err($q);
		$price_total = $order_href->{'total'};
		# manually get the number of phones and phone ports
		foreach my $item (@{$order_href->{'items'}})
		{
			my $item_ref = F::Order::get_reseller_item($dbh,$item->{'item_id'},$reseller_id) or err($q);
			$item_hash->{$item->{'item_id'}} = $item->{'quantity'};
		}
	}

	# No items were actually purchased
	unless(keys(%$item_hash))
	{
		push(@{$vars->{MSG_ERROR}}, "You must fill out the Add-On Order form.");
		return undef;
	}

	return $order_href;
}


# initialize these template values for the Additional Services page
sub additional_services_init
{
	my $dbh             = shift(@_);
	my $q               = shift(@_);
	my $vars            = shift(@_);
	my $price_total     = shift(@_);
	my $qty_phones      = shift(@_);
	my $qty_phone_ports = shift(@_);
	my $order_href      = shift(@_);
	my $reseller_id     = shift(@_);
	my $dynamic_item_IDs = shift(@_);

	$vars->{'QTY_PHONES'}      = $qty_phones;
	$vars->{'QTY_PHONE_PORTS'} = $qty_phone_ports;

	get_deduction($vars,$order_href,$dbh,$reseller_id,$q,$dynamic_item_IDs);
	#
	#	deduction from the Sales Director
	#
	if ($vars->{'DEDUCTION_EXISTS'})
	{
		$price_total -= $vars->{'DEDUCTION_VALUE'};
	}

	#
	#	Promo Code
	#
	if ($vars->{'PROMO_CODE'})
	{
		my $promo_discount = $vars->{'PROMO_CODE_DISCOUNT'};
		$promo_discount =~ s/,//g;   # remove commas from the discount before subtraction
		$price_total -= $promo_discount;
	}

	# get the Expedited Provisioning info
	$vars->{'EXPEDITED_ID'} = $dynamic_item_IDs->{'EXPEDITED_PROVISIONING'};
	$vars->{'EXPEDITE_FEE'} = sprintf("%.2f", ($price_total * 0.05));
	#$vars->{'EXPEDITE_FEE'} =~ s/\.\d\d$//;	# parse decimal points out of the Expedite Fee
	$vars->{'EXPEDITE_FEE'} = ($vars->{'EXPEDITE_FEE'} < 10 ? 10 : $vars->{'EXPEDITE_FEE'});	# minimum $10 Expedite Fee
	if ($order_href->{'order_type'} eq 'addon')
	{
		my $hide_expedite = 1;
		foreach my $item (@{$order_href->{'items'}})
		{
			if ($item->{'group_name'} eq 'PBXtra UNBOUND Handset Rental')
			{	
				$hide_expedite = 0;
				last;
			}
			if ($item->{'group_name'} eq 'IP Phones')
			{
				$hide_expedite = 0;
				last;
			}
			if ($item->{'item_id'} == $dynamic_item_IDs->{'UNBOUND_QoS_ROUTER'})
			{
				$hide_expedite = 0;
				last;
			}
		}
		if ($hide_expedite)
		{
			# do not allow Expedite Fee if no provisionable items are present
			$vars->{'EXPEDITE_FEE'} = 0;
		}
	}

	# save the ordered items to know if any of the additional services have already been ordered
	# this is in case the user has returned to make changes before confirming the order
	$vars->{'ORDER_ITEMS'} = $order_href->{'items'};
	$vars->{'ORDER_TYPE'}  = $order_href->{'order_type'};

	return 1;
}


#
#	submit a ticket for an addon order that doesn't fit regular categories (i.e. "Other")
#
sub addon_other_rt_ticket
{
	my $dbh        = shift(@_);
	my $q          = shift(@_);
	my $vars       = shift(@_);
	my $order_href = shift(@_);

	# save values for the RT message
	$vars->{'NAME'}  = $order_href->{'customer_name'};
	$vars->{'EMAIL'} = $order_href->{'admin_email'};
	my $ticket_subject = $vars->{'NAME'} . "'s PBXtra Order (addon for server $order_href->{server_id})";
	if ($vars->{'UNBOUND'})
	{
		$ticket_subject = $vars->{'NAME'} . "'s UNBOUND Order (addon for server $order_href->{server_id})";
	}

	my $customer_info = F::Customer::get_customer_info($dbh,$order_href->{'customer_id'});

	my $content = "Customer ID # $order_href->{customer_id} ($customer_info->{name})<BR>\n";
	$content   .= "server ID # $order_href->{server_id}<BR><BR>\n";
	$content   .= "Billing Address:<BR>\n";
	$content   .= "$order_href->{customer_name}<BR>\n";
	$content   .= "$order_href->{billing_address1} $order_href->{billing_address2}<BR>\n";
	$content   .= "$order_href->{billing_city}, $order_href->{billing_state}<BR>\n";
	$content   .= "$order_href->{billing_zip} $order_href->{billing_country}<BR><BR>\n";
	$content   .= "Shipping Address:<BR>\n";
	$content   .= "$order_href->{ship_company_name}<BR>\n";
	$content   .= "$order_href->{shipping_address1} $order_href->{shipping_address2}<BR>\n";
	$content   .= "$order_href->{shipping_city}, $order_href->{shipping_state}<BR>\n";
	$content   .= "$order_href->{shipping_zip} $order_href->{shipping_country}<BR><BR>\n";

	if ($order_href->{'reseller_id'})
	{
		# add optional reseller info
		my $reseller = F::Resellers::get_reseller($dbh,$order_href->{'reseller_id'},'reseller_id') or err($q);
		$content .= "RESELLER: $reseller->{company} (ID # $reseller->{reseller_id})<BR>\n";
		$content .= "Reseller Name: $reseller->{first_name} $reseller->{last_name}<BR>\n";
		$content .= "Reseller Email: $reseller->{email}<BR>\n";
		$content .= "Reseller Phone: $reseller->{work_phone}<BR><BR>\n";
	}

	$content   .= "Order Contact Name: $order_href->{admin_first_name} $order_href->{admin_last_name}<BR>\n";
	$content   .= "Order Contact Email: $order_href->{admin_email}<BR>\n";
	$content   .= "Order Contact Phone: $order_href->{admin_phone}<BR><BR>\n";

	# add the comments the customer provided in the order_items.tt form
	my $customer_comments = $q->param('change_other');
	$customer_comments =~ s/\n/<BR>\n/g;
	$content   .= "Customer Comments:<BR>\n$customer_comments<BR>\n";

	# set the working directory to the RT lib
	# RT is doing something *un*funny with the @INC path
	chdir "/opt/rt3/lib/";

	if ($order_href->{'ticket_id'} =~ /\w/)
	{
		# RT ticket already exists - update it
		my $rt = F::RT->new(F::RT::kRT_USER_ID_PMAD(), $order_href->{'ticket_id'});
		$rt->Priority(5);
		$rt->Requestors($vars->{'EMAIL'});
		$rt->Subject($ticket_subject);
		$rt->AddComment($content);
		#$rt->AdminCc($vars->{'SALES_PERSON_EMAIL'});
	}
	else
	{
		# create a new RT ticket
		my $rt = F::RT->new(F::RT::kRT_USER_ID_PMAD());
		$rt->Subject($ticket_subject);
		$rt->Queue('Customer Care');
		$rt->InitialPriority(5);
		$rt->Requestors($vars->{'EMAIL'});
		$rt->AddComment($content);
		$order_href->{'ticket_id'} = $rt->CreateTicket;

		F::Order::update_order_header($dbh, {
												order_id  => $order_href->{'order_header_id'},
												ticket_id => $order_href->{'ticket_id'}
											}
		);
	}

	# change back to the normal working directory
	chdir $working_dir or err($q);

	$vars->{'ADDON_OTHER_TICKET_ID'} = $order_href->{'ticket_id'};

	return 1;
}


#
#	submit the order as an RT ticket
#
sub create_rt_ticket
{
	my $q           = shift(@_);
	my $vars        = shift(@_);
	my $dbh         = shift(@_);
	my $order_href  = shift(@_);
	my $order_id    = shift(@_);

	# save values for the RT message
	my $name  = $order_href->{'customer_name'};
	my $email = $order_href->{'admin_email'};
	my $ticket_subject = $name . "'s PBXtra Order";
	if ($vars->{'UNBOUND'})
	{
		$ticket_subject = $name . "'s UNBOUND Order";
	}
	if ($vars->{'ADDON'})
	{
		$ticket_subject .= " (addon for server $vars->{'SID'})";
	}
	#my $sales_person = $order_href->{'sales_person'};

	# set the working directory to the RT lib
	# RT is doing something *un*funny with the @INC path
	chdir "/opt/rt3/lib/";

	my $rt = F::RT->new(F::RT::kRT_USER_ID_PMAD());
	$rt->Subject($ticket_subject);
	$rt->Queue('Orders');
	$rt->InitialPriority(5);
	$rt->Requestors($email);
	my $ticket_id = $rt->CreateTicket;
	
	$vars->{'RT_TICKET_SUBJECT'} = $ticket_subject;

	# if the order was a PARTNER REFERRAL create a ticket in billing to alert accounting of a commission
	# otherwise no tickets are needed - NetSuite handles this for us
	my $sugar_dbh = F::Database::sugarcrm_dbconnect() or err($q);
	my $proposal_id = $order_href->{'quote_header_id'};
	# get the proposal data for this order
	my $proposal_href = get_quote($dbh,$proposal_id) or err($q);
	# if there is an Account in Sugar that owns this proposal -- get it
	my $sugar_opportunity_id = $proposal_href->{'sugar_opportunity_id'};
	my $account = F::Sugar::get_sugar_account_from_opportunity($sugar_dbh,$sugar_opportunity_id);

	# this is in case there is a partner account - they should get commissions BUT this project never took off
	if ($account->{'account_type'} eq 'Partner')
	{
		my $billing_rt = F::RT->new(F::RT::kRT_USER_ID_PMAD());
		$billing_rt->Subject("Partner Commission: $ticket_subject");
		$billing_rt->InitialPriority(5);
		$billing_rt->RefersTo($ticket_id);

		my $billing_msg = "A Partner Referral Commission<br><br>";
		$billing_msg   .= "Partner Name: " . $account->{'name'} . "<br>";
		$billing_msg   .= "Billing Address: " . $account->{'billing_address_street'} . "<br>";
		$billing_msg   .= "City: " . $account->{'billing_address_city'} . "<br>";
		$billing_msg   .= "State: " . $account->{'billing_address_state'} . "<br>";
		$billing_msg   .= "Country: " . $account->{'billing_address_country'} . "<br>";
		$billing_msg   .= "Zip: " . $account->{'billing_address_postalcode'} . "<br>";
		$billing_msg   .= "Office Phone: " . $account->{'phone_office'} . "<br>";
		$billing_msg   .= "Alternate Phone: " . $account->{'phone_alternate'} . "<br>";
		$billing_msg   .= "Email: " . $account->{'email1'};

		$billing_rt->AddComment($billing_msg);
		$billing_rt->CreateTicket();
	}

	chdir $working_dir or err($q);
	return $ticket_id;
}


sub submit_order
{
	my $q           = shift(@_);
	my $vars        = shift(@_);
	my $dbh         = shift(@_);
	my $order_href  = shift(@_);
	my $order_id    = shift(@_);
	my $reseller_id = shift(@_);
	my $valid_reseller = shift(@_);
	my $intranet_id = shift(@_);
	my $dynamic_item_IDs = shift(@_);

	# get the proposal - we'll need the Sugar Opportunity ID
	my $proposal_id = $order_href->{'quote_header_id'};
	my $proposal_href = get_quote($dbh,$proposal_id) or err($q);

	init_payment_info($dbh,$vars,$order_href,$dynamic_item_IDs);

	#
	#	figure out the asterisks - their count is dynamic
	#
	my $asterisks = '';
	# save these values for the note on LIVE BACK-UP SERVERS
	my ($backup_server_selected,$backup_server_ref) = F::Order::is_live_backup_server_selected($order_href->{'items'}); # check if LBS was selected
	if ($backup_server_selected)
	{
		$asterisks .= '*';
		$vars->{'BACKUP_SERVER_SELECTED'} = 1;
		$vars->{'BACKUP_SERVER_STARS'}    = $asterisks;
	}
	# save asterisks for UNBOUND MONTHLY RECURRING TAXES
	if ($vars->{'UNBOUND'})
	{
		$asterisks .= '*';
		$vars->{'UNBOUND_MONTHLY_TAXES_ASTERISKS'} = $asterisks;
	}

	#
	#	for UNBOUND orders get recurring and non-recurring totals
	#
	if ($vars->{'UNBOUND'})
	{
		$vars->{'ORDER_ITEMS'} = $order_href->{'items'};
		F::Order::save_unbound_recurring_subtotals($vars);
	}

	# save the MEMO field for NetSuite
	my $memo_content = '';
	if ($vars->{'ADDON'})
	{
		$memo_content = 'addon';
		# look for PRORATED items
		foreach my $item (@{$order_href->{'items'}})
		{
			if ($item->{'prorate_memo'} =~ /\w/)
			{
				$memo_content .= ' ' . $item->{'prorate_memo'};
				last;
			}
		}
	}

	# SUGAR LOGIN via SOAP
	my $soap = F::SOAP::Lite->new( uri => F::Sugar::kSUGAR_NAMESPACE, proxy => F::Sugar::kSUGAR_URL );
	my $result = $soap->login({ user_name => F::Sugar::kSUGAR_USERNAME, password => F::Sugar::kSUGAR_PASSWORD })->result;
	my $session_id = $result->{'id'};

	# get the salesperson assigned to the Opportunity -- it *MIGHT* have changed
	my $assigned_user_id = '';
	my $sugar_dbh = F::Database::sugarcrm_dbconnect() or err($q);
	if ($proposal_href->{'sugar_opportunity_id'} =~ /\w+/)
	{
		# an order from a proposal - or possibly an addon with the original proposal ID saved
		my $opportunity = F::Sugar::get_sugar_opportunity_by_id($sugar_dbh,$proposal_href->{'sugar_opportunity_id'});
		$assigned_user_id = $opportunity->{'assigned_user_id'};
	}
	if ($assigned_user_id !~ /\w+/)
	{
		# no assigned user found - the Opportunity may have been deleted - or the ID was not saved
		my $contact = F::Sugar::get_sugar_contact_by_email($sugar_dbh,$order_href->{'admin_email'});
		if (ref($contact) eq "ARRAY" && ref($contact->[0]) eq "HASH")
		{
			$assigned_user_id = $contact->[0]->{'assigned_user_id'};
		}
	}
	my $sugar_salesperson = {};
	if ($assigned_user_id =~ /\w+/)
	{
		$sugar_salesperson = F::Order::get_sugar_salesperson_by_sugarid($dbh,$assigned_user_id);
	}
	$vars->{'SALES_PERSON_NAME'}  = $sugar_salesperson->{'name'};
	$vars->{'SALES_PERSON_PHONE'} = $sugar_salesperson->{'phone'};
	$vars->{'SALES_PERSON_EMAIL'} = $sugar_salesperson->{'email'};

	# get expected ship date (assuming payment is completed today)
	(my $due_date, $vars->{'DUE_DATE_ENGLISH'}) = F::Order::get_provisioned_date($order_href,$dynamic_item_IDs);

	# get the NetSuite shipping service ID
	my $shipping_IDs = F::Order::kNETSUITE_SHIPPING_IDS;
	my $netsuite_shipping_service = $shipping_IDs->{'UPS_'.$order_href->{'shipping_service'}};

#use Carp;debug_lvl(dXML);trace;debug_lvl(dMETHOD);debug_lvl(dLVL1);debug_lvl(dLVL2);
	# connect to NetSuite
	my $ns = F::NetSuite->new(
								email    => F::NetSuite::NETSUITE_EMAIL,
								password => F::NetSuite::NETSUITE_PASSWORD,
								account  => F::NetSuite::NETSUITE_ACCOUNT
							);
	process_netsuite_errors($ns,$vars);

	my $customer_info = F::Customer::get_customer_info($dbh,$order_href->{'customer_id'});

	# create the entityId - company name (reseller name) - customer ID
	my $admin_name = $order_href->{'admin_first_name'} . ' ' . $order_href->{'admin_last_name'};
	$admin_name =~ s/\s$//;
	my $companyname_truncated = $order_href->{'customer_name'} || $admin_name;
	$companyname_truncated =~ s/\s+/ /g;
	$companyname_truncated = sprintf("%.*s", 72, $companyname_truncated);
	$companyname_truncated =~ s/\s+$//; # remove trailing white space
	if ($companyname_truncated =~ /\(/ and $companyname_truncated !~ /\)/)
	{
		$companyname_truncated .= ')';  # add a closing parenthesis when needed and missing
	}
	my $entityId = $companyname_truncated . ' ' . $order_href->{'customer_id'};  # MAX length=80, companyname_truncated=72 + space + customer_id=7
	# Cleanse entries - NetSuite doesn't allow backslashes or backticks - double dashes are a bad idea around SQL
	my $companyName = $order_href->{'customer_name'} || $admin_name || 'none';
	$companyName =~ s/\s+/ /g;
	$companyName = sprintf("%.*s", 83, $companyName);	# MAX length in NetSuite=83 characters
	my $admin_email = $order_href->{'admin_email'};
	my $admin_phone = $order_href->{'admin_phone'};
	$admin_phone = sprintf("%.21s",$admin_phone);	# anything longer will choke NetSuite
	my $ship_company_name = $order_href->{'ship_company_name'};
	my $city        = $order_href->{'shipping_city'};
	my $addr1       = $order_href->{'shipping_address1'};
	my $addr2       = $order_href->{'shipping_address2'};
	my $zip         = $order_href->{'shipping_zip'};
	my $state       = $order_href->{'shipping_state'};
	my $is_taxable  = $valid_reseller ? 'False' : 'True';	# no reseller should be taxed
	my $country     = F::Country::get_netsuite_name_by_country($order_href->{'shipping_country'});
	foreach ($entityId, $companyName, $admin_email, $admin_phone, $city, $ship_company_name, $addr1, $addr2, $zip, $state, $country)
	{
		$_ =~ s/\\|\`|--|'//g;
	}

	#
	#	PARSE CREDIT CARD INFO
	#
	my $cc_info = F::Billing::get_cc_info($dbh, $order_href->{'customer_id'}, 1);
	my ($credit_card_expiration_date, $cc_name);
	if ($cc_info->[0]->{'expiration'})
	{
		# parse expiration date
		my $cc_month_expire = $cc_info->[0]->{'expiration'};
		$cc_month_expire =~ s/\d\d$//;
		my $cc_month_expire0 = $cc_month_expire;
		$cc_month_expire0 =~ s/^0//;
		my $cc_year_expire  = $cc_info->[0]->{'expiration'};
		$cc_year_expire =~ s/^\d\d//;
		$cc_year_expire = "20" . $cc_year_expire;
		my $last_day = Date::Calc::Days_in_Month($cc_year_expire,$cc_month_expire0);
		$credit_card_expiration_date = "$cc_year_expire-$cc_month_expire-$last_day" . "T11:00:00.000-08:00";
		# remove whitespace from CARD NUMBER
		$cc_info->[0]->{'card_number'} =~ s/\s//g;
		# remove leading/trailing whitespace from CC NAME and limit to 64 CHARS
		$cc_name = $cc_info->[0]->{'first_name'} . ' ' . $cc_info->[0]->{'last_name'};
		$cc_name =~ s/^\s+|\s+$//g;
		$cc_name = sprintf("%.*s", 64, $cc_name);
	}

	# see if there is already a credit card for this NetSuite customer
	my $customer_netsuite_creditcard_id = '';
	if ($customer_info->{'netsuite_id'} > 1)
	{	
		$customer_netsuite_creditcard_id = get_netsuite_customer_cc($ns, $customer_info->{'netsuite_id'});

		process_netsuite_errors($ns,$vars);
	}

	# save CREDIT CARD as an array ref
	my $payment = $order_href->{'payment_method'};
	my $netsuite_payment_options = F::Order::kNETSUITE_PAYMENT_OPTIONS();
	my $cc_aryRef = [];
	my $has_cc = 0;
	if ($payment eq "VISA" or $payment eq "MASTERCARD" or $payment eq "American Express" or $payment eq "Discover")
	{
		$cc_aryRef = 	[
							{
								'paymentMethod'  => $netsuite_payment_options->{$payment},
								'ccNumber'       => $cc_info->[0]->{'card_number'},
								'ccExpireDate'   => $credit_card_expiration_date,
								'ccName'         => $cc_name,
								'ccDefault'      => 'true'
							}
						];
		if ($customer_netsuite_creditcard_id)
		{
			$cc_aryRef->[0]->{'internalId'} = $customer_netsuite_creditcard_id;
		}
		$has_cc = 1;
	}
	else
	{
		$cc_aryRef =	[
							{
								ccNumber     => '',
								ccExpireDate => '',
								ccName       => '',
								ccDefault    => 'true'
							}
						];
	}

	# create a new customer in NetSuite if there isn't already one
	my $addressbookID = '';
	if ($customer_info->{'netsuite_id'} eq '' or $customer_info->{'netsuite_id'} eq '1')
	{
		# create a NEW customer in NetSuite
		my $customer_data = {
								entityId    => $entityId,
								companyName => $companyName,
								email       => $admin_email,
								phone       => $admin_phone,
#								taxable     => $is_taxable,
								salesRepId  => $sugar_salesperson->{'netsuite_id'},
								ccinfo      => $cc_aryRef,
								address     => [
												{
													city    => $city,
													addr1   => $addr1,
													addr2   => $addr2,
													zip     => $zip,
													state   => $state,
													country => $country
												}
											   ],
							};
		if ($vars->{'RESELLER_NETSUITE_ID'})
		{
			# add reseller's NetSuite ID as the customer's parent customer
			$customer_data->{'parent'} = $vars->{'RESELLER_NETSUITE_ID'};
		}
		$customer_info->{'netsuite_id'} = $ns->add(type => 'Customer', data => $customer_data);
		process_netsuite_errors($ns,$vars);
		if ($vars->{MSG_ERROR}) {return 0}

		# save the new NetSuite customer ID in the PBXtra database
		F::Customer::update_customer($dbh, $order_href->{'customer_id'}, {'netsuite_id'=>$customer_info->{'netsuite_id'} || undef});
		process_netsuite_errors($ns,$vars);
		# get the NetSuite CC ID back from NetSuite
		if ($has_cc)
		{
			$customer_netsuite_creditcard_id = get_netsuite_customer_cc($ns, $customer_info->{'netsuite_id'});
			process_netsuite_errors($ns,$vars);
		}
	}


	#
	#	CREATE SOME VALUES FOR THE SalesOrder
	#
	# concatenate the shipping and billing addresses
	my $shipAddress = $ship_company_name . "\n" .
					  $order_href->{'shipping_address1'} . " " . $order_href->{'shipping_address2'} . "\n" .
					  $order_href->{'shipping_city'} . ", " . $order_href->{'shipping_state'} . "\n" .
					  $order_href->{'shipping_zip'} . " " . $order_href->{'shipping_country'};
	$shipAddress =~ s/\\|\`|--|'//g;

	my $billAddress = $companyName . "\n" .
					  $order_href->{'billing_address1'} . " " . $order_href->{'billing_address2'} . "\n" .
					  $order_href->{'billing_city'} . ", " . $order_href->{'billing_state'} . "\n" .
					  $order_href->{'billing_zip'} . " " . $order_href->{'billing_country'};
	$billAddress =~ s/\\|\`|--|'//g;


	#
	#	create the notes and message that will accompany the NetSuite invoice
	#
	my $netsuite_msg = '';
	if ($vars->{'SHOW_SUPPORT_MSG'})
	{
		$netsuite_msg .= "($vars->{PHONE_CNT} Phone";
		$netsuite_msg .= "s" unless ($vars->{'PHONE_CNT'} == 1);
		$netsuite_msg .= " + $vars->{PORT_CNT} Phone Port";
		$netsuite_msg .= "s" unless ($vars->{'PORT_CNT'} == 1);
		my $contracts = $vars->{'PHONE_CNT'} + $vars->{'PORT_CNT'};
		$netsuite_msg .= ") = $contracts Software and Support Agreement";
		$netsuite_msg .= "s" if ($contracts > 1);
		$netsuite_msg .= "\n";
	}
	if ($vars->{'BACKUP_SERVER_SELECTED'})
	{
		$netsuite_msg .= "Live Back-up Servers must be provisioned with the same upgrades and expansion cards as the main server. ";
	}
	$netsuite_msg = "." if($netsuite_msg eq '');

	my @past_editions;
	# If we're upgrading editions, find editions that we do NOT want to show the customer for MRC
	if ($vars->{'ADDON'} and $vars->{'UNBOUND'})
	{
		# We only have to worry about SE/PE, since there is (currently) no upgrade past CCE
		my %recur_to_setup = (
			$dynamic_item_IDs->{'UNBOUND_SOFTWARE_STANDARD'} => $dynamic_item_IDs->{'UNBOUND_SETUP_STANDARD'},
			$dynamic_item_IDs->{'UNBOUND_SOFTWARE_PRO'}      => $dynamic_item_IDs->{'UNBOUND_SETUP_PRO'}
		);

		# Find if they're upgrading editions (more than 1 edition will show up in the items, one downgrade, one upgrade)
		my @editions = sort { $a <=> $b } map { $_->{'item_id'} } grep {
			$_->{'item_id'} == $dynamic_item_IDs->{'UNBOUND_SOFTWARE_STANDARD'}   ||
			$_->{'item_id'} == $dynamic_item_IDs->{'UNBOUND_SOFTWARE_PRO'}        ||
			$_->{'item_id'} == $dynamic_item_IDs->{'UNBOUND_SOFTWARE_CALLCENTER'} ||
			$_->{'item_id'} == $dynamic_item_IDs->{'UNBOUND_SOFTWARE_OLD_CCE'}
		} @{ $order_href->{'items'} };

		# We have an edition upgrade, do something special
		if (@editions > 1)
		{
			# We're abusing the fact that currently edition netsuite ids are in sorted order (se/pe/cce)
			# If this changes, so will this section of code.
			@past_editions = @editions;
			pop @past_editions;

			# make sure we treat recurring edition items specially as well
			push @past_editions, map { $recur_to_setup{$_} } @past_editions;
		}
	}

	#
	#	save all items to a new array of hashes for the NetSuite call
	#
	my $all_items = [];
	my $item_group_list = F::Order::kITEM_GROUP_LIST;
	foreach my $group (@$item_group_list)
	{
		# step through the groups so item show up in the right order
		foreach my $item (@{$order_href->{'items'}})
		{
			# Sometimes the item is like the group name, but not exact
			if ($group eq $item->{'group_name'})
			{
				my $item_ref = {};
				if ($item->{'item_id'} == $dynamic_item_IDs->{'EXPEDITED_PROVISIONING'} or
					$item->{'item_id'} == $dynamic_item_IDs->{'PROMO_60_DAYS'})
				{
					# only send prices for items that have no regular price in NetSuite
					$item_ref->{'amount'} = $item->{'item_price'} * $item->{'quantity'};
				}
				elsif ($item->{'item_id'} == $dynamic_item_IDs->{'PCIe_POWER_ADAPTER'} or
				    $item->{'item_id'} == $dynamic_item_IDs->{'FAX_TIMING_CABLE'})
				{
					$item_ref->{'amount'} = ($item->{'item_price'} * $item->{'quantity'}) || 0;
				}
				# There should only ever be 1 regulatory recovery fee, but just in case, make sure we handle it
				elsif ($item->{'item_id'} == $dynamic_item_IDs->{'UNBOUND_REGULATORY_FEE'})
				{
					$item_ref->{'amount'} = ($item->{'item_price'} * $item->{'quantity'}) || 0;
				}
				# Only calc the prorate price if we know it's not otherwise discounted.
				elsif ($item->{'prorated'})
				{
					$item_ref->{'amount'} = $item->{'item_price'} * $item->{'quantity'};
					if ($item->{'item_price'} < 0)
					{
						$item->{'quantity'} *= -1;
					}
				}
				# The lesser edition is being subtracted; make sure we send a negative price to netsuite
				elsif (grep { $item->{'item_id'} == $_ } @past_editions)
				{
					$item_ref->{'amount'} = $item->{'item_price'} * $item->{'quantity'};
					if ($item->{'item_price'} < 0)
					{
						$item->{'quantity'} *= -1;
					}
				}
				$item_ref->{'quantity'}   = $item->{'quantity'};
				$item_ref->{'internalId'} = $item->{'netsuite_id'};
				push (@$all_items, $item_ref);
			}
		}
	}

	# add DISCOUNTS and DEDUCTIONS as NetSuite line items - these are not items in the PBXtra database
	my $total_deduction = $vars->{'DEDUCTION_VALUE'};
	$total_deduction   =~ s/,//g;	# remove commas
	if ($total_deduction > 0)
	{
		$total_deduction *= -1;	#make the discount negative
		my $manager_discount = F::Order::get_item($dbh,$dynamic_item_IDs->{'MANAGER_DISCOUNT'});
		push @$all_items, {internalId=>$manager_discount->{'netsuite_id'}, quantity=>1, amount=>$total_deduction};
	}
	my $total_reseller_discount = $vars->{'RESELLER_DISCOUNT'};
	$total_reseller_discount   =~ s/,//g;	# remove commas
	if ($total_reseller_discount > 0)
	{
		$total_reseller_discount *= -1;	#make the discount negative
		my $reseller_discount = F::Order::get_item($dbh,$dynamic_item_IDs->{'RESELLER_DISCOUNT'});
		push @$all_items, {internalId=>$reseller_discount->{'netsuite_id'}, quantity=>1, amount=>$total_reseller_discount};
	}
	# SMALL_SERVER_DISCOUNT & PROMO_CODE_DISCOUNT should never both be present
	my $promo_code_total_discount = $vars->{'PROMO_CODE_DISCOUNT'} || 0;
	$promo_code_total_discount   =~ s/,//g;	# remove commas
	if ($promo_code_total_discount)
	{
		$promo_code_total_discount *= -1;	#make the discount negative
		push @$all_items, {internalId=>$dynamic_item_IDs->{'PROMO_DISCOUNT_TAXABLE'}, quantity=>1, amount=>$promo_code_total_discount};
	}

	if ($vars->{'UNBOUND'})
	{
		# rental phones must be accompanied by $0 purchase phones
		foreach my $item (@{$order_href->{'items'}})
		{
			if ($item->{'group_name'} eq 'PBXtra UNBOUND Handset Rental' and $item->{'unbound_rental_inventory_item_id'})
			{
				push @$all_items, {internalId=>$item->{'netsuite_id'}, quantity=>$item->{'quantity'}, amount=>0};
			}
		}
	}

my $test_cc=0;

	# has this order already been placed? Avoid multiple NetSuite orders for re-loads or legitimate modifications
	my $netsuite_transaction_id = $order_href->{'netsuite_transaction_id'} || '';
	if ($order_href->{'netsuite_salesorder_id'} eq '' or $order_href->{'netsuite_salesorder_id'} == 1)
	{
		# create a new NetSuite SalesOrder
		if ($sugar_salesperson->{'netsuite_id'} !~ /\d/)
		{
			$sugar_salesperson->{'netsuite_id'} = 526;	# WARNING! no salesperson was assigned somehow (rare but disastrous) give to 'House Account'
		}
		# GET THE ORDER TYPE
		my $netsuite_order_type;
		if ($vars->{'UNBOUND'})
		{
			# (44) Unbound : Direct - New System
			# (48) Unbound : Direct - Add-on
			$netsuite_order_type = $vars->{'ADDON'} ? 48 : 44;  # Direct UNBOUND = 44, addon = 48
			if ($vars->{'RESELLER_STATUS'} =~ /Agent|Affiliate|Reseller-Fonality-Authorized/i)
			{
				$netsuite_order_type = 45;	# Unbound : Affiliate - New System
			}
			elsif ($vars->{'RESELLER_STATUS'} =~ /authorized|Certified|Reseller-CT/i)
			{
				$netsuite_order_type = 46;	# Unbound : Authorized - New System
			}
			elsif ($vars->{'RESELLER_STATUS'} =~ /premium/i)
			{
				$netsuite_order_type = 47;	# Unbound : Premium - New System
			}
		}
		elsif ($vars->{'ADDON'})
		{
			# PBXtra - ADDON
			$netsuite_order_type = $ns->order_type("pbxtra_direct_addon");
			if ($reseller_id)
			{
				if ($vars->{'RESELLER_STATUS'} =~ /authorized|agent/i)
				{
					$netsuite_order_type = $ns->order_type("pbxtra_affiliate_addon");
				}
				else
				{
					$netsuite_order_type = $ns->order_type("pbxtra_premium_addon");
				}
			}
		}
		else
		{
			# PBXtra - Regular
			$netsuite_order_type = 5;	# PBXtra : Direct - New System
			if ($vars->{'RESELLER_STATUS'} =~ /Agent|Affiliate|Reseller-Fonality-Authorized/i)
			{
				$netsuite_order_type = 8;	# PBXtra : Affiliate - New System
			}
			elsif ($vars->{'RESELLER_STATUS'} =~ /authorized|Certified|Reseller-CT/i)
			{
				$netsuite_order_type = 35;	# PBXtra : Authorized - New System
			}
			elsif ($vars->{'RESELLER_STATUS'} =~ /premium/i)
			{
				$netsuite_order_type = 10;	# PBXtra : Premium - New System
			}
		}

		# add prefix to internal NetSuite sales order ID if necessary
		my $tranId = $vars->{'TICKET_ID'};
		if ($vars->{'UNBOUND'})
		{
			$tranId = 'UB' . $vars->{'TICKET_ID'};
		}

		my $data = {
						internalId   => $customer_info->{'netsuite_id'},
						class        => $netsuite_order_type,
						tranId       => $tranId,
						isTaxable    => $is_taxable,
						toBeEmailed  => 'false',
						custbody2    => $due_date,
						message      => $netsuite_msg,
						salesRepId   => $sugar_salesperson->{'netsuite_id'},
						billAddress  => $billAddress,
						shipAddress  => $shipAddress,
						items        => $all_items,
						memo         => $memo_content,
						$vars->{'UNBOUND'} ? (orderStatus => '_pendingFulfillment')      : (),
						$vars->{'ADDON'}   ? (custbody3   => $order_href->{'server_id'}) : (),
				   };

	    # default shippingCost to UPS ground
		my $shipping_IDs = F::Order::kNETSUITE_SHIPPING_IDS;
		my $default_shipping_service = $shipping_IDs->{'UPS_GROUND'};
	    $data->{'shipMethod'}   = (defined $netsuite_shipping_service ? $netsuite_shipping_service : $default_shipping_service);
	    # shippingCost may be 0 if this is an Add-On with nothing shippable
	    $data->{'shippingCost'} = (defined $order_href->{'shipping_cost'} ? $order_href->{'shipping_cost'} : 0);
	    # UNBOUND must be paid by CC but orders over $10k won't authorize so we'll leave the CC in the customer and set Terms
	    if ($vars->{'UNBOUND'} and $order_href->{'total'} + $order_href->{'sales_tax'} > 10000)
	    {
	        $payment = "CC - Over Limit";
	    }

		# set the SalesOrder's PAYMENT METHOD otherwise set TERMS
		if ($order_href->{'promo_60daypay'})
		{
			# save arbitrary Terms and remove credit card from the SalesOrder
			$data->{'creditCard'} = '';
			$data->{'ccNumber'} = '';
			$data->{'ccName'} = '';
			$data->{'ccStreet'} = '';
			$data->{'ccZipCode'} = '';
			$data->{'ccSecurityCode'} = '';
			$data->{'terms'} = $netsuite_payment_options->{'60 Day Promo'};
		}
		# set the SalesOrder's PAYMENT METHOD otherwise set TERMS
		elsif ($payment eq "VISA" or $payment eq "MASTERCARD" or $payment eq "American Express" or $payment eq "Discover Card")
		{
			$data->{'creditCard'} = $customer_netsuite_creditcard_id;
			# check for a TEST credit card -- but only use if the user is logged into the Intranet
			if ($cc_info->[0]->{'card_number'} == '4111111111111111' and $intranet_id)
			{
				# TEST credit card - now see if the user 
				$data->{'getAuth'} = 'False';
			}
			else
			{
				# regular customer credit card
				$data->{'getAuth'} = 'True';
			}
		}
		else
		{
			# credit cards are broken when setting to Terms -- try and zero them out anyways
			# this would only affect a SalesOrder if the Customer had already been created with a bad CC # by a user's previous iteration
			$data->{'creditCard'} = '';
			$data->{'ccNumber'} = '';
			$data->{'ccName'} = '';
			$data->{'ccStreet'} = '';
			$data->{'ccZipCode'} = '';
			$data->{'ccSecurityCode'} = '';
			$data->{'terms'} = $netsuite_payment_options->{$payment};
		}

		# credit card debugging - we must only charge $0.01 when using a real credit card # -- GetAuth will fail on test cards
		if($test_cc)
		{
			#$data->{'items'}=[{internalId=>202,quantity=>1,amount=>0.01}];
			#$data->{'shippingCost'}=0;
			$data->{'getAuth'}='False';
		}

		# get the NetSuite ID of the account to save the money to
		my $account_list = F::NetSuite::NETSUITE_DEPOSIT_ACCOUNTS;
		my $account = '';
		if ($order_href->{'payment_method'} eq 'American Express')
		{
			$account = $account_list->{'AMEX'};
		}
		elsif ($order_href->{'payment_method'} =~ /Discover|VISA|MASTERCARD/i)
		{
			$account = $account_list->{'VISA MASTERCARD'};
		}

		my $sale_type = '';
		if ($vars->{'ADDING_USER_LICENSES'})
		{
			# prepare a new data structure for a CashSale
			my $cc_info = F::Billing::get_cc_info($dbh, $order_href->{'customer_id'}, 1);
			my $order_type_id = '';
			if ($reseller_id)
			{
				my $reseller = F::Resellers::get_reseller($dbh,$reseller_id,'reseller_id') or err($q);
				if ($reseller->{'status'} =~ /authorized|agent/i)
				{
					$order_type_id = $ns->order_type("pbxtra_affiliate_addon");
				}
				else
				{
					$order_type_id = $ns->order_type("pbxtra_premium_addon");
				}
			}
			else
			{
				$order_type_id = $ns->order_type("pbxtra_direct_addon");
			}
			my $cashsale_data = {
									items          => $all_items,
									class          => $order_type_id,
									tranId         => 'Add' . $vars->{'TICKET_ID'},
									salesRepId     => $sugar_salesperson->{'netsuite_id'},
									paymentMethod  => { internalId => $ns->paymentMethodID($payment) },
									billAddress    => $billAddress,
									shipAddress    => $shipAddress,
									chargeIt       => $test_cc ? 'false' : 'true',
									toBeEmailed    => 'false',
									internalId     => $customer_info->{'netsuite_id'},
									email          => $admin_email,
									account        => $account,
									custbody3      => $order_href->{'server_id'}, 	# a.k.a. Server
									skip_cctx      => $test_cc,
									memo           => $memo_content,
									ccNumber       => $cc_info->[0]->{'card_number'},
									ccExpireDate   => $credit_card_expiration_date,
									ccName         => $cc_name,
									ccStreet       => $order_href->{'billing_address1'} .' '. $order_href->{'billing_address2'},
									ccCity         => $order_href->{'billing_city'},
									ccState        => $order_href->{'billing_state'},
									ccZipCode      => $order_href->{'billing_zip'},
									ccSecurityCode => $cc_info->[0]->{'cvv2'},
									ccApproved     => 'true'
			};
			# create a CashSale
			$sale_type = "cashSale";
			$ns->errors->clear;
			$order_href->{'netsuite_salesorder_id'} = $ns->add(type => 'CashSale', data => $cashsale_data);
			my $ns_result = process_netsuite_errors($ns,$vars);
		}
		else
		{
			# create a SalesOrder
			$sale_type = "salesOrder";
			$ns->errors->clear;
			$order_href->{'netsuite_salesorder_id'} = $ns->add(type => 'SalesOrder', data => $data);
			my $ns_result = process_netsuite_errors($ns,$vars);
		}

		if ($vars->{MSG_ERROR}) {return 0}

		# save the TRANSACTION ID and get the modified SalesOrder back to examine the calculated tax
		$ns->get(type=>$sale_type, data=>{internalId=>$order_href->{'netsuite_salesorder_id'}});
		# save the TRANSACTION ID and get the modified SalesOrder back to examine the calculated tax
		my $transaction_record   = $ns->som->dataof('//tranId');
		$netsuite_transaction_id = $transaction_record->{'_value'}[0];
		process_netsuite_errors($ns,$vars);
	}
	else
	{
		# NetSuite SalesOrder already exists -- update existing SalesOrder
		my $data = {
						internalId      => $order_href->{'netsuite_salesorder_id'},
						isTaxable       => $is_taxable,
						custbody2       => $due_date,
						message         => $netsuite_msg,
						billAddress     => $billAddress,
						shipAddress     => $shipAddress,
						shipAddressList => $addressbookID,
						items           => $all_items
				   };
	    # default shippingCost to UPS ground
		my $shipping_IDs = F::Order::kNETSUITE_SHIPPING_IDS;
		my $default_shipping_service = $shipping_IDs->{'UPS_GROUND'};
	    $data->{'shipMethod'}   = (defined $netsuite_shipping_service ? $netsuite_shipping_service : $default_shipping_service);
	    # shippingCost may be 0 if this is an Add-On with nothing shippable
	    $data->{'shippingCost'} = (defined $order_href->{'shipping_cost'} ? $order_href->{'shipping_cost'} : 0);
	    # UNBOUND must be paid by CC but orders over $10k won't authorize so we'll leave the CC in the customer and set Terms
	    if ($vars->{'UNBOUND'} and $order_href->{'total'} + $order_href->{'sales_tax'} > 10000)
	    {
	        $payment = "CC - Over Limit";
	    }

		# set the SalesOrder's PAYMENT METHOD otherwise set TERMS
		if ($order_href->{'promo_60daypay'})
		{
			# save arbitrary Terms and remove credit card from the SalesOrder
			$data->{'creditCard'} = '';
			$data->{'ccNumber'} = '';
			$data->{'ccName'} = '';
			$data->{'ccStreet'} = '';
			$data->{'ccZipCode'} = '';
			$data->{'ccSecurityCode'} = '';
			$data->{'terms'} = $netsuite_payment_options->{'60 Day Promo'};
		}
		elsif ($payment eq "VISA" or $payment eq "MASTERCARD" or $payment eq "American Express" or $payment eq "Discover Card")
		{
			$data->{'creditCard'} = $customer_netsuite_creditcard_id;
			$data->{'terms'}      = '';
			# check for a TEST credit card -- but only use if the user is logged into the Intranet
			if ($cc_info->[0]->{'card_number'} == '4111111111111111' and $intranet_id)
			{
				# TEST credit card - now see if the user
				$data->{'getAuth'} = 'False';
			}
			else
			{
				# regular customer credit card
				$data->{'getAuth'} = 'True';
			}
		}
		else
		{
			# credit cards are broken when setting to Terms -- try and zero them out anyways
			$data->{'creditCard'} = '';
			$data->{'ccNumber'} = '';
			$data->{'ccName'} = '';
			$data->{'ccStreet'} = '';
			$data->{'ccZipCode'} = '';
			$data->{'ccSecurityCode'} = '';
			$data->{'paymentMethod'} = '';
			$data->{'terms'}         = $netsuite_payment_options->{$payment};
		}
		# credit card debugging - we must only charge $0.01 when using a real credit card # -- GetAuth will fail on test cards
		if($test_cc)
		{
			#$data->{'items'}=[{internalId=>202,quantity=>1,amount=>0.01}];
			#$data->{'shippingCost'}=0;
			$data->{'getAuth'}='False';
		}

		# here's the bit that actually adds the SalesOrder
		$ns->update(type=>'SalesOrder', data=>$data);
		my $ns_result = process_netsuite_errors($ns,$vars);
		if ($vars->{MSG_ERROR}) {return 0}

		# get the modified SalesOrder back to examine the calculated tax
		$ns->get(type=>"salesOrder", data=>{internalId=>$order_href->{'netsuite_salesorder_id'}});
		process_netsuite_errors($ns,$vars);
	}


	# Do not pass go, do not change the Sugar Opportunity if there was an error
	if ($vars->{MSG_ERROR})
	{
		return 0;
	}


	#
	#	get the real SALES TAX back from the NetSuite SalesOrder
	#	
	# TAX RATE - percentage
	my $rec                         = $ns->som->dataof('//taxRate');
	$order_href->{'sales_tax_rate'} = $rec->{'_value'}[0];
	$vars->{'SALES_TAX_ENGLISH'}    = $order_href->{'sales_tax_rate'};
	# TAX TOTAL - dollar amount
	$rec                       = $ns->som->dataof('//taxTotal');
	$order_href->{'sales_tax'} = $rec->{'_value'}[0];
	$vars->{'SALES_TAX'}       = format_comma(sprintf("%.2f",$order_href->{'sales_tax'}));
	# recalculate the TOTAL to include the modified SALES TAX
	$order_href->{'total'} += $order_href->{'sales_tax'};
	$vars->{'ORDER_TOTAL'}  = format_comma(sprintf("%.2f",$order_href->{'total'}));

	# update the order_header with the most recent info
	my $update_vals = {
							order_id                => $order_id,
							sales_tax               => $order_href->{'sales_tax'},
							sales_tax_rate          => $order_href->{'sales_tax_rate'},
							total                   => $order_href->{'total'},
							sales_person            => $vars->{'SALES_PERSON_NAME'},
							netsuite_salesorder_id  => $order_href->{'netsuite_salesorder_id'},
							netsuite_transaction_id => $netsuite_transaction_id
						};
	F::Order::update_order_header($dbh,$update_vals) or (push (@{$vars->{MSG_ERROR}}, "Couldn't update order ID #$order_id"));


	# CREATE THE RT MESSAGE...
	my $content = create_ticket_message($q,$vars,$dbh,$order_href,$vars->{'SALES_PERSON_NAME'},'rt_ticket',$order_id,$reseller_id,$valid_reseller,$dynamic_item_IDs);

	my $rt_subject = $vars->{'RT_TICKET_SUBJECT'} || $order_href->{'customer_name'} .
	                                                 ($vars->{'UNBOUND'} ? "'s UNBOUND Order" : "'s PBXtra Order") .
	                                                 ($vars->{'ADDON'} ? " (addon for server $order_href->{server_id})" : '') .
	                                                 ($vars->{'RT_TICKET_SUBJECT'} ? '' : " (Modified)") . "\n";

	# set the working directory to the RT lib
	# RT is doing something *un*funny with the @INC path
	chdir "/opt/rt3/lib/";

	my $rt = F::RT->new(F::RT::kRT_USER_ID_PMAD(), $vars->{'TICKET_ID'});
	$rt->Priority(5);
	$rt->Requestors($order_href->{'admin_email'});
	$rt->Subject($rt_subject);
	$rt->AddComment($content);
	$rt->AdminCc($vars->{'SALES_PERSON_EMAIL'});

	# return to the previous working directory -- this is for the RT ticketing system
	chdir $working_dir or err($q);

	# ADDON specific code
	if ($order_href->{'order_type'} =~ /addon/)
	{
		# do not update Opportunity for ADDON orders - return now
		return 1;
	}

	#
	#	add a note to the Opportunity
	#
	my $content = create_ticket_message($q,$vars,$dbh,$order_href,$vars->{'SALES_PERSON_NAME'},'sugar',$order_id,$reseller_id,$valid_reseller,$dynamic_item_IDs);
	$content = escapeHTML($content);
	$result = $soap->set_entry(
		$session_id,
		'Notes',
		[
			{
				'name'  => 'name',
				'value' => "This proposal has been ORDERED!"
			},
			{
				'name'  => 'team_id',
				'value' => 1    # Global team
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
				'value' => $proposal_href->{'sugar_opportunity_id'}
			}
		]
	)->result;

	#
	#	change the sales_status
	#
	$result = $soap->set_entry(
		$session_id,
		'Opportunities',
		[
			{
				'name'  => 'id',
				'value' => $proposal_href->{'sugar_opportunity_id'}
			},
			{
				'name'  => 'amount',
				'value' => $order_href->{'total'}
			},
			{
				'name'  => 'sales_stage',
				'value' => 'Order Submitted'
			},
			{
				'name'  => 'description',
				'value' => $content
			}
		]
	)->result;

	# garbage collection
	$soap = undef;
	$content = undef;

	return 1;
}


#
#	get CREDIT CARD info from a NetSuite customer
#
sub get_netsuite_customer_cc
{
	my $ns          = shift(@_);
	my $customer_id = shift(@_);

	$ns->errors->clear;
	$ns->get( type => 'Customer', data => {internalId => $customer_id} );
	my $data = $ns->som->result->{record};
	my $cc = ref($data->{creditCardsList}{creditCards}) eq 'ARRAY'
		? $data->{creditCardsList}{creditCards}[0]
		: $data->{creditCardsList}{creditCards};

	return $cc->{'internalId'};
}


#
#	create the text for RT tickets and Sugar opportunities
#
sub create_ticket_message
{
	my $q              = shift(@_);
	my $vars           = shift(@_);
	my $dbh            = shift(@_);
	my $order_href     = shift(@_);
	my $sales_person   = shift(@_);
	my $msg_type       = shift(@_);
	my $order_id       = shift(@_);
	my $reseller_id    = shift(@_);
	my $valid_reseller = shift(@_);
	my $dynamic_item_IDs = shift(@_);

	my $name  = $order_href->{'customer_name'};
	my $email = $order_href->{'admin_email'};
	my $phone = $order_href->{'admin_phone'};
	$phone =~ s/^(\d{3})(\d{3})(\d{4})$/\($1\) $2-$3/;

	my $my_order_type = "PBXtra Order";
	if ($vars->{'UNBOUND'})
	{
		$my_order_type = "UNBOUND Order";
	}

	my $my_order_type = "PBXtra Order";
	if ($vars->{'UNBOUND'})
	{
		$my_order_type = "UNBOUND Order";
	}

	# track if CCE or HUD Agent are on the proposal for a possible discount
	my $cce_quote       = 0;
	my $hud_agent_quote = 0;
	my $total_phones    = 0;

	my $content = "<br><p>$name (<a href=mailto:$email>$email</a>) has placed an ";
	if ($vars->{'ADDON'})
	{
		$content .= "ADDON ";
	}
	$content .= "order</p>";

	$content .= "The $my_order_type number is " . $vars->{'TICKET_ID'} . ".";
	$content .= "<p>Customer ID: " . $order_href->{'customer_id'} . "<br>";
	$content .= "Customer Name: $name<br>";
	if ($vars->{'SERVER_ID'})
	{
		$content .= "Server ID: ". $vars->{'SERVER_ID'} ."<br>";
	}

	if ($reseller_id)
	{
		$content .= "Primary Reseller Contact Name: ";
	}
	else
	{
		$content .= "Contact Name: ";
	}
	$content   .= ucfirst($order_href->{'admin_first_name'}) . " " . ucfirst($order_href->{'admin_last_name'}) . "<br>";

	if ($reseller_id)
	{
		$content .= "Primary Reseller Contact Phone: ";
	}
	else
	{
		$content .= "Contact Phone: ";
	}
	$content   .= "$phone<br>";

	if ($reseller_id)
	{
		$content .= "Reseller: $vars->{RESELLER_NAME} (ID #$reseller_id, status: $vars->{RESELLER_STATUS})<br>";
		$content .= "Channel Manager: $sales_person<br>";
	}
	else
	{
		$content .= "Salesperson: $sales_person<br>";
	}
	$content   .= "</p><pre>";

	if ($valid_reseller)
	{
		$content .= "Description                                                Retail  Qty         Price    Sub Total<br>";
		$content .= "-----------------------------------------------------+-----------+----+-------------+------------<br>";
	}
	else
	{
		$content .= "Description                                                 Price  Qty    Sub Total<br>";
		$content .= "-----------------------------------------------------+-----------+----+------------<br>";
	}

	my $item_group_list = F::Order::kITEM_GROUP_LIST;
	foreach my $group (@$item_group_list)
	{
		foreach my $item (@{$order_href->{'items'}})
		{
			if ($item->{'group_name'} =~ /^$group$/i)
			{
				# remove commas for math functions
				my $item_price = $item->{'item_price'};
				$item_price    =~ s/,//g;
				$content .= sprintf("%-53s",$item->{'name'});
				if ($valid_reseller)
				{
					$content .= '| $' . sprintf("%9s",$item->{'price'});
				}
				else
				{
					$content .= '| $' . sprintf("%9s",format_comma(sprintf("%.2f", $item->{'item_price'})));
				}
				$content .= '|'   . sprintf("%4s",$item->{'quantity'});
				if ($valid_reseller)
				{
					$content .= '| $' . sprintf("%11s",format_comma(sprintf("%.2f", $item->{'item_price'})));
					my $reseller_subtotal = $item_price * $item->{'quantity'};
					$content .= '| $' . sprintf("%10s",format_comma(sprintf("%.2f", $reseller_subtotal)));
				}
				else
				{
					my $subtotal = $item_price * $item->{'quantity'};
					$content .= '| $' . sprintf("%10s",format_comma(sprintf("%.2f", $subtotal)));
				}
				$content .= "<br>";
			}
		}
	}
	$content .= "<p>";


	# reseller totals
	if ($valid_reseller)
	{
		$content .= "<br>                                     TOTAL RETAIL: \$ ";
		$content .= sprintf("%10s", $vars->{'RETAIL_TOTAL'});
		$content .= "<br>                                RESELLER DISCOUNT: \$ ";
		$content .= sprintf("%10s", '-' . $vars->{'RESELLER_DISCOUNT'});
	}

	# deduction from the Sales Director
	if ($vars->{'DEDUCTION_EXISTS'})
	{
		$content .= "<br>                               MANAGER'S DISCOUNT: \$ ";
		$content .= sprintf("%10s", '-' . format_comma(sprintf("%.2f", $vars->{'DEDUCTION_VALUE'})));
	}

	# Promo Code
	if ($vars->{'PROMO_CODE'})
	{
		$content .= '<br>                             PROMOTIONAL DISCOUNT: $ ';
		$content .= sprintf("%10s", '-'.$vars->{'PROMO_CODE_DISCOUNT'});
	}

	$content .= '<br>                                        SUB TOTAL: $ ';
	$content .= sprintf("%10s", $vars->{'SUBTOTAL'});

	# SALES TAX
	if ($order_href->{'sales_tax'} > 0)
	{
		my $percent = $order_href->{'shipping_state'} . ' sales tax (' . $order_href->{'sales_tax_rate'} . '%)';
		$percent = sprintf("%50s",$percent);
		my $sales_tax = sprintf("%.2f",$order_href->{'sales_tax'});
		$sales_tax = format_comma(sprintf("%.2f", $sales_tax));
		$sales_tax = sprintf("%10s",$sales_tax);
		$content .= "<br>$percent \$ $sales_tax";
	}

	# shipping & handling
	if ($order_href->{'shipping_cost'})
	{
		my $shipping_and_handling = "Shipping and Handling (" . $order_href->{'shipping_service'} . ')';
		$shipping_and_handling = sprintf("%50s",$shipping_and_handling);
		$content .= "<br>$shipping_and_handling \$ " . sprintf("%10s",format_comma(sprintf("%.2f", $order_href->{'shipping_cost'})));
	}

	if ($vars->{'UNBOUND'})
	{
		$content .= "<br>                              FIRST MONTH'S TOTAL: \$ ";
		$content .= sprintf("%10s",format_comma(sprintf("%.2f", $order_href->{'total'})));

		my $monthly_recurring_text = "$vars->{UNBOUND_MONTHLY_TAXES_ASTERISKS} Recurring Monthly Charges:";
		$monthly_recurring_text = sprintf("%50s",$monthly_recurring_text);
		$content .= "<br>$monthly_recurring_text \$ " . sprintf("%10s", format_comma($vars->{'RECURRING_TOTAL'}));
	}
	else
	{
		$content .= '<br>                                            TOTAL: $ ';
		$content .= sprintf("%10s",format_comma(sprintf("%.2f", $order_href->{'total'})));
	}

	$content .= "</p><br>";

	# display the asterisk comments
	my $other_stars = 0;
	if ($vars->{'BACKUP_SERVER_SELECTED'})
	{
		$content .= $vars->{'BACKUP_SERVER_STARS'} . ' Live Back-up Servers must be provisioned with the same upgrades ';
		$content .= 'and expansion cards as the main server.';
		$other_stars = 1;
	}
	if ($vars->{'SHOW_SUPPORT_MSG'})
	{
		$content .= '<br>' if ($other_stars);
		$content .= $vars->{'SUPPORT_STARS'} . " ($vars->{PHONE_CNT} Phone";
		$content .= "s" unless ($vars->{'PHONE_CNT'} == 1);
		$content .= " + $vars->{PORT_CNT} Phone Port";
		$content .= "s" unless ($vars->{'PORT_CNT'} == 1);
		my $contracts = $vars->{'PHONE_CNT'} + $vars->{'PORT_CNT'};
		$content .= ") = $contracts Software & Support Agreement";
		$content .= "s" if ($contracts > 1);
		$other_stars = 1;
		if ($vars->{'PRORATED_SUPPORT'})
		{
			$content .= '<br>&nbsp;&nbsp;' . $vars->{'PRORATED_TEXT'};
		}
	}
	elsif ($vars->{'PRORATED_SUPPORT'})
	{
		$content .= '<br>' if ($other_stars);
		$content .= $vars->{'PRORATED_SUPPORT_STARS'} . " " .$vars->{'PRORATED_TEXT'};
		$other_stars = 1;
	}
	if ($vars->{'UNBOUND'})
	{
		$content .= "$vars->{UNBOUND_MONTHLY_TAXES_ASTERISKS} State and Local Taxes not included.<BR>";
	}

	# payment method
	$content .= "</pre>";
	$content .= "<p>Payment Method: " . $order_href->{'payment_method'} . "</p><br>";
	$content .= "<p>SHIPPING ADDRESS:<br>";
	$content .= $order_href->{'ship_company_name'} . "<br>";
	$content .= $order_href->{'shipping_address1'} . "<br>";
	if ($order_href->{'shipping_address2'} =~ /\w/)
	{
		$content .= $order_href->{'shipping_address2'} . "<br>"
	}
	$content .= $order_href->{'shipping_city'} . ", " . $order_href->{'shipping_state'} . "<br>";
	$content .= $order_href->{'shipping_country'} . " " . $order_href->{'shipping_zip'} . "</p>";

	$content .= "<br><p>Estimated Shipping Details:<br>";
	my @shipping_details = split(/\s*,\s*/, $order_href->{'shipping_weight_estimated'});
	if (@shipping_details)
	{
		foreach my $detail (@shipping_details)
		{
			$content .= "$detail<br>";
		}
	}
	else
	{
		$content .= "No items to ship.";
	}
	$content .= "</p>";

	$content .= "<br><p>BILLING ADDRESS:<br>";
	$content .= $name . "<br>";
	$content .= $order_href->{'billing_address1'} . "<br>";
	if ($order_href->{'billing_address2'} =~ /\w/)
	{
		$content .= $order_href->{'billing_address2'} . "<br>"
	}
	$content .= $order_href->{'billing_city'} . ", " . $order_href->{'billing_state'} . "<br>";
	$content .= $order_href->{'billing_country'} . " " . $order_href->{'billing_zip'} . "</p>";
	$content .= "<br>";


	# RESELLER order? -- ignore extensions for CREDITS
	my $fonality_phone_credit = 0;
	my $reseller_phone_credit = 0;
	foreach my $order_item (@{$order_href->{'items'}})
	{
		if ($order_item->{'item_id'} == $dynamic_item_IDs->{'RESELLER_CREDIT_OUR_PHONE'})
		{
			$fonality_phone_credit = 1;
		}
		elsif ($order_item->{'item_id'} == $dynamic_item_IDs->{'RESELLER_CREDIT_THEIR_PHONE'})
		{
			$reseller_phone_credit = 1;
		}
	}

	# EXTENSIONS INTERVIEW
	if ($vars->{'NUM_OF_EXTENSIONS'})
	{
		$content .= get_extensions_list_text($vars,'html',$dynamic_item_IDs);
	}
	else
	{
		$content .= "There are no phones or phone ports for Fonality to configure.<br>";
	}

	return $content;
}


#
#	SAVE THE RESULTS OF THE EXTENSION INTERVIEW - EXTENSIONS FOR EACH DEVICE WERE SUBMITTED
#
sub process_extension_devices
{
	my $vars        = shift(@_);
	my $dbh         = shift(@_);
	my $q           = shift(@_);
	my $order_id    = shift(@_);
	my $order_href  = shift(@_);
	my $reseller_id = shift(@_);
	my $dynamic_item_IDs = shift(@_);

	# get a list of items with Phone Ports
	my $phone_ports = F::Order::kPHONE_PORTS;

	# update all other Extension Interview entries to deleted=1
	F::Order::delete_extension_interviews($dbh,$order_id);

	# RESELLER order? -- ignore extensions for CREDITS
	my $fonality_phone_credit = 0;
	my $reseller_phone_credit = 0;
	foreach my $order_item (@{$order_href->{'items'}})
	{
		if ($order_item->{'item_id'} == $dynamic_item_IDs->{'RESELLER_CREDIT_OUR_PHONE'})
		{
			$fonality_phone_credit = 1;
		}
		elsif ($order_item->{'item_id'} == $dynamic_item_IDs->{'RESELLER_CREDIT_THEIR_PHONE'})
		{
			$reseller_phone_credit = 1;
		}
	}

	my (%extensions, %unbound_ported_nums);
	foreach my $order_item (@{$order_href->{'items'}})
	{
		next if ($order_item->{'item_id'} eq $dynamic_item_IDs->{'POLYCOM_650_SIDECAR'});
		next if ($order_item->{'item_id'} eq $dynamic_item_IDs->{'KIRK_KWS300_BASE'});
		next if ($order_item->{'item_id'} == $dynamic_item_IDs->{'CONFIG_FEE'});   # skip the PHONE SETUP FEE - its group_name is 'IP Phones'
		next if ($order_item->{'item_id'} == $dynamic_item_IDs->{'AASTRA_CT_HANDSET'});   				# skip the EXTRA 480i HANDSETS
		next if ($fonality_phone_credit and $order_item->{'group_name'} eq 'IP Phones'); # RESELLER configuring our phones
		next if ($reseller_phone_credit and $order_item->{'item_id'} == $dynamic_item_IDs->{'RESELLER_FEE_THEIR_PHONE'}); # RESELLER configuring own phones

		my $item_ref   = get_reseller_item($dbh,$order_item->{'item_id'},$reseller_id) or err($q);
		my $group_name = $item_ref->{'group_name'};
		my $item_name  = $item_ref->{'name'};

		if ($vars->{'UNBOUND'})
		{
			# get PBXTRA UNBOUND items
			$vars->{'UNBOUND_ADDITIONAL_DID_ITEM_ID'} = $dynamic_item_IDs->{'UNBOUND_SETUP_DID'};
			$vars->{'UNBOUND_TOLLFREE_SETUP_ITEM_ID'} = $dynamic_item_IDs->{'UNBOUND_SETUP_TOLLFREE'};
			$vars->{'UNBOUND_FAX_DID_ITEM_ID'}        = $dynamic_item_IDs->{'UNBOUND_FAX'};
		}

		if ($group_name eq 'IP Phones' or
			$group_name eq 'PBXtra UNBOUND Handset Rental' or
			$order_item->{'item_id'} == $dynamic_item_IDs->{'REPROVISIONED_PHONE'} or
			$order_item->{'item_id'} == $dynamic_item_IDs->{'REMOTE_REPROVISIONED_PHONE'} or
			$order_item->{'item_id'} == $dynamic_item_IDs->{'UNBOUND_REPROVISIONING'} or
			$order_item->{'item_id'} == $dynamic_item_IDs->{'RESELLER_FEE_THEIR_PHONE'} or
			$order_item->{'item_id'} == $vars->{'UNBOUND_ADDITIONAL_DID_ITEM_ID'}	)
		{
			my $cnt = 0;
			while ($cnt++ < $order_item->{'quantity'})
			{
				my $phone_name = 'item_id_' . $order_item->{'item_id'} .  '_number_' . $cnt;
				# PBXtra UNBOUND gives a DID for every phone
				if ($vars->{'UNBOUND'})
				{
					# Unbound has 3 fields per device: an extension, a DID areacode, and a DID prefix
					my $did_areacode   = $q->param($phone_name);
					my $did_prefix_raw = $q->param($phone_name . '_nxx');
					my $did_prefix = ($did_prefix_raw eq '0' ? '' : $did_prefix_raw);	# zero is used for ANY option which should be NULL

					# save the DID in the hash by device name so they can use the same DID prefixes multiple times
					$extensions{$phone_name} = { DID => $did_areacode . $did_prefix };

					if ($q->param("${phone_name}_is_lnp"))
					{
						my $did = $q->param("${phone_name}_lnp");
						if ($did eq '')
						{
							push @{$vars->{MSG_ERROR}}, "All ported phone numbers must be entered.";
							return;
						}
						if (length($did) < 10 || length($did) > 10)
						{
							push @{$vars->{MSG_ERROR}}, "All ported phone numbers must be 10 digits long.";
							return;
						}
						if (exists $unbound_ported_nums{$did})
						{
							push @{$vars->{MSG_ERROR}}, "Ported phone number #$did was assigned more than once.";
							return;
						}
						$unbound_ported_nums{$did}      = 1;
						$extensions{$phone_name}->{LNP} = 1;
						$extensions{$phone_name}->{DID} = $did;
					}
					elsif ($did_areacode eq '')
					{
						push (@{$vars->{MSG_ERROR}}, "All DID Areacodes must be selected.");
						return;
					}
					elsif ($did_prefix_raw eq '')
					{
						push @{$vars->{MSG_ERROR}}, "All DID Prefixes must be selected or 'Any'.";
						return;
					}
				}
				else
				{
					my $extension  = $q->param($phone_name);
					# get extensions for PBXtra
					if ($extension eq '')
					{
						push (@{$vars->{MSG_ERROR}}, "All extension numbers must be entered.");
						return;
					}
					elsif ($extensions{$extension})
					{
						push (@{$vars->{MSG_ERROR}}, "Extension #$extension was assigned more than once.");
						return;
					}
					elsif (length($extension) < 3 || length($extension) > 6)
					{
						push (@{$vars->{MSG_ERROR}}, "All extensions must be between 3 and 6 digits long.");
						return;
					}

					# save the extension in a hash to save all at once
					$extensions{$extension} = $phone_name;
				}
			}
		}
		elsif ($order_item->{'item_id'} == $dynamic_item_IDs->{'RHINO_FXS'})
		{
			next if ($fonality_phone_credit);	# RESELLER configuring our phones
			my $cnt = 0;
			my $total = $order_item->{'quantity'} * 4;
			while ($cnt < $total)
			{
				$cnt++;
				my $port_name = 'rhino_phone_port_' . $cnt;
				my $extension = $q->param($port_name);
				unless ($extension =~ /\d/)
				{
					push (@{$vars->{MSG_ERROR}}, "All Extension numbers must be completed.");
					return;
				}
				if ($extensions{$extension})
				{
					push (@{$vars->{MSG_ERROR}}, "Extension #$extension was assigned more than once.");
					return;
				}
				$extensions{$extension} = $port_name; # save the extension in a hash to save all at once
			}
		}
		elsif ($phone_ports->{$order_item->{'item_id'}})
		{
			next if ($fonality_phone_credit);	# RESELLER configuring our phones
			my $total_cnt = 0;
			my $item_cnt = 0;
			while ($item_cnt < $order_item->{'quantity'})
			{
				$item_cnt++;
				my $port_cnt = 0;
				while ($port_cnt < $phone_ports->{$order_item->{'item_id'}})
				{
					$total_cnt++;
					$port_cnt++;
					my $port_name = 'item_id_' . $order_item->{'item_id'} .  '_number_' . $total_cnt;
					my $extension = $q->param($port_name);
					unless ($extension =~ /\d/)
					{
						push (@{$vars->{MSG_ERROR}}, "All Extension numbers must be completed.");
						return;
					}
					if ($extensions{$extension})
					{
						push (@{$vars->{MSG_ERROR}}, "Extension #$extension was assigned more than once.");
						return;
					}
					$extensions{$extension} = $port_name; # save the extension in a hash to save all at once
				}
			}
		}
		elsif ($order_item->{'item_id'} == $vars->{'UNBOUND_TOLLFREE_SETUP_ITEM_ID'})
		{
			my $cnt = 0;
			while ($cnt++ < $order_item->{'quantity'})
			{
				# just use a place-holder, the user can no longer choose what NPA they want for toll free
				$extensions{"item_id_$order_item->{'item_id'}_number_$cnt"} = { DID => 800 };
			}
		}
		elsif ($order_item->{'item_id'} == $vars->{'UNBOUND_FAX_DID_ITEM_ID'})
		{
			my $cnt = 0;
			while ($cnt++ < $order_item->{'quantity'})
			{
				my $fax_name = 'item_id_' . $order_item->{'item_id'} .  '_number_' . $cnt;
				my $fax_value = $q->param($fax_name);
				if ($fax_value =~ /\d/)
				{
					$extensions{"item_id_$order_item->{item_id}_number_$cnt"} = $fax_value;
				}
				else
				{
					push (@{$vars->{MSG_ERROR}}, "All Fax DID numbers must be completed.");
					return;
				}
			}
		}
	}

	# make sure the extension has not already been used on this server
	if ($vars->{'ADDON'} and $order_href->{'server_id'})
	{
		my $old_extensions = F::Extensions::get_extension_simple($dbh,$order_href->{'server_id'});
		foreach my $old_extension (@$old_extensions)
		{
			foreach my $new_extension (keys %extensions)
			{
				if ($new_extension eq $old_extension->{'extension'})
				{
					push (@{$vars->{MSG_ERROR}}, "Extension #$new_extension is already assigned on your server.");
					return;
				}
			}
		}
	}

	# add all Extension Interview entries
	if ($vars->{'UNBOUND'})
	{
		# UNBOUND allows devices to have the same 'extension' because we're only saving the DID's areacode and prefix
		foreach my $phone_name (sort keys %extensions)
		{
			if ($phone_name =~ /^item_id_$vars->{UNBOUND_FAX_DID_ITEM_ID}_number_/)
			{
				F::Order::add_extension_interview($dbh, $order_id, $phone_name, $extensions{$phone_name});
			}
			else
			{
				F::Order::add_extension_interview($dbh, $order_id, $phone_name, $extensions{$phone_name}->{DID}, $extensions{$phone_name}->{LNP});
			}
		}
	}
	else
	{
		foreach my $extension (sort keys %extensions)
		{
			F::Order::add_extension_interview($dbh,$order_id,$extensions{$extension},$extension);
		}
	}
}



#
#	SAVE THE ORDERING CUSTOMER'S IP ADDRESS AS A CONFIRMATION OF THEIR HAVING CHECKED THE TERMS & CONDITIONS
#
sub save_customer_ip
{
	my $q           = shift(@_);
	my $dbh         = shift(@_);
	my $order_id    = shift(@_);
	my $remote_addr = shift(@_);
	my $remote_port = shift(@_);

	update_order_header( $dbh,	{ 
									order_id        => $order_id,
									user_ip_address => "$remote_addr (port '$remote_port')"
								}
	) or err($q);

	return 1;
}


#
#	get all the deductions from an order - promos, deductions, discounts (except Reseller Discounts)
#	saves values in the $vars hash
#
sub get_deduction
{
	my $vars        = shift(@_);
	my $order_href  = shift(@_);
	my $dbh         = shift(@_);
	my $reseller_id = shift(@_);
	my $q           = shift(@_);
	my $dynamic_item_IDs = shift(@_);

	#
	#	deduction from the Sales Director
	#
	if ($order_href->{'deduction_expire_date'} =~ /\d/ && $order_href->{'deduction_expire_date'} > 0)
	{
		# A DEDUCTION IS PRESENT
		# get the expiration date
		my ($exp_year,$exp_month,$exp_day) = split(/-/,$order_href->{'deduction_expire_date'});
		my $expire_days  = Date_to_Days($exp_year,$exp_month,$exp_day);
		# compare it to the current date
		my ($current_year,$current_month0,$current_day0) = get_current_date();
		my $current_days = Date_to_Days($current_year,$current_month0,$current_day0);
		if ($expire_days >= $current_days and $order_href->{'deduction'} > 0)
		{
			# THE DEDUCTION HAS NOT EXPIRED YET
			$vars->{'DEDUCTION_EXISTS'} = 1;
			$vars->{'DEDUCTION_VALUE'} = $order_href->{'deduction'};
			$vars->{'DEDUCTION_VALUE_COMMIFIED'} = format_comma(sprintf("%.2f", $order_href->{'deduction'}));
		}
	}

	#
	#	Promo Code
	#
	$vars->{'PROMO_CODE'} = 0;
	my $promo_discount = F::Order::get_promo_code_discount($dbh,$order_href,$reseller_id,$dynamic_item_IDs);

	#
	#	only give the larger of the 2 discounts (Promo & Small-Server)
	#
	if ($promo_discount > 0)
	{
		$vars->{'PROMO_CODE_DISCOUNT'} = format_comma(sprintf("%.2f", $promo_discount));
		$vars->{'PROMO_CODE'} = $order_href->{'promo_code'};
	}
}


#
#	GET THE TOTAL PRICE, NUMBER OF PHONE PORTS AND PHONES FROM AN ORDER
#
sub get_order_subtotals
{
	my $dbh        = shift(@_);
	my $order_href = shift(@_);
	my $dynamic_item_IDs = shift(@_);

	# get the total price minus any Additional Services
	my $price_total = 0;
	foreach my $order_item (@{$order_href->{'items'}})
	{
		next if($order_item->{'item_id'} eq $dynamic_item_IDs->{'EXPEDITED_PROVISIONING'});
		$price_total += ($order_item->{'item_price'} * $order_item->{'quantity'});
	}
	my ($qty_phone_ports,$qty_phones) = F::Order::get_phone_count($dbh,$order_href,$dynamic_item_IDs);

	return ($price_total,$qty_phone_ports,$qty_phones);
}


#
#	creates a text style format of an EXTENSION LIST
#	if 'html' is passed as the 2nd parameter -- the text will be wrapped by <pre> tags and lines delimted wih <br>
#	otherwise lines will be delimited by \n
#
#############################################################################
sub get_extensions_list_text
{
	my $vars  = shift(@_);
	my $style = shift(@_);
	my $dynamic_item_IDs = shift(@_);

	my $html = ($style eq 'html') ? 1 : 0;

	my $msg = '';
	$msg .= "<pre>" if ($html);
	my $extension_size = "%-11s";
	if ($vars->{'UNBOUND'})
	{
		$msg .= "Phone Number   Device";
		$extension_size = "%-15s";
	}
	else
	{
		$msg .= "Extension Device";
	}
	if ($html)
	{
		$msg .= "<br>";
	}
	else
	{
		$msg .= "\n";
	}

	foreach my $item (sort { $a->{'name'} cmp $b->{'name'} } @{$vars->{'EXTENSION_ITEMS'}})
	{
		next if($item->{'item_id'} == $dynamic_item_IDs->{'POLYCOM_650_SIDECAR'});

		if ($item->{'group_name'} eq 'IP Phones' or
			$item->{'group_name'} eq 'PBXtra UNBOUND Handset Rental' or
			$item->{'item_id'} eq $dynamic_item_IDs->{'REPROVISIONED_PHONE'} or
			$item->{'item_id'} eq $dynamic_item_IDs->{'REMOTE_REPROVISIONED_PHONE'} or
			$item->{'item_id'} eq $dynamic_item_IDs->{'UNBOUND_REPROVISIONING'} or
			$item->{'item_id'} eq $dynamic_item_IDs->{'RESELLER_FEE_THEIR_PHONE'})
		{
			my $myCnt = 0;
			while ($myCnt < $item->{'quantity'})
			{
				$myCnt++;
				my $var_name = 'item_id_' . $item->{'item_id'} . '_number_' . $myCnt;
				if ($vars->{'UNBOUND'})
				{
					$var_name .= '_prettytext';	# UNBOUND uses two values combined into 1 - NPA & NXX
				}
				my $phone_name = ($item->{'item_id'} eq $dynamic_item_IDs->{'RESELLER_FEE_THEIR_PHONE'}) ? 'Reseller Provided Phone' : $item->{'name'};
				$msg .= sprintf($extension_size, $vars->{$var_name}) . "$phone_name ($myCnt)";
				if ($html)
				{
					$msg .= "<br>";
				}
				else
				{
					$msg .= "\n";
				}
			}
		}
		elsif ($item->{'item_id'} == $dynamic_item_IDs->{'RHINO_FXS'})
		{
			my $myCnt = 0;
			my $myTotal = $item->{'quantity'} * 4;
			while ($myCnt < $myTotal)
			{
				$myCnt++;
				my $var_name = 'rhino_phone_port_' . $myCnt;
				$msg .= sprintf($extension_size, $vars->{$var_name}) . "Rhino Channel - phone port ($myCnt)";
				if ($html)
				{
					$msg .= "<br>";
				}
				else
				{
					$msg .= "\n";
				}
			}
		}
		elsif ($vars->{'PHONE_PORTS'}->{$item->{'item_id'}})
		{
			my $total_cnt = 0;
			my $item_cnt  = 0;
			my $quantity  = $item->{'quantity'};
			if ($item->{'extension_qty'} > 0)
			{
				$quantity = $item->{'extension_qty'};
			}
			while ($item_cnt < $quantity)
			{
				$item_cnt++;
				my $port_cnt = 0;
				while ($port_cnt < $vars->{'PHONE_PORTS'}->{$item->{'item_id'}})
				{
					$port_cnt++;
					$total_cnt++;
					my $var_name = 'item_id_' . $item->{'item_id'} . '_number_' . $total_cnt;
					$msg .= sprintf($extension_size, $vars->{$var_name}) . $item->{'name'} . " (phone port $total_cnt)";
					if ($html)
					{
						$msg .= "<br>";
					}
					else
					{
						$msg .= "\n";
					}
				}
			}
		}
		elsif ($item->{'item_id'} == $vars->{'UNBOUND_ADDITIONAL_DID_ITEM_ID'})
		{
			my $myCnt = 0;
			while ($myCnt < $item->{'quantity'})
			{
				$myCnt++;
				my $var_name = 'item_id_' . $item->{'item_id'} . '_number_' . $myCnt . '_prettytext';
				$msg .= sprintf($extension_size, $vars->{$var_name}) . "$item->{name} ($myCnt)";
				if ($html)
				{
					$msg .= "<br>";
				}
				else
				{
					$msg .= "\n";
				}
			}
		}
	}

	if ($vars->{'UNBOUND'})
	{
		# always put toll-free numbers below the rest of the items
		foreach my $item (sort { $a->{'name'} cmp $b->{'name'} } @{$vars->{'EXTENSION_ITEMS'}})
		{
			if ($item->{'item_id'} == $vars->{'UNBOUND_TOLLFREE_SETUP_ITEM_ID'})
			{
				my $myCnt = 0;
				while ($myCnt < $item->{'quantity'})
				{
					$myCnt++;
					my $var_name = 'item_id_' . $item->{'item_id'} . '_number_' . $myCnt . '_prettytext';
					$msg .= sprintf($extension_size, $vars->{$var_name}) . "$item->{name} ($myCnt)";
					if ($html)
					{
						$msg .= "<br>";
					}
					else
					{
						$msg .= "\n";
					}
				}
			}
		}

		# no wait! now put FAX DIDs at the bottom
		foreach my $item (sort { $a->{'name'} cmp $b->{'name'} } @{$vars->{'EXTENSION_ITEMS'}})
		{
			if ($item->{'item_id'} == $vars->{'UNBOUND_FAX_DID_ITEM_ID'})
			{
				for (my $myCnt=1; $myCnt <= $item->{'quantity'}; $myCnt++)
				{
					my $var_name = 'item_id_' . $item->{'item_id'} . '_number_' . $myCnt . '_prettytext';
					$msg .= sprintf($extension_size, $vars->{$var_name} . ' ') . "$item->{name} ($myCnt)";
					$msg .= ($html ? "<br>" : "\n");
				}
			}
		}
	}

	if ($html)
	{
		$msg .= "</pre>";
	}

	return $msg;
}


#############################################################################
sub addon_order_init
{
	my $dbh        = shift(@_);
	my $vars       = shift(@_);
	my $order_href = shift(@_);

	unless ($order_href->{'order_type'} eq 'addon')
	{
		return 1;
	}

	# remember what the customer was purchasing - we only allow one kind of product at a time with addons
	$vars->{'ADDON_SELECT'} = $order_href->{'addon_type'};

	return 1;
}


#############################################################################
sub get_current_date
{
	# current year, month and day
	my $current_year  = (localtime(time))[5] + 1900;
	my $current_month = (localtime(time))[4] + 1;
	my $current_day   = (localtime(time))[3];

	# make sure the month is TWO DIGITS
	my $current_month0 = $current_month;
	$current_month0 =~ s/^(\d)$/0$1/;

	# make sure the day is TWO DIGITS
	my $current_day0   = $current_day;
	$current_day0   =~ s/^(\d)$/0$1/;

	return ($current_year,$current_month0,$current_day0);
}


#############################################################################
sub get_cookie
{
	my ($q)            = shift(@_);
	my ($cookie_name)  = shift(@_) or err($q);
	my ($cookie_value) = F::Cookies::get_cookie_from_browser($q,$cookie_name);
	

	return ($cookie_value);
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


#############################################################################
#	return the sub-directory where the template toolkits will be found
#	normally this will be 'pbxtra' unless the order is for UNBOUND
#############################################################################
sub get_template_dir
{
	my $q = shift(@_);

	my $source = $q->param('src');
	$source =~ s/\W//g;	# remove all non-word characters
	if ($source eq 'unbound')
	{
		return 'unbound';
	}
	else
	{
		return 'pbxtra';
	}
}


#############################################################################
#	return the sub-directory where the template toolkits will be found
#	normally this will be 'pbxtra' unless the order is for UNBOUND
#############################################################################
sub get_template_dir
{
	my $q = shift(@_);

	my $source = $q->param('src');
	$source =~ s/\W//g;	# remove all non-word characters
	if ($source eq 'unbound')
	{
		return 'unbound';
	}
	else
	{
		return 'pbxtra';
	}
}


#############################################################################
# err: Check the return value for an error and display it with a backtrace
#     if there is an error condition.
#
#    Args: scalar_reference[,optional_error_text]
# Returns: same reference | dies on error
#############################################################################
sub err
{
	my($q) = shift(@_);
	my($ref) = shift(@_);
	my($error) = shift(@_);

	return unless $@;
	return($ref) if(defined($ref));

	unless(defined($error)) {
		$error = 'A system error occurred.';
	}

	my $template_dir = get_template_dir($q);

	my $vars = {};
	$vars->{'ERR_MSG'}  = $error;
	$vars->{'TT_DIR'}   = $template_dir;
	$vars->{'TT_FULL_DIR'} = cwd() . '/' . $template_dir;
	$vars->{'BASE_DIR'} = cwd() . '/';
	$vars->{'TT_CONSTANTS_DIR'} = $vars->{'BASE_DIR'};

	my $tt_object = Template->new({
		ABSOLUTE  => 1,
		EVAL_PERL => 1,
		PRE_PROCESS  => $vars->{'BASE_DIR'} . "config.tt",
		WRAPPER => 'wrapper2_order.tt',
		INCLUDE_PATH => $template_dir,
		PRE_CHOMP => 1, TRIM => 1, POST_CHOMP => 1
	});

	show_template($q,$vars,'order_error.tt',undef,$tt_object);
	exit;
}



sub process_netsuite_errors
{
	my $ns   = shift(@_);
	my $vars = shift(@_);

	my $result = '';

	# skip warnings - only respond to real errors
	my $err = $ns->errors->filter(sub { $_[0]->{'code'} ne 'WARNING'});
	if (@$err)
	{
		my $err_str = $ns->errors->as_string;
		if ($err_str =~ /Code : CC_PROCESSOR_ERROR/)
		{
			push (@{$vars->{MSG_ERROR}}, "An error occurred while processing the credit card.");
			$result = "Credit Card Error";
		}
		else
		{
			push (@{$vars->{MSG_ERROR}}, COMMON_ERROR);
			$err_str .= Dumper($ns);
			# remove username and password
			$err_str =~ s/'email'.+\n/'email':########################\n/g;
			$err_str =~ s/'password'.+\n/'password':#####\n/g;
			$err_str =~ s/'account'.+\n/'account':##########\n/g;
			$err_str =~ s/'role'.+\n/'role':###\n/g;
			send_err_email($err_str);
		}
	}
	# errors stack in the NetSuite object so clear them
	$ns->errors->clear;

	return $result;
}

sub send_err_email {
	my $msg = shift;

	use Sys::Hostname;
	#my $DEV = (hostname =~ /web11/ ? 1 : 0);

	warn $msg;#write to error_log
	$msg = "<PRE>$msg\n\n". Dumper(\%ENV) ."</PRE>";
	F::Mail::send_html_email_to(
		[{EMAIL => err_email }, {EMAIL => 'pmadison@fonality.com'}, {EMAIL => 'jjenkins@fonality.com'}],
		{ FROM => 'errors@fonality.com', SUBJECT =>  hostname . ' : o.cgi error : ' . ERRID, MSG => $msg }
	);
}



