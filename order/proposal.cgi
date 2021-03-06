#!/usr/bin/perl
#
#	this program is used to get referral cookie data from customers requesting proposals
#	if we haven't already gotten their referral data, we do it now then redirect them
#	to a proposal generated by q.cgi.
#

use strict;
use lib '/html/pbxtra';
use Apache::Request();
#use Data::Dumper;
use F::Database;
use F::Order;
use F::Cookies;
use Apache::Cookie();
use Template ();
use Cwd;
eval('use CGI::Carp qw(fatalsToBrowser);');

{
# GLOBAL VARIABLES
my $referrer_site  = 'referringsite';
my $request_cookie = 'requesturl';
my $referral_site  = undef;


&main;
exit;


sub main
{ 
	my $q   = new Apache::Request(@_, DISABLE_UPLOADS => 0, POST_MAX => (10 * (1024 * 1024))); 
	my $dbh = mysql_connect() or die "Unable to connect to database; $!"; # Connect to the db

	# the template toolkit object will only be used if there is an error
	my $tt_object = Template->new({
		EVAL_PERL => 1,
		PRE_PROCESS  => 'config.tt',
		WRAPPER => 'pbxtra/wrapper_order.tt',
		INCLUDE_PATH => '.', PRE_CHOMP => 1, TRIM => 1, POST_CHOMP => 1
	});
	my $vars = {};

	# get the input values
	my $proposal_id = $q->param('pid') or push(@{$vars->{MSG_ERROR}}, "No proposal ID supplied");
	my $email    = $q->param('eml') or push(@{$vars->{MSG_ERROR}}, "No email supplied");
	my $error = 0;
	if ($vars->{MSG_ERROR})
	{
		$error = 1;
	}

	# verify the proposal ID and email match
	my $proposal_href = get_quote_validated($dbh,$proposal_id,$email) unless($error);
	if (defined $proposal_href and !$error)
	{
		# proposal request verified!

		# get the referring site from a cookie
		my $request_url          = get_cookie($q,$request_cookie) or '';
		my $referringsite        = get_cookie($q,$referrer_site)  or '';
		my ($ref_date,$ref_site) = split(/\r/,$referringsite);

		# get referral cookie data if there isn't already any
		# changed to compare lengths of requesturl too. -mstofko
		if ($proposal_href->{'referral_site'} eq '' or $proposal_href->{'referral_date'} eq '' or (length($request_url) > length($proposal_href->{'first_requesturl'}) and $request_url !~ /\.cgi/i))
		{
			update_quote_header($dbh,	{
											quote_id         => $proposal_id,
											referral_site    => $ref_site,
											referral_date    => $ref_date,
											first_requesturl => $request_url
										}
			) or err($q);
		}

		# redirect to the o.cgi Order script
		print "Location: pbxtra_proposal_downloads/p" . $proposal_href->{'random_proposal_string'} . ".pdf?t=".localtime()."\n\n";
	}
	else
	{
		# proposal request failed!
		push (@{$vars->{MSG_ERROR}}, "Error getting proposal ID #$proposal_id for email address '$email'");
		show_template($q,$vars,'pbxtra/order_email_quote_error.tt',undef,$tt_object);
	}
}
	

#############################################################################
# get_cookie: gets the fonality.com cookie from the browser, then uses the value
# of that cookie to get the corresponding row from the cookies table
#
#    Args: CGIobj,[cookie_value]
# Returns: CGIobj ($q) updated with values such as $q->param('sid')
#############################################################################
sub get_cookie
{
	my $q            = shift(@_);
	my $cookie_name  = shift(@_) or err($q);
	my $cookie_value = F::Cookies::get_cookie_from_browser($q,$cookie_name);

	# get rest of cookie info from db
	#my $cookie_href = get_cookie_from_db($dbh, $cookie_value, 'cookies_reseller');

	#return ($cookie_href);
	return ($cookie_value);
}


#############################################################################
# err: Check the return value for an error and display it with a backtrace
#     if there is an error condition.
#
#    Args: apache_object,scalar_reference[,optional_error_text]
# Returns: same reference | dies on error
#############################################################################
sub err {
	my $q     = shift(@_);
	my $ref   = shift(@_);
	my $error = shift(@_);

	return unless $@;
	return($ref) if(defined($ref));

	unless (defined $error)
	{
		$error = 'A system error occurred';
	}

	show_error($q, '[BE]: ' . $@);
	#confess("$error: " . $@); # Supply a backtrace upon error
	#die "System Error: $@";   # This code should never run
}



}
