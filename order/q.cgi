#!/usr/bin/perl

use lib '/home01/pmadison';
#use lib '/home/smisel';

use strict;
use lib '/html/pbxtra';
use Cwd;
use Apache::Request();
use BackOffice::OrderMisc;
use BackOffice::Order;
use F::Util;
use BackOffice::Products;
#use Data::Dumper;
use Template ();
use F::Database;
use F::Resellers;
use F::Mail;
use Mail::Sender;
use F::Cookies;
use Apache::Cookie();
use CGI qw(escapeHTML);
use F::IntranetSupport;
use Date::Calc qw(Days_in_Month);
eval('use CGI::Carp qw(fatalsToBrowser);');
use MIME::Entity;
use HTML::HTMLDoc;
use PDF::Reuse;

use Data::Dumper;


{
main(@_);
exit;
}


sub main
{
	my @orig = @_;

	# GLOBAL VARIABLES
	my $referrer_site   = 'referringsite';
	my $request_cookie  = 'requesturl';
	my $config = BackOffice::OrderMisc::get_config();

	my $next_page = 'order_items.tt'; # default

	# 
	#	GENERAL CGI
	# 
	my $q = new Apache::Request(@orig, DISABLE_UPLOADS => 0, POST_MAX => (10 * (1024 * 1024))); 
	my $dbh = F::Database::mysql_connect() or die "Unable to connect to database; $!"; # Connect to the db
	my $vars = {};
	
	#
	#	INITIATE TEMPLATE TOOLKIT FOR STDOUT
	#
	my $tt_object = Template->new({
		ABSOLUTE  => 1,
		EVAL_PERL => 1,
		PRE_PROCESS  => $vars->{'BASE_DIR'} . 'config.tt',
		WRAPPER => 'wrapper_order.tt',
		PRE_CHOMP => 1, TRIM => 1, POST_CHOMP => 1
	});

	$vars->{'QUOTE'} = 1;
	$vars->{'HOST'}  = '/';
#	$vars->{'SCRIPT_URL'}  = 'https://' . $ENV{'HTTP_HOST'} . $ENV{'SCRIPT_NAME'}; 
#	$vars->{'SERVER_NAME'} = 'https://' . $ENV{'HTTP_HOST'};
$vars->{'SCRIPT_URL'}  = 'http://' . $ENV{'HTTP_HOST'} . $ENV{'SCRIPT_NAME'};	# DEV only
$vars->{'SERVER_NAME'} = 'http://' . $ENV{'HTTP_HOST'};	# DEV only
$vars->{'MAXITEMS'} = $config->{'maxitems'} || 10;
	#
	# get RESELLER info
	#
	my $reseller_company = undef;
	my $reseller_state   = undef;
	my $reseller_id      = undef;
	my $cookie           = undef;
	$vars->{'NOT_A_RESELLER'} = 1;
	if (my $reseller_cookie = F::Cookies::get_cookie_from_browser($q,'FONALITYreseller'))
	{
		# these values are actually in the database but derived from a random string in the cookie
		$cookie = F::Cookies::get_reseller_id_from_cookie($dbh,$q,$reseller_cookie,1);
	}
	if (defined $cookie)
	{
		# A VALID RESELLER COOKIE WAS FOUND
		my $href = F::Resellers::get_reseller($dbh,$cookie->{'reseller_id'},'reseller_id') or push(@{$vars->{MSG_ERROR}}, "Cannot retrieve reseller.");
		$reseller_id    = $href->{'reseller_id'};
		$vars->{'RESELLER_STATUS'} = $href->{'status'};
		$vars->{'RESELLER_EMAIL'}  = $href->{'email'};
		$vars->{'RESELLER_NAME'}   = $href->{'first_name'} . ' ' . $href->{'last_name'};
		$vars->{'RESELLER_ID'}     = $reseller_id;
		$vars->{'RESELLER_COOKIE_DETECTED'} = 1;
		$vars->{'RESELLER_PROPOSAL'} = 1;
		$vars->{'NOT_A_RESELLER'} = 0;
		$reseller_state = $href->{'state'};
		$reseller_company = $href->{'company'};
		if($href->{'certified'} eq 'on')
		{
			$vars->{'VALID_RESELLER'} = 1;
			$vars->{'FONALITY_INSTALL_REQUIRED'} = $href->{'fonality_install_required'};
	   	}
	   	else
	   	{
			$vars->{'INVALID_RESELLER'} = 1;
		}
	}

	#
	# get REFERRING SITE cookie
	#
	my $referral_site = F::Cookies::get_cookie_from_browser($q,'fonalityref');


	#
	#	INTRANET
	#
	# get user ID if the user is logged in - sales will do this to add sales queue call proposals
	(undef, my $intranet_id, my $intranet_name) = F::IntranetSupport::get_cookie($dbh);
	my $intranet_sugar_id = undef;
	$vars->{'INTRANET_NAME'} = $intranet_name;
	my $sales_person = {};	#Sugar::get_sugar_salesperson_by_username($dbh,$intranet_name);
	$vars->{'DOLLAR_AMT_DEDUCTION_ALLOWED'} = 0;
	$vars->{'INVALID_SUGAR_SALESPERSON'}    = 1;
	if (defined $sales_person)
	{
		$vars->{'INVALID_SUGAR_SALESPERSON'} = 0;
		# the user logged into the intranet is a valid Sugar salesperson
		$intranet_sugar_id = $sales_person->{'sugar_salesperson_id'};
		# the right to add or modify a DOLLAR AMT DEDUCTION
		if ($sales_person->{'can_deduct'})
		{
			$vars->{'DOLLAR_AMT_DEDUCTION_ALLOWED'} = 1;
			my $current_year  = (localtime(time))[5] + 1900;
			my $current_month = (localtime(time))[4] + 1;
			my $last_date = Days_in_Month($current_year,$current_month);
			$current_month =~ s/^(\d)$/0$1/;
			$vars->{'DOLLAR_AMT_EXPIRE'} = "$current_year-$current_month-$last_date";
		}
		else
		{
			$vars->{'DOLLAR_AMT_DEDUCTION_ALLOWED'} = 0;
		}
	}


	# get input data and parse nasties
	parse_input($q,$vars);

	
	# instantiate object to handle products and associated bundles, categories, labels, deployment-methods, etc
	my $products = BackOffice::Products->new();


	#
	#	If the customer is ready to buy - convert to an order
	#
	if ($vars->{'CONVERT'})
	{
		# directly convert a given Proposal to an Order
	    my $proposal_id   = $vars->{'CONVERT'} or push(@{$vars->{MSG_ERROR}}, "No proposal ID supplied");
	    my $email         = $vars->{'EML'}     or push(@{$vars->{MSG_ERROR}}, "No email supplied");
	    my $proposal_href = BackOffice::Order::get_quote_validated($dbh,$proposal_id,$email)
			or push(@{$vars->{MSG_ERROR}}, "Error getting proposal from database");
	    my $order_id = BackOffice::Order::convert_quote_to_order($dbh,$proposal_href,$vars);
	    
	    if ($vars->{MSG_ERROR})
	    {
#			form_repop($q,$vars);
			$next_page = 'order_email_quote_error.tt';
	    }
	    else
	    {
			# redirect to the o.cgi Order script
			print "Location: o.cgi?oid=$order_id&eml=$email\n\n";
			exit;
	    }
	}


	#
	#	complete the proposal
	#
	#	email customer and create Sugar Opportunity
	#
	elsif ($vars->{'EMAIL_PROPOSAL'})
	{
	    # load recalled proposals from the database
	    my $proposal_href = undef;
		if ($vars->{'PROPOSAL_ID'})
		{
			$proposal_href = BackOffice::Order::get_quote($dbh,$vars->{'PROPOSAL_ID'});
		}
		# put the random PDF file name in $proposal_href
	    get_random_pdf_name($q,$dbh,$proposal_href,$vars);
	    # save proposal header values and calculate prices
	    add_quote_values($q,$vars,$dbh,$proposal_href,$reseller_id,$products);
exit;

	    if ($vars->{MSG_ERROR})
	    {
			$next_page = 'order_items.tt';
			# get shipping services available and rates - results are stored in $vars
			BackOffice::Order::get_pbxtra_shipping($dbh,$q,$vars,$proposal_href,$reseller_id,"quote");
			order_items_init($q,$vars,$products);
			$vars->{'ORDER_ITEMS'} = $proposal_href->{'items'};	# reset selected items hash
#			form_repop($q,$vars);
	    }
	    else
	    {
			push (@{$vars->{MSG_COMPLETED}}, "<font class='order_top_heading'>Your proposal will be emailed to you at MY-EMAIL-ADDY.</font>");
			$next_page = 'order_email_quote.tt';

			#
			#	netsuite quote queue
			#

# get salesrep info
#$vars->{'SALES_PERSON_NAME'}  = $sales_person->{'name'};
#$vars->{'SALES_PERSON_TITLE'} = $sales_person->{'title'};
#$vars->{'SALES_PERSON_PHONE'} = $sales_person->{'phone'};
#$vars->{'SALES_PERSON_EMAIL'} = $sales_person->{'email'};

# expressive variable names are always best
#create_netsuite_opportunity($q,$vars,$dbh,$proposal_href,$reseller_id,$reseller_company,$reseller_state);

# send email proposal to requestor
#email_quote($q,$vars,$dbh,$proposal_href,$reseller_id);
exit;

	    }
	}

	#
	# If they are recalling an existing proposal go to a pre-loaded order_items
	#
	elsif ($vars->{'RECALL'})
	{
		order_items_init($q,$vars,$products);
		if ($vars->{MSG_ERROR})
		{
			# this error will be seen by someone clicking on a malformed link in an email
#			form_repop($q,$vars);
			$next_page = 'order_email_quote_error.tt';
		}
		else
		{
			$vars->{'RECALLED_QUOTE'} = 1;
			$next_page = 'order_items.tt';
		 }
	}

	#
	# If they are coming from the simple quote, this will be similar to recalling a quote but without validation
	#
	elsif ($vars->{'CUSTOM'})
	{
	    # grab the annual support checkbox data, since that parameter affects both simple/custom quote
	    # customer input
	    my $cookie_data = F::Cookies::get_cookie_from_browser($q, "fonality_quote");
	    my (undef, undef, $auto_support, undef) = split(',', $cookie_data);
	    $vars->{'AUTO_SUPPORT'} = $auto_support;

		order_items_init($q,$vars,$products);
	    if ($vars->{MSG_ERROR})
	    {
#			form_repop($q, $vars);
			$next_page = 'order_email_quote_error.tt';
	    }
	    else
	    {
			$next_page = 'order_items.tt';
	    }
	}

	#
	# otherwise -- select the items for a proposal and show a fresh form
	#
	else 
	{
		order_items_init($q,$vars,$products);
		$next_page = 'order_items.tt';
	}


	# we shouldn't have to tell a CGI script not to cache, but anyways... (squid caches script output)
	print "Pragma: no-cache\r\n";
	print "Cache-control: no-cache\r\n";
	print "Expires: 0\r\n";

	# print out the approptriate TT page based on $next_page
	F::Util::show_template($q,$vars,$next_page,undef,$tt_object);
	return 1;
}


sub parse_input
{
	my $q    = shift;
	my $vars = shift;

	$vars->{'CONVERT'}              = F::Util::strip_nasties($q->param('convert'))              || '';	# request to convert a quote to an order
	$vars->{'EML'}                  = F::Util::strip_nasties($q->param('eml'))                  || '';	# request for an existing quote
	$vars->{'EMAIL_PROPOSAL'}       = F::Util::strip_nasties($q->param('email_proposal'))       || '';	# submitting a quote to netsuite
	$vars->{'EXISTING_PROPOSAL'}    = F::Util::strip_nasties($q->param('existing_proposal'))    || '';	# request for a recalled quote
	$vars->{'RECALL'}               = F::Util::strip_nasties($q->param('recall'))               || '';	# recall a quote
	$vars->{'CUSTOM'}               = F::Util::strip_nasties($q->param('custom'))               || '';	# switch from the wizard to a regular quote
	$vars->{'EMAIL_TO_RESELLER'}    = F::Util::strip_nasties($q->param('email_to_reseller'))    || '';
	$vars->{'PROPOSAL_ID'}          = F::Util::strip_nasties($q->param('proposal_id'))          || '';
	$vars->{'NAME'}                 = F::Util::strip_nasties($q->param('name'))                 || '';
	$vars->{'EMAIL'}                = F::Util::strip_nasties($q->param('email'))                || '';
	$vars->{'EMAIL_CONFIRM'}        = F::Util::strip_nasties($q->param('email_confirm'))        || '';
	$vars->{'CUST_PHONE'}           = F::Util::strip_nasties($q->param('cust_phone'))           || '';
	$vars->{'WEBSITE'}              = F::Util::strip_nasties($q->param('website'))              || '';
	$vars->{'INDUSTRY'}             = F::Util::strip_nasties($q->param('industry'))             || '';
	$vars->{'TELECOMMUTERS'}        = F::Util::strip_nasties($q->param('telecommuters'))        || '';
	$vars->{'BRANCH_OFFICES'}       = F::Util::strip_nasties($q->param('branch_offices'))       || '';
	$vars->{'DOLLAR_AMT_DEDUCTION'} = F::Util::strip_nasties($q->param('dollar_amt_deduction')) || '';
	$vars->{'DOLLAR_AMT_EXPIRE'}    = F::Util::strip_nasties($q->param('dollar_amt_expire'))    || '';
	$vars->{'SHIPPING_SERVICE'}     = F::Util::strip_nasties($q->param('shipping_service'))     || '';
	$vars->{'RESELLER_PROPOSAL'}    = F::Util::strip_nasties($q->param('reseller_proposal'))    || '';
	$vars->{'PROMO_CODE'}           = F::Util::strip_nasties($q->param('promo_code'))           || '';
	$vars->{'PRODUCT'}              = F::Util::strip_nasties($q->param('product'))              || '10';	# product ID, FCS = 10
}


sub get_random_pdf_name
{
	my $q             = shift(@_);
	my $dbh           = shift(@_);
	my $proposal_href = shift(@_);
	my $vars          = shift(@_);
	my $random_string = $proposal_href->{'random_proposal_string'};

	# do not get a random number if this is a recalled quote that already has one
	if ($random_string !~ /\w/)
	{
		$random_string = F::Util::return_random_string(20);
		# save the random string for any additional quotes the customer may request
		# update the quote_header with the RT Ticket ID
		BackOffice::Order::update_quote_header($dbh,   {
										quote_id               => $vars->{'PROPOSAL_ID'},
										random_proposal_string => $random_string
									}
		) or push(@{$vars->{MSG_ERROR}}, "Cannot update quote header.");
		$proposal_href->{'random_proposal_string'} = $random_string;
	}
}


sub email_quote
{
	my ($email_msg, $proposal_msg, $error, $htmlmsg);
	my $q             = shift(@_);
	my $vars          = shift(@_);
	my $dbh           = shift(@_);
	my $proposal_href = shift(@_);
	my $reseller_id   = shift(@_);

	my $email_template    = 'order_email_quote_msg.tt';
	my $random_string     = $proposal_href->{'random_proposal_string'};
	my $proposal_file     = "pbxtra_proposal_downloads/p$random_string.pdf";
	my $proposal_template = 'dynamic_proposal.tt';
	my $proposal_template_dir = './proposal_files';

	# specify the subject
	my $subject = $vars->{'NAME'} . "'s PBXtra Proposal #$vars->{PROPOSAL_ID}";

	# create a new tt_obj because the main one has a pre_config and wrapper
	my $tt_proposal = Template->new({ POST_CHOMP => 1, TRIM => 1, PRE_CHOMP => 1, INCLUDE_PATH => $proposal_template_dir });

	# load the email body from the TT
	$tt_proposal->process($proposal_template,$vars,\$proposal_msg) or $tt_proposal->error($error); 

	#	create the proposal - a .pdf file to be downloaded by the customer
	my $htmldoc = new HTML::HTMLDoc();
	$htmldoc->path('proposal_files');
	$htmldoc->set_bodyfont('Arial');
	$htmldoc->set_fontsize('10');
	#$htmldoc->set_left_margin(15,'mm');
	#$htmldoc->set_bottom_margin(5,'mm');
	$htmldoc->set_page_size('letter');
	$htmldoc->set_left_margin(0,'mm');
	$htmldoc->set_bottom_margin(5,'mm');
	$htmldoc->set_top_margin(0,'mm');
	$htmldoc->set_right_margin(0,'mm');
	#$htmldoc->set_bodyimage('proposal_files/logolight.jpg');
	$htmldoc->set_footer('.','/','');	# page X of Y in the bottom right of each page
	$htmldoc->set_html_content($proposal_msg);
	my $pdf = $htmldoc->generate_pdf();
	my $pdf_string = $pdf->to_string($pdf);
	my $pdf_result;
	eval { $pdf_result = $pdf->to_file($proposal_file) };

	my $static_pdf_path = cwd() . '/proposal_files/';
	my $static_pdf = $static_pdf_path . 'connect_static.pdf';

	# open a temp file and write the dynamic and static content to it
	PDF::Reuse::prFile("/nfs/www/pbxtra_proposal_downloads/temp$random_string.pdf");
	PDF::Reuse::prDoc($static_pdf);
	PDF::Reuse::prDoc('/nfs/www/' . $proposal_file);
	PDF::Reuse::prEnd();

	# overwrite the dynamic file with the femp file
	PDF::Reuse::prFile('/nfs/www/' . $proposal_file);
	PDF::Reuse::prDoc("/nfs/www/pbxtra_proposal_downloads/temp$random_string.pdf");
	PDF::Reuse::prEnd();

	# clean up
	unlink("/nfs/www/pbxtra_proposal_downloads/temp$random_string.pdf");

	#
	#	send the email with a link to the proposal
	#

	# create a new tt_obj because the main one has a pre_config and wrapper
	my $tt_email = Template->new({ POST_CHOMP => 1, TRIM => 1, PRE_CHOMP => 1, INCLUDE_PATH => "./$vars->{'TT_DIR'}" });
	$tt_email->process($email_template,$vars,\$email_msg) or $tt_email->error($error); 
	# replace with spaces and line breaks
	$email_msg =~ s/\&\#32\;/ /g;
	$email_msg =~ s/\&\#13\;/\n/g;
	# always add trailing carriage returns - multipart emails require them
	$email_msg .= "\n";
	# who to send the email to
	my $to = $vars->{'EMAIL'};
	# Felix Nilam - 10/08/2009
	# send proposal to reseller if specified
	if($vars->{'EMAIL_TO_RESELLER'} eq 'on')
	{
		if($vars->{'RESELLER_EMAIL'} ne '')
		{
			$to = $vars->{'RESELLER_EMAIL'};
			$vars->{'EMAIL'} = $vars->{'RESELLER_EMAIL'};
		}
	}
	
	my $from;
	if (defined $reseller_id)
	{
		$from = 'Fonality Reseller Proposal <resellers@fonality.com>';
	}
	else
	{
		$from = 'Fonality Proposal <sales@fonality.com>';
	}

	eval
	{
		my $sender = new Mail::Sender({ bypass_outlook_bug => 1 });
		$sender->OpenMultipart(
		{
			smtp    => 'localhost',
			to      => $to,
			subject => $subject,
			from    => $from,
		} );
		$sender->Body(
		{
			ctype => 'text/html',
			msg   => $email_msg,
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

	} or push(@{$vars->{MSG_ERROR}}, "Cannot send email.");
}


sub create_netsuite_opportunity
{
	my $q                 = shift(@_);
	my $vars              = shift(@_);
	my $dbh               = shift(@_);
	my $proposal_href     = shift(@_);
	my $reseller_id       = shift(@_);
	my $reseller_company  = shift(@_);
	my $intranet_sugar_id = shift(@_);
	my $reseller_state    = shift(@_);

	# specify values before creating the Opportunity's text content
	my $subject = $vars->{NAME} . "'s PBXtra Proposal #$vars->{PROPOSAL_ID}";
	my $script  = $ENV{'HTTP_HOST'} . $ENV{'SCRIPT_NAME'};
	my $total   = $vars->{'QUOTE_TOTAL'};

	# create a message for the new ticket
	my $content = "<br><p>$vars->{NAME} (<a href='mailto:$vars->{EMAIL}'>$vars->{EMAIL}</a>) has created a proposal in the amount of: \$$total</p>";
	$content   .= "Recall Quote Page: \n";
	
	$content   .= "https://$script?";
	$content   .= "src=$vars->{'TT_DIR'}&" if($vars->{'TT_DIR'});
	$content   .= "recall=$vars->{PROPOSAL_ID}&email=$vars->{EMAIL} \n<br>";
	
	$content   .= "Proposal (reference only, no Advertising ROI included!): \n";
	$content   .= "https://$ENV{'HTTP_HOST'}/pbxtra_proposal_downloads/p" . $proposal_href->{'random_proposal_string'} . ".pdf \n<br>";
	$content   .= "Place Order: \n";
	$content   .= "https://$ENV{'HTTP_HOST'}/q.cgi?";
	$content   .= "src=$vars->{'TT_DIR'}&" if($vars->{'TT_DIR'});
	$content   .= "convert=$vars->{PROPOSAL_ID}&eml=$vars->{EMAIL} \n<br>";
	
	$content   .= "Phone number is: $vars->{CUST_PHONE}<br>";
	$content   .= "Website: " . $vars->{'WEBSITE'} . " <br>";
	$content   .= "Industry: " . $vars->{'INDUSTRY'} . "<br>";
	$content   .= "Telecommuters? " . $vars->{'TELECOMMUTERS'} . "<br>";
	$content   .= "<br>Reseller: $reseller_company (ID #$reseller_id)" if($reseller_id);
	$content   .= "</p><pre>";
	if ($reseller_id)
	{
		$content .= "Description                                                Retail  Qty         Price    Sub Total<br>";
		$content .= "-----------------------------------------------------+-----------+----+-------------+------------<br>";
	}
	else
	{
		$content .= "Description                                                 Price  Qty    Sub Total<br>";
		$content .= "-----------------------------------------------------+-----------+----+------------<br>";
	}

	my $item_group_list = BackOffice::Order::kITEM_GROUP_LIST;
	foreach my $group (@$item_group_list)
	{
		foreach my $item (@{$proposal_href->{'items'}})
		{
			if ($item->{'group_name'} =~ /^$group$/i)
			{
				$content .= sprintf("%-53s",$item->{'name'});
				$content .= '| $' . sprintf("%9s",$item->{'price'});
				$content .= '|'   . sprintf("%4s",$item->{'quantity'});
				if ($reseller_id)
				{
					$content .= '| $' . sprintf("%11s",$item->{'reseller_price'});
					$content .= '| $' . sprintf("%10s",$item->{'reseller_subtotal'});
				}
				else
				{
					$content .= '| $' . sprintf("%10s",$item->{'subtotal'});
				}
				$content .= "<br>";
			}
		}
	}

	$content .= "<p>";
	if ($reseller_id)
	{
		$content .= "<br>                                     TOTAL RETAIL: \$ ";
		$content .= sprintf("%10s", $vars->{'RETAIL_TOTAL'});
		$content .= '<br>                                RESELLER DISCOUNT: $ ';
		$content .= sprintf("%10s", '-' . $vars->{'RESELLER_DISCOUNT'});
	}

	if ($proposal_href->{'deduction'} > 0)
	{
		$content .= "<br>          MANAGER'S DISCOUNT (expires " . $proposal_href->{'deduction_expire_date'} . "): \$ ";
		$content .= sprintf("%10s", '-'. F::Util::format_comma(sprintf("%.2f", $proposal_href->{'deduction'})));
	}

	if ($vars->{'PROMO_CODE'})
	{
		$content .= '<br>                             PROMOTIONAL DISCOUNT: $ ';
		$content .= sprintf("%10s", '-' . $vars->{'PROMO_CODE_DISCOUNT'});
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

	$content .= "<br>                                            TOTAL: \$ ";
	$content .= sprintf("%10s", $total);
	$content .= "</pre><br>";

	#
	#	display the asterisk comments
	#
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
	}
	if ($vars->{'SALES_TAX_ASTERISKS'} =~ /\*/)
	{
		$content .= '<br>' if ($other_stars);
		$content .= $vars->{'SALES_TAX_ASTERISKS'} . ' This is an estimate based on your state. ';
		$content .= 'This amount may vary slightly based on your exact tax jurisdiction and will be confirmed in your final invoice.';
		$other_stars = 1;
	}

	$content .= "</p>";
	$content = escapeHTML($content);

	# get the time the request was made
	my $current_min  = (localtime(time))[1];
	$current_min     =~ s/^(\d)$/0$1/;
	my $current_hour = (localtime(time))[2];
	$current_hour    =~ s/^(\d)$/0$1/;
	my $current_time = "$current_hour:$current_min";

	# save the PRODUCT name
	my $product_name = '';

	#
	#	create Opportunity in netsuite
	#


}


sub order_items_init
{
	my $q        = shift(@_);
	my $vars     = shift(@_);
	my $products = shift(@_);
	my $proposal_href;

	# initialize the bundles (items)
	BackOffice::Order::order_form_init($q,$vars,$products);

	# see if they are recalling a proposal or coming from wizard quote or building a new one
	my $proposal_id;
	if ($vars->{'RECALL'} || $vars->{'CUSTOM'})
	{
		# recall the proposal
		my $email = $vars->('EMAIL');
		
		if ($vars->{'CUSTOM'})
		{
			# sent from quote WIZARD, get saved quote data
		    $proposal_id = $vars->{'CUSTOM'};
#		    $proposal_href = BackOffice::Order::get_quote($dbh, $proposal_id);
		}
		else
		{
			# get RECALLED quote data
		    $proposal_id = $vars->{'RECALL'};
#		    $proposal_href = BackOffice::Order::get_quote_validated($dbh,$proposal_id,$email);
		    $vars->{'MODIFY'} = 1;
		}

		if ($proposal_href)
		{
		    if($vars->{'RECALL'})
		    {
				# happy message
				push (@{$vars->{MSG_COMPLETED}}, "Proposal #$proposal_id has been recalled.");
		    }

		    # put these items into a TT hash
		    $vars->{'PROPOSAL_ID'} = $proposal_id;
		    $vars->{'ORDER_ITEMS'} = $proposal_href->{'items'};
		    $vars->{'EMAIL'}       = $email;
		    $vars->{'SHIPPING_COUNTRY'} = $proposal_href->{'shipping_country'};
		    $vars->{'SHIPPING_STATE'}   = $proposal_href->{'shipping_state'};
		    $vars->{'SHIPPING_CITY'}    = $proposal_href->{'shipping_city'};
		    $vars->{'SHIPPING_ZIP'}     = $proposal_href->{'shipping_zip'};
		}
		else
		{
			push (@{$vars->{MSG_ERROR}}, "'$email' is the incorrect email address for Proposal #$proposal_id");
		}
	}

	return 1;
}


#############################################################################
#	this routine adds non-price info to each item in the proposal
#############################################################################
#sub add_item_details
#{
#	my $dbh            = shift(@_);
#	my $q              = shift(@_);
#	my $proposal_items = shift(@_);
#	
#	foreach my $proposal_item (@$proposal_items)
#	{
#		if ($proposal_item->{'group_name'} eq '')
#		{
#			# get group and name for each selected item
#			my $item_ref = BackOffice::Order::get_item($dbh, $proposal_item->{'item_id'});
#			$proposal_item->{'group_name'}   = $item_ref->{'group_name'};
#			$proposal_item->{'name'}         = $item_ref->{'name'};
#			$proposal_item->{'mnemonic'}     = $item_ref->{'mnemonic'};
#			$proposal_item->{'weight'}       = $item_ref->{'weight'};
#			$proposal_item->{'netsuite_id'}  = $item_ref->{'netsuite_id'};
#			$proposal_item->{'retail_price'} = $item_ref->{'retail_price'};
#		}
#	}
#}


#############################################################################
#	add a new entry in the quote_header table
#############################################################################
sub create_new_quote
{
	my $dbh            = shift(@_);
	my $q              = shift(@_);
	my $vars           = shift(@_);
	my $price_total    = shift(@_);
	my $reseller_id    = shift(@_);
	my $intranet_name  = shift(@_);
	my $request_cookie = shift(@_);
	my $referrer_site  = shift(@_);

	# get the referring site from a cookie
	my $referringsite        = F::Cookies::get_cookie_from_browser($q,$referrer_site) || '';
	my ($ref_date,$ref_site) = split(/\r/,$referringsite);

	# is this a reseller proposal?
	my $reseller_proposal = 0;
	if (defined $reseller_id)
	{
		$reseller_proposal = 1;
	}

	# If this is an intranet user creating the quote put that in the first_requesturl. We don't care about employees
	# browser cookies. -mstofko
	my $request_url = F::Cookies::get_cookie_from_browser($q,$request_cookie) || '';
	if ($intranet_name)
	{
		$request_url = "intranetcookie";
	}

	# create the quote_header
	my $proposal_id = add_quote($dbh,$price_total,$ref_site,$ref_date,$request_url,$reseller_proposal,$reseller_id) or push(@{$vars->{MSG_ERROR}}, "Cannot add quote.");

	return $proposal_id;
}


#
#	process the quote page items and contact info
#
sub add_quote_values
{
	my $q              = shift(@_);
	my $vars           = shift(@_);
	my $dbh            = shift(@_);
	my $intranet_name  = shift(@_);
	my $proposal_href  = shift(@_);
	my $reseller_id    = shift(@_);
	my $request_cookie = shift(@_);
	my $referrer_site  = shift(@_);
	my $products       = shift(@_);
	my $proposal_id    = $vars->{'proposal_id'};

	# get a dollar amount discount if one is present - very few salespeople have the can_deduct permission to do this
	my $deduct_amt = '';
	if ($vars->{'DOLLAR_AMT_DEDUCTION_ALLOWED'})
	{
		$deduct_amt = $vars->{'DOLLAR_AMT_DEDUCTION'} || 0;
		$deduct_amt =~ s/\..+$//;	# get rid of decimals and everything after them
		$deduct_amt =~ s/\D//g;		# get rid of non-digits
		$vars->{'DOLLAR_AMT_DEDUCTION'} = F::Util::format_comma(sprintf("%.2f", $deduct_amt));
		$vars->{'DOLLAR_AMT_EXPIRE'} = $vars->{'DOLLAR_AMT_EXPIRE'};
		$proposal_href->{'deduction'} = $deduct_amt;
		$proposal_href->{'deduction_expire_date'} = $vars->{'DOLLAR_AMT_EXPIRE'};

		# DOLLAR_AMT_EXPIRE must be properly formatted: YYYY-MM-DD
		if ($vars->{'DOLLAR_AMT_EXPIRE'} ne '' and $vars->{'DOLLAR_AMT_EXPIRE'} !~ /^\d{4}-\d\d-\d\d$/)
		{
			push (@{$vars->{MSG_ERROR}}, 'Deduction Expiration was improperly formatted: YYYY-MM-DD');
		}
	}
	else
	{
		# make sure deductions are not given to quotes generated by anyone unauthorized to give them
		# even if a deduction has previously been given to this quote
		# a customer should not be able to change the quote and still get the deduction
		$proposal_href->{'deduction'}             = '';
		$proposal_href->{'deduction_expire_date'} = '';
	}

	# name is required
	push (@{$vars->{MSG_ERROR}}, 'Name is required') unless($vars->{'NAME'} =~ /\w/);

	# make sure email address is not blank and is valid
	push (@{$vars->{MSG_ERROR}}, 'Invalid email address') unless F::Mail::check_email_address($vars->{'EMAIL'});

	# make sure the email address and the confimration email address are the same
	push (@{$vars->{MSG_ERROR}}, "Email addresses don't match") unless ($vars->{'EMAIL'} =~ /$vars->{'EMAIL_CONFIRM'}/i);

	# phone is required
	push (@{$vars->{MSG_ERROR}}, 'A valid phone number is required') unless($vars->{'PHONE'} =~ /^\D*1?\D*\d{3}\D*\d{3}\D*\d{4}.*$/);

	# get selected items
	my ($price_total,$item_qty_hash,$price_hash) = BackOffice::Order::get_invoice_totals($q,$vars,$products);


	my %item_hash          = undef;
	unless ($vars->{MSG_ERROR})
	{
		# remember these values for the asterisk notes below, etc.
		my $support_id         = undef;
		my $annual_support_ref = undef;
		my $retail_total       = 0;
		my $support_cnt        = 0;

		# reset the total because we'll add the price of server upgrades/defaults if a LIVE BACK-UP SERVER was selected
		$proposal_href->{'total'} = 0;

		foreach my $proposal_item (@{$proposal_href->{'items'}})
		{
			# resellers get extra retail fields
			if ($reseller_id)
			{
				# get the REGULAR PRICE from the get_item() results
				$proposal_item->{'price'} = F::Util::format_comma(sprintf("%.2f", $proposal_item->{'retail_price'}));
				$retail_total += $proposal_item->{'retail_price'} * $proposal_item->{'quantity'};
				# get the DISCOUNT PRICE from the quote_trans table
				$proposal_item->{'reseller_price'}    = F::Util::format_comma(sprintf("%.2f", $proposal_item->{'item_price'}));
				$proposal_item->{'reseller_subtotal'} = F::Util::format_comma(sprintf("%.2f", ($proposal_item->{'item_price'} * $proposal_item->{'quantity'})));
			}
			else
			{
				# GET PRICE FROM THE quote_trans TABLE
				$proposal_item->{'price'}    = F::Util::format_comma(sprintf("%.2f", $proposal_item->{'item_price'}));
				$proposal_item->{'subtotal'} = F::Util::format_comma(sprintf("%.2f", ($proposal_item->{'item_price'} * $proposal_item->{'quantity'})));
			}

			# save ANNUAL SUPPORT info
			if ($proposal_item->{'group_name'} eq 'Annual Support Group')
			{
				$support_id  = $proposal_item->{'item_id'};
				$support_cnt = $proposal_item->{'quantity'};
				$annual_support_ref = $proposal_item; # save this ref to operate on later - add an asterisk for notes below
			}

			# save the quantity to the ITEM HASH - we need it to figure phone & port counts
			$item_hash{$proposal_item->{'item_id'}} = $proposal_item->{'extension_qty'} || $proposal_item->{'quantity'};

			# re-tally the total
			$proposal_href->{'total'} += $proposal_item->{'item_price'} * $proposal_item->{'quantity'};
		}


		#
		# save these values for the support contract note if necessary
		#
		my $qty_phone_ports = get_qty_phone_ports($dbh,\%item_hash,BackOffice::Order::kPHONE_PORTS) or 0;
		if ($qty_phone_ports or $support_cnt)
		{
			$vars->{'SUPPORT_ID'} = $support_id;
			$vars->{'PORT_CNT'}   = $qty_phone_ports;
			$vars->{'PHONE_CNT'}  = $support_cnt - $qty_phone_ports;
		}
		else
		{
			$vars->{'PORT_CNT'} = $vars->{'PHONE_CNT'} = 0;
		}

		#
		#	figure out the asterisks - their count is dynamic
		#
		my $asterisks = '';

		# save these values for the note on SUPPORT CONTRACT NOTE
		if ($support_cnt)
		{
			$annual_support_ref->{'name'} =~ s/\s*\(.+\)\s*$//;	# strip the User Range from the Support Name
			$vars->{'SUPPORT_NAME_WITHOUT_STARS'} = $annual_support_ref->{'name'};
			$vars->{'SUPPORT_SELECTED'} = 1;
			if ($qty_phone_ports > 1)
			{
				$asterisks .= '*';
				$annual_support_ref->{'name'} .= $asterisks;	# add asterisk for footnote
				$vars->{'SUPPORT_STARS'}    = $asterisks;
				$vars->{'SHOW_SUPPORT_MSG'} = 1;
			}
			$vars->{'SUPPORT_NAME'} = $annual_support_ref->{'name'};
		}

		#
		#	deductions made by the Sales Director
		#
		my $quote_total = $proposal_href->{'total'};
		my $subtotal    = $proposal_href->{'total'};
		if ($proposal_href->{'deduction'} > 0)
		{
			$quote_total -= $proposal_href->{'deduction'};
			$subtotal    -= $proposal_href->{'deduction'};
		}

		#
		#	Promo Code - reseller discounts will be deducted in get_promo_code_discount()
		# 
		$vars->{'PROMO_CODE'} = 0;
		my $promo_discount = 0;
		if ($proposal_href->{'promo_code'} ne '')
		{
			$promo_discount = BackOffice::Order::get_promo_code_discount($dbh,$proposal_href,$reseller_id);
		}

		#
		# only give the larger of the 2 discounts
		#
		if ($promo_discount > 0)
		{
			$vars->{'PROMO_CODE_DISCOUNT'} = F::Util::format_comma(sprintf("%.2f", $promo_discount));
			$vars->{'PROMO_CODE'} = $proposal_href->{'promo_code'};
			$quote_total -= $promo_discount;
			$subtotal    -= $promo_discount;
		}

		#
		#	estimate Shipping & Sales Tax
		#
		my ($shipping_service) = $vars->{'SHIPPING_SERVICE'};
my $shipping_price = "";
print "";
		# parse the selected shipping service
		$shipping_service =~ s/^UPS_//;
		my @shipping_service = split(/_/, $shipping_service);
		my $parsed_shipping_service = 'UPS';
		foreach my $word (@shipping_service)
		{
			$word = lc($word);
			$word = ucfirst($word);
			$word = 'AM' if($word eq 'Am');
			$parsed_shipping_service .= ' ' . $word;
		}
		$vars->{'SHIPPING_SERVICE'} = $parsed_shipping_service;
		$vars->{'SHIPPING_COST'}    = F::Util::format_comma(sprintf("%.2f", $shipping_price));
		$quote_total += $shipping_price;
		# now the sales tax
		my $total_tax = 0;
		my $floating_sales_tax_percentage = BackOffice::Order::get_sales_tax($proposal_href->{'shipping_state'}, $proposal_href->{'shipping_zip'});
		if ($floating_sales_tax_percentage and !$reseller_id)
		{
			$total_tax = BackOffice::Order::get_pbxtra_taxable_amt($vars,$proposal_href) * $floating_sales_tax_percentage;
			$total_tax = sprintf("%.2f", $total_tax);   # round to the nearest penny
			$quote_total += $total_tax;
			$vars->{'SALES_TAX'}         = F::Util::format_comma(sprintf("%.2f", $total_tax));
			$vars->{'SALES_TAX_ENGLISH'} = $floating_sales_tax_percentage * 100;
			$vars->{'SHIPPING_STATE'}    = $proposal_href->{'shipping_state'};
			# save these values for the note on estimated sales tax
			$asterisks .= '*';
			$vars->{'SALES_TAX_ASTERISKS'} = $asterisks;
		}

		# update the shipping & tax estimates
		# also save the total - a LIVE BACKUP SERVER may have changed it
		# update the quote_header record with the name and email (for future sales solicitation use)
		update_quote_header($dbh,	{
										quote_id              => $proposal_id,
										name                  => $vars->{'NAME'}                || '',
										email                 => $vars->{'EMAIL'}               || '',
										phone                 => $vars->{'PHONE'}               || '',
										website               => $vars->{'WEBSITE'}             || '',
										industry              => $vars->{'INDUSTRY'}            || '',
										deduction             => $deduct_amt                    || '',
										deduction_expire_date => $vars->{'DOLLAR_AMT_EXPIRE'}   || '',
										reseller              => $vars->{'RESELLER_PROPOSAL'} || '',
										shipping_cost         => $shipping_price,
										shipping_service      => $shipping_service,
										total                 => $proposal_href->{'total'}
									}
		) or push(@{$vars->{MSG_ERROR}}, "Cannot update quote.");

		$vars->{'QUOTE_TOTAL'}       = F::Util::format_comma(sprintf("%.2f", $quote_total));
		$vars->{'SUBTOTAL'}          = F::Util::format_comma(sprintf("%.2f", $subtotal));
		$vars->{'ORDER_ITEMS'}       = $proposal_href->{'items'}; 
		$vars->{'RETAIL_TOTAL'}      = F::Util::format_comma(sprintf("%.2f", $retail_total));
		$vars->{'RESELLER_DISCOUNT'} = F::Util::format_comma(sprintf("%.2f", ($retail_total - $proposal_href->{'total'})));
		$vars->{'PROPOSAL_ID'}       = $proposal_id;
	}


	# if we have an existing proposal, don't create new proposal_id, and remove existing quote_trans db entries
	if ($vars->{'EXISTING_PROPOSAL'})
	{
		# update the existing quote_header with the new $price_total
		$proposal_id = $vars->{'EXISTING_PROPOSAL'};
		update_quote_header($dbh,{quote_id => $proposal_id, total => $price_total}) or push(@{$vars->{MSG_ERROR}}, "Cannot update the quote.");

		## remove all items from quote_trans
		remove_item_from_quote($dbh,$proposal_id);
	}
	else
	{
		# create the quote_header
		$proposal_id = create_new_quote($dbh,$q,$vars,$price_total,$reseller_id,$intranet_name,$request_cookie,$referrer_site);
	}

	# create the quote_trans
	while ( my ($item_id, $quantity) = each(%item_hash) )
	{
		next if ($item_id !~ /\d/);
		BackOffice::Order::add_item_to_quote($dbh,$proposal_id,$item_id,$quantity,$price_hash->{$item_id});
	}

	#
	#	Promo Code
	# 
	my $promo_code = $vars->{'PROMO_CODE'};
	my $proposal_href = get_quote($dbh,$proposal_id) or push(@{$vars->{MSG_ERROR}}, "Cannot get quote.");
	if ($promo_code ne '')
	{
		$promo_code = uc($promo_code);
		$promo_code =~ s/^\s+|\s+$//g; # remove leading/trailing white space
		$proposal_href->{'promo_code'} = $promo_code;
		my $promo_discount = BackOffice::Order::get_promo_code_discount($dbh,$proposal_href,$reseller_id,$vars);
		if ($promo_discount == -1)
		{
			# customer entered a Promo Code but it was rejected
			push (@{$vars->{MSG_ERROR}}, "<font color='red'>Invalid Promotional Code</font>");
		}
		elsif ($promo_discount == 0)
		{
			# customer entered a Promo Code but it was rejected
			push (@{$vars->{MSG_ERROR}}, "<font color='red'>Your proposal has not met the Promotional requirements.</font>");
		}
		else
		{
			# save the Promo Code to the quote_header table
			update_quote_header($dbh,{quote_id => $proposal_id, promo_code => $promo_code}) or push(@{$vars->{MSG_ERROR}}, "Cannot add promotion.");
		}
	} 
	else
	{
		# save a NULL promo_code - no Promo Code entered
		update_quote_header($dbh,{quote_id => $proposal_id, promo_code => ''});
	}


	#
	#   Estimate shipping and tax
	#
	$proposal_href->{'shipping_zip'}     = $q->param('shipping_zip');
	$proposal_href->{'shipping_country'} = $q->param('shipping_country');
	$proposal_href->{'shipping_state'}   = $q->param($proposal_href->{'shipping_country'} eq 'United States' ? 'shipping_state' : 'shipping_province');
	$proposal_href->{'shipping_city'}    = $q->param('shipping_city');
	my $shipping_error = 0;
	if ($proposal_href->{'shipping_country'} eq "United States" and $proposal_href->{'shipping_state'} eq '')
	{
		push @{$vars->{MSG_ERROR}}, "State is required if shipping in the US.";
		$shipping_error = 1;
	}
	if ($proposal_href->{'shipping_country'} eq '')
	{
		push @{$vars->{MSG_ERROR}}, "Shipping country is required.";
		$shipping_error = 1;
	}
	if ($proposal_href->{'shipping_city'} eq '')
	{
		push @{$vars->{MSG_ERROR}}, "Shipping city is required.";
		$shipping_error = 1;
	}
	if ($proposal_href->{'shipping_zip'} eq '')
	{
		push @{$vars->{MSG_ERROR}}, "Shipping zipcode is required.";
		$shipping_error = 1;
	}
	unless ($shipping_error)
	{
		update_quote_header($dbh,{
									quote_id         => $proposal_id,
									shipping_zip     => $proposal_href->{'shipping_zip'},
									shipping_country => $proposal_href->{'shipping_country'},
									shipping_state   => $proposal_href->{'shipping_state'},
									shipping_city    => $proposal_href->{'shipping_city'}
							 	}
		) or push(@{$vars->{MSG_ERROR}}, "Cannot update shipping.");
		# get shipping services available and rates - results are stored in $vars
		BackOffice::Order::get_pbxtra_shipping($dbh,$q,$vars,$proposal_href,$reseller_id,"quote");
	}

	# if a recalled proposal has been ordered, insert it into the orders tables
	if($q->param('go_to_order'))
	{
		$proposal_id = $vars->{'EXISTING_PROPOSAL'} or push(@{$vars->{MSG_ERROR}}, "No proposal ID supplied");
		my $email = $vars->{'EML'} or push(@{$vars->{MSG_ERROR}}, "No email supplied");
		$proposal_href = BackOffice::Order::get_quote_validated($dbh,$proposal_id,$email)
			or push(@{$vars->{MSG_ERROR}}, "Error getting proposal from database");
		my $order_id   = BackOffice::Order::convert_quote_to_order($dbh,$proposal_href,$vars);

		if ($vars->{MSG_ERROR})
		{
			# the return results will process the error msg
			return $vars;
		}
		else
		{
			# redirect to the o.cgi Order script
			if ($q->param('src'))
			{
				print "Location: o.cgi?oid=$order_id&src=". $q->param('src') ."\n\n";
			}
			else
			{
				print "Location: o.cgi?oid=$order_id\n\n";
			}
			exit;
		}
	}
	else
	{
		$vars->{'NAME'}  = $proposal_href->{'name'};
		$vars->{'PHONE'} = $proposal_href->{'cust_phone'};
		$vars->{'EMAIL'} = $proposal_href->{'email'};
		$vars->{'TOTAL'} = F::Util::format_comma(sprintf("%.2f", $proposal_href->{'total'}));

		$vars->{'EMAIL_CONFIRM'} = $proposal_href->{'email'};
		$vars->{'WEBSITE'} = $proposal_href->{'website'};
		$vars->{'INDUSTRY'} = $proposal_href->{'industry'};
		$vars->{'TELECOMMUTERS'} = $proposal_href->{'telecommuters'};
		$vars->{'BRANCH_OFFICES'} = $proposal_href->{'branch_offices'};
		$vars->{'DOLLAR_AMT_DEDUCTION'} = $proposal_href->{'deduction'} unless ($proposal_href->{'deduction'} eq '0');
		if ($proposal_href->{'deduction_expire_date'} ne '' and $proposal_href->{'deduction_expire_date'} ne '0000-00-00')
		{
			$vars->{'DOLLAR_AMT_EXPIRE'} = $proposal_href->{'deduction_expire_date'};
		}

		return $vars;
	}
}


#############################################################################
# get_cookie: gets the fonality.com cookie from the browser, the using the value
# of that cookie, gets the corresponding row from the cookies table
#
#    Args: CGIobj,[cookie_value]
# Returns: CGIobj ($q) updated with values such as $q->param('sid')
#############################################################################
#sub get_cookie
#{
#	my $q            = shift;
#	my $cookie_name  = shift;
#	my $cookie_value = F::Cookies::get_cookie_from_browser($q,$cookie_name);
#	
# get rest of cookie info from db
#my $cookie_href = get_cookie_from_db($dbh, $cookie_value, 'cookies_reseller');
#	
#	#return ($cookie_href);
#	return ($cookie_value);
#}


#############################################################################
# USER ERROR!
# form_repop: if MSG_ERROR then re-populate $vars with data from $q->param
#    Args: CGIobj, Template Toolkit "$vars" reference
# Returns: $vars
#############################################################################
#sub form_repop
#{
#	my $q    = shift(@_);
#	my $vars = shift(@_);
#	if ($vars->{'MSG_ERROR'})
#	{
#		foreach ($q->param())
#		{
#			$vars->{$_} = $q->param($_);
#			# also save UPPER case version of the values
#			my $key = uc($_);
#			$vars->{$key} = $q->param($_);
#		}
#	}
#	return $vars;
#}


#############################################################################
# err: Check the return value for an error and display it with a backtrace
#     if there is an error condition.
#
#    Args: scalar_reference[,optional_error_text]
# Returns: same reference | dies on error
#############################################################################
#sub err {
#	my($q) = shift(@_);
#	my($ref) = shift(@_);
#	my($error) = shift(@_);
#	return unless $@;
#	return($ref) if(defined($ref));
#	unless(defined($error)) {
#		$error = 'A system error occurred';
#	}
#	show_error($q, '[BE]: ' . $@); 
#	#confess("$error: " . $@); # Supply a backtrace upon error
#	#die "System Error: $@";   # This code should never run
#}



