#!/usr/bin/perl
# Start of documentation header 
 
=head1 NAME 
 
CGI::Application::Plugin::FONSearch
 
=head1 VERSION 
 
$Id: Search.pm 1692 2013-02-18 23:11:57Z jweitz $ 
 
=head1 SYNOPSIS 
 
use CGI::Application::Plugin::FONSearch

=head1 DESCRIPTION 

	Contains Intranet search features including searchable application listing and modification.
 
=head1 EXAMPLES 
 
=over 4 
 
	See examples in class methods.

=back 

=head1 CLASS METHODS

=over 4

Method usage.

=back

=cut
package Fap::WebApp::Intranet::Search;

use strict;
use vars qw($VERSION @EXPORT);
use base 'Fap::WebApp::Intranet';

$VERSION = '1.00';

require Exporter;

@EXPORT = qw(
	get_searchable_applications
	add_searchable_application
	remove_searchable_application
);

sub import { goto &Exporter::import }

=head2 get_searchable_applications

=over 4

	Retrieve a list of searchable applications and their parameters.

	Args   : none
	Returns: listref of hashes containing searchable application params

=back

=cut

sub get_searchable_applications
{
	my $self = shift;

	my @res = $self->db->table('intranet_searchable')->all;
	my @res = $self->db->strip(@res) if @res;

	return \@res;
}

=head2 add_searchable_application

=over 4

	Add or update a searchable application to the framework.

	Args   : $application_mode, $format_regex, $action_param, $query_param
	Returns: true on success or false on failure

=back

=cut
sub add_searchable_application
{
	my $self = shift;
	my ($mode, $format, $action, $param) = @_;

	if(!$mode)
	{
		$@ = "Mode is required";
		return undef;
	}

	if(!$format)
	{
		$@ = "Format is required";
		return undef;
	}

	$action ||= 'searchable';
	$param ||= 'query';

	my $res = $self->db->table('intranet_searchable')->find_or_create({ 'mode' => $mode, 'format' => $format, 'action' => $action, 'param' => $param });

	if($res)
	{
		return 1;
	}
	else
	{
		return undef
	}
}

=head2 remove_searchable_application

=over 4

	Remove a searchable application from the framework

	Args   : $application_mode
	Returns: true on success or undef on failure

=back

=cut
sub remove_searchable_application
{
	my $self = shift;
	my $app = shift;

	if(!$app)
	{
		$@ = "No application provided";
		return undef;
	}

	if(my $app = $self->db->table('intranet_searchable')->find({ 'mode' => $app }))
	{
		$app->delete();
		return 1;
	}
	else
	{
		return undef;
	}
}

1;
