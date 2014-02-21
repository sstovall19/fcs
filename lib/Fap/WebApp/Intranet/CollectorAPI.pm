#!/usr/bin/perl

package Fap::WebApp::Intranet::CollectorAPI;

use strict;
use base 'Fap::WebApp::Intranet';

use vars qw($VERSION @EXPORT);
use base 'Fap::WebApp::Intranet';

# Fap namespace modules
use Fap;
use Fap::Global;

# 3rd party modules
use LWP::UserAgent;
use Try::Tiny;

$VERSION = '1.00';

require Exporter;

@EXPORT = qw(
	collector_api_get
	collector_api_post
);

sub import
{
	goto &Exporter::import;
}


=head2 collector_api_post

=over 4

	POST data to the collector.

	Args   : $uri, $post_data_hashref
	Returns: $decoded_json_data

=back

=cut
sub collector_api_post
{
	my($self, $uri, $post_data) = @_;

	# Define api vars
	my($url, $api_user, $api_key);

	# Clean up URI ( no duplicate slashes )
	$uri =~ s/\/{2,}/\//g;
	$uri =~ s/^\/+//;

	# Create LWP 
	$self->{API_UA} ||= LWP::UserAgent->new;
	$self->{API_UA}->agent("FCSQuote/0.1");

	# If we have config availble, try to load the api info from the database
	if($self->can('config'))
	{
		$url = $self->config('Collector.API_BASE');
		$api_user = $self->config('Collector.API_USER');
		$api_key = $self->config('Collector.API_KEY');
	}

	# Fall back to globals
	$url ||= Fap::Global::kCOLLECTOR_API_BASE;
	$url .= '/' . $uri; 

	$api_user ||= Fap::Global::kCOLLECTOR_API_USER;
	$api_key ||= Fap::Global::kCOLLECTOR_API_KEY;


	# Make sure we have a hashref for postdata
	$post_data ||= {};
	$post_data->{'user'} = $api_user || Fap::Global::kCOLLECTOR_API_USER;
	$post_data->{'api_key'} = $api_key || Fap::Global::kCOLLECTOR_API_KEY;

	$self->write_log(level => 'DEBUG', log => [ "POSTing to $url", $post_data]);
	# Send the POST request
        my $response = $self->{API_UA}->post($url, $post_data);

	# Check for a valid response
	if ($response->is_success)
	{
		try {
			my $res = $self->json_decode($response->decoded_content);
			$self->write_log(level => 'VERBOSE', log => "API POST response received successfully");
			$self->write_log(level => 'DEBUG', log => $res);
			return $res;
		}
		catch
		{
			$self->write_log(level => 'ERROR', log => "Failed to decode JSON $!");
			return undef;
		}
	}
	else
	{
		$self->write_log(level => 'ERROR', log => $response->message) if $self->can('write_log');
		return undef;
	}

}

=head2 collector_api_get

=over 4

	GET data from the collector

	Args   : URI
	Returns: decoded_json_result

=back

=cut
sub collector_api_get
{
	my $self = shift;
	my $uri = shift;
	$uri =~ s/\/{2,}/\//g;
	$uri =~ s/^\/+//;

	my($url, $api_user, $api_key);

	if($self->can('config'))
	{
		$url = $self->config('Collector.API_BASE');
		$api_user = $self->config('Collector.API_USER');
		$api_key = $self->config('Collector.API_KEY');
	}

	$url ||= Fap::Global::kCOLLECTOR_API_BASE;
	$api_user ||= Fap::Global::kCOLLECTOR_API_USER;
	$api_key ||= Fap::Global::kCOLLECTOR_API_KEY;

	print Fap::Global::kCOLLECTOR_API_BASE, "\n";
	$url .= '/' . $uri . "?user=".$api_user."&api_key=".$api_key;

	$self->{API_UA} ||= LWP::UserAgent->new;
	$self->{API_UA}->agent("FCSQuote/0.1");
	my $req = HTTP::Request->new(GET => $url);
	$req->header(Accept => "application/json, */*;q=0.1");

	my $data;
	my $try = 0;

	# Try a max of 3 times to GET the data - mostly for dev environment weirdness
	while(!$data && $try < 3)
	{
		try {
			my $res = $self->{API_UA}->request($req);
			$data = $self->json_decode($res->content);
		}
		catch
		{
			$self->write_log(level => 'ERROR', log => "API request failed ( TRY: $try ) $@ $!") if $self->can('write_log');
			$try++;
		}
	}


	return $data;
}


1;
