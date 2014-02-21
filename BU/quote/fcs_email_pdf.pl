#!/usr/bin/perl

use strict;
use Cwd;
use Fap::StateMachine::Unit;
use MIME::Entity;
use HTML::HTMLDoc;
use PDF::Reuse;
use Getopt::Std;
use Fap::Order;
use Fap;
use Try::Tiny;
use Fap::View::TT;
use Fap::Net::Email;
use Fap::Model::Fcs();
use LWP::Simple;

my $client = Fap::StateMachine::Unit->new->run();

sub execute
{
	my ($package, $client, $q) = @_;

	my $db = Fap::Model::Fcs->new();
	my $order = Fap::Order->get(db=>$db,id=>$q->{order_id});
	if (!$order) {
		 $client->displayfailure("Invalid Order ID");
	}
	my $salesrep = $db->table("NetsuiteSalesperson")->single({netsuite_id=>$order->netsuite_salesperson_id});
	if (!$salesrep) {
		#$client->displayfailure("Invalid Sales Rep");
		$salesrep = $db->table("NetsuiteSalesperson")->single({salesperson_id=>840});
        }

	my $vars = {
		SALES_PERSON_NAME=>$salesrep->first_name . ' ' . $salesrep->last_name,
		SALES_PERSON_PHONE=>$salesrep->phone,
		SALES_PERSON_EMAIL=>$salesrep->email,
		DISCOUNT_PERCENT=>0,#,$order->discount_percent * 100,
		NAME=>join(" ",$order->contact->first_name,$order->contact->last_name),
		COMPANY=>$order->company_name,
		PHONE=>$order->contact->phone,
		EMAIL=>$order->contact->email,
		PROPOSAL_ID=>$order->order_id,
		random_string=>return_random_string(20),
		TERM_MONTHS=>$order->term_in_months,
		ONE_TIME_TOTAL=>format_comma($order->one_time_total),
		USERS=>0,
		conf=>Fap->load_conf("bu/email_pdf"),
		quoteconf=>Fap->load_conf("quote"),
	};
	my $groupcount=0;
	foreach my $group ($order->order_groups) {
		$groupcount++;
		my $total_lease=0;
		my $total_purchase=0;
		my $items = [];
		my $users;
		my ($users_bundle) = grep {$_->bundle_id=~/^81|83$/} $group->order_bundles;
		if ($users_bundle) {
			$vars->{USERS}+= $users_bundle->quantity;
		}
		foreach my $bundle ($group->order_bundles) {
			my $subtotal_lease="N/A";
			my $subtotal_purchase="N/A";
			my $price = 0;

			if ($bundle->is_rented) {
				$subtotal_lease = $bundle->discounted_price;#*$bundle->quantity;
				$price = $bundle->bundle->mrc_price;
			} else {
				$subtotal_purchase = $bundle->discounted_price;#*$bundle->quantity;
				$price = $bundle->bundle->base_price;
			}

			my $ref = {
				name=>substr($bundle->bundle->display_name,0,35),
				unit_price=>format_comma($bundle->discounted_price/$bundle->quantity),
				subtotal_purchase=> format_comma($subtotal_purchase),
				subtotal_lease=> format_comma($subtotal_lease),
				quantity=>$bundle->quantity,
			};

			$total_lease+=$subtotal_lease;
			$total_purchase+=$subtotal_purchase;
			push(@$items,$ref);
		}

		##REFACTOR##

		my $total_discount_lease = 0; # ($order->discount_percent * $total_lease);
		my $total_discount_purchase = 0; # ($order->discount_percent * $total_purchase);
	
		my $total_cost = $group->one_time_total+($group->mrc_total*($order->term_in_months-1));
		##/REFACTOR##
		my $order_group_info = {
			TOTAL_PRORATE_PURCHASE=>'0.00',
			TOTAL_DISCOUNT_LEASE=>format_comma($total_discount_lease),
			TOTAL_DISCOUNT_PURCHASE=>format_comma($total_discount_purchase),
			TOTAL_SALES_TAX_OT=>format_comma($group->one_time_tax_total),
			TOTAL_SALES_TAX_MRC=>format_comma($group->mrc_tax_total),
			LEASE_TOTAL_BEFORE_SHIPPING=>format_comma($total_lease-$total_discount_lease),
			PURCHASE_TOTAL_BEFORE_SHIPPING=>format_comma($group->one_time_tax_total+$total_purchase-$total_discount_purchase),
			SHIPPING_ADDR=>substr(join(" ",$group->shipping_address->addr1,$group->shipping_address->addr2,$group->shipping_address->city,$group->shipping_address->state_prov,$group->shipping_address->postal,$group->shipping_address->country),0,100),
			SHIPPING=>[],
			ORDER_ITEMS=>$items,
		};
               	foreach my $shippings ($group->order_shippings) {
			push(@{$order_group_info->{SHIPPING}},{
				text=>$shippings->shipping_text,
				rate=>$shippings->shipping_rate
			});
                }
		if (!scalar(@{$order_group_info->{SHIPPING}})) {
			$order_group_info->{SHIPPING} = [{
				text=>"No shipping",
				rate=>"0.00",
			}];
		}
		$vars->{ITEMS}->{$groupcount} = $order_group_info;
	}
	$vars->{TOTAL_COST_OWNERSHIP} =  $order->one_time_total+($order->mrc_total*($order->term_in_months));
	$vars->{AVERAGE_COST_PER_USER} = format_comma(($vars->{TOTAL_COST_OWNERSHIP}/$vars->{USERS})/$order->term_in_months-1);
	$vars->{TOTAL_COST_OWNERSHIP}=format_comma($vars->{TOTAL_COST_OWNERSHIP});
	$vars->{TOTAL_MONTHLY_COST} = format_comma($order->mrc_total);
	use Data::Dumper;
	print STDERR Dumper($vars);
	email_quote($vars,$client);
	return $q;
}

sub set_random_pdf_name
{
	my $q = shift(@_);
	my $random_string = $q->{'random_proposal_string'};

	if ($random_string !~ /\w/)
	{
		$random_string = return_random_string(20);
		$q->{'random_proposal_string'} = $random_string;
	}
}


sub email_quote
{
	my ($email_msg, $proposal_msg, $error, $htmlmsg,$client);
	my ($vars,$client) = @_;

	# specify the subject
	my $subject = $vars->{'NAME'} . "'s PBXtra Proposal #$vars->{PROPOSAL_ID}";
	my $conf = $vars->{conf};
	$vars->{THE_SERVER_NAME} = $conf->{download_url};
	$vars->{PROPOSAL_DIR} = $conf->{proposal_dir};
	$vars->{PROPOSAL_FILE} = "p$vars->{random_string}.pdf";
	$vars->{ORDER_URL} = $vars->{quoteconf}->{order_url};
	my $assets_path = Fap->path_to($conf->{assets_dir});
	my $proposal_file = Fap->path_to("$conf->{output_dir}/p$vars->{random_string}.pdf");

	# create a new tt_obj because the main one has a pre_config and wrapper

	my $tt = Fap::View::TT->new(paths=>[$conf->{assets_dir}]);

	$proposal_msg = $tt->process($conf->{proposal_template},$vars);

	#	create the proposal - a .pdf file to be downloaded by the customer
	my $htmldoc = new HTML::HTMLDoc();
	$htmldoc->path($assets_path);
	$htmldoc->set_bodyfont('Arial');
	$htmldoc->set_fontsize('8');
	$htmldoc->set_page_size('letter');
	$htmldoc->set_bottom_margin(5,'mm');
	$htmldoc->set_top_margin(0,'mm');
	$htmldoc->set_footer('.','.','.');
	$htmldoc->set_html_content($proposal_msg);
	my $pdf = $htmldoc->generate_pdf();
	my $pdf_string = $pdf->to_string($pdf);
	my $pdf_result;

	$pdf_result = $pdf->to_file($proposal_file);

	# open a temp file and write the dynamic and static content to it
	PDF::Reuse::prFile(Fap->path_to("$conf->{output_dir}/temp$vars->{random_string}.pdf"));
	PDF::Reuse::prDoc("$assets_path/$vars->{conf}->{pdf_include}");
	PDF::Reuse::prDoc($proposal_file);
	PDF::Reuse::prEnd();

	# overwrite the dynamic file with the femp file
	PDF::Reuse::prFile($proposal_file) || $client->displayfailure ("Couldn't create PDF file: $!");
	PDF::Reuse::prDoc(Fap->path_to("$conf->{output_dir}/temp$vars->{random_string}.pdf"));
	PDF::Reuse::prEnd();

	# clean up
	unlink(Fap->path_to("$conf->{output_dir}/temp$vars->{random_string}.pdf"));

        # some sanity checks
	if (! -e $proposal_file) {
		$client->displayfailure("Couldn't create PDF file $proposal_file");
	}

	my $proposal_url = $vars->{THE_SERVER_NAME}."/".$vars->{PROPOSAL_DIR}."/".$vars->{PROPOSAL_FILE};
        if (! head($proposal_url)) {
		$client->displayfailure("Unable to retrieve PDF at $proposal_url");
	}

	#
	#	send the email with a link to the proposal
	#

        if (! Fap::Net::Email->send_template(('type'=>'html','template'=>$conf->{email_template},
                                              'vars'=>$vars,'from'=>'Fonality Proposal <sales@fonality.com>','to'=>$vars->{'EMAIL'},
                                              'subject'=>$subject)))
            { $client->displayfailure("Could not email."); }

	save_proposal($vars->{PROPOSAL_ID}, $proposal_url);
}

sub rollback
{
	my ($package, $client, $input) = @_;
	$input->{output} = {rollback=>"success"};
	return $input;
}

sub format_comma 
{
	my ($price) = shift;
	return($price) if ($price eq 'N/A');
	my $ni = sprintf("%0.2f",$price);
	my $delimiter = ','; # replace comma if desired
	my($n,$d) = split /\./,$ni,2;
	my @a = ();
	while($n =~ /\d\d\d\d/)
	{
		$n =~ s/(\d\d\d)$//;
		unshift @a,$1;
	}
	unshift @a,$n;
	$n = join $delimiter,@a;
	$n = "$n\.$d" if $d =~ /\d/;
	return "\$". $n;
}

sub return_random_string
{
	my $length = shift(@_) || 10;
	my @chars = qw(2 3 4 5 6 7 8 9 A B C D E F G H J K L M N P
			Q R S T U V W X Y Z a b c d e f g h i j k
			m n o p q r s t u v w x y z _);
	srand();
	my $rand_string = '';
	# Pick a random character from our array, and append it
	$rand_string .= $chars[int rand @chars] while length($rand_string) < $length;
	return($rand_string);
}

sub save_proposal
{
	my ($order_id) = shift;
	my ($url) = shift;

	my $db = Fap::Model::Fcs->new;
	my $order = $db->table("Order")->search( { "me.order_id" => $order_id } )->first;
	$order->set_columns( { proposal_pdf => $url } );
	$order->update();
}
