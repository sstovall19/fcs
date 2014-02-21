#!/usr/bin/perl
# Start of documentation header 
 
=head1 NAME 
 
CGI::Application::Plugin::FONConfig
 
=head1 VERSION 
 
$Id: Config.pm 2378 2013-03-21 21:59:33Z jweitz $ 
 
=head1 SYNOPSIS 
 
use CGI::Application::Plugin::FONConfig

=head1 DESCRIPTION 

	Handles retrieving, setting and changing framework configuration settings found in the database
 
=head1 EXAMPLES 
 
=over 4 
 
	See examples in class methods.

=back 

=head1 CLASS METHODS

=over 4

Method usage.

=back

=cut
package Fap::WebApp::Intranet::Config;

use strict;
use vars qw($VERSION @EXPORT);
use base 'Fap::WebApp::Intranet';

$VERSION = '1.00';

require Exporter;

@EXPORT = qw(
	config
	remove_config
	config_keys
	get_all_settings
);

sub import { goto &Exporter::import }

=head2 config

=over 4

	Get or set a configuration file from the database.

	Args   : setting_name [, setting_value ]
	Returns: value of setting_name or undef on error

	Examples:

		$self->config('log.ERROR'); # Get the setting for log.ERROR

		$self->config('log.ERROR', 1); # Set the value of log.ERROR to 1

=back

=cut
sub config
{
	my $self = shift;
	my ($param, $value) = @_;

	if(not defined($param))
	{
		return undef;
	}

	# Clean param
	#$param = $self->validate($param);
	my $ret;

	if(defined($value))
	{
		$self->write_log(level => 'VERBOSE', log => "Going to update configuration setting: $param=$value");
		if(&_set_config($self, $param, $value))
		{
			$self->db->cache->set("intranet_setting.$param",$value,600);
			return 1;
		}
		else
		{
			return undef;
		}
	} else {
		$ret = $self->db->cache->get("intranet_setting.$param");
		if ($ret) {
				return $ret;
		}
	} 

	# If we've already stored this parameter in the _config hash, just return the value instead of querying the database
	if(defined $self->{'_config'}->{$param})
	{
		return $self->{'_config'}->{$param};
	}

	# Get the value from the database
	my $res = $self->db->table('intranet_settings')->find({ 'setting' => $param });

	if($res)
	{
		$ret =  $self->{'_config'}->{$param} = $res->value;
		$self->db->cache->set("intranet_setting.$param",$ret,600);
	}
	return $ret;
}

=head2 remove_config

=over 4

	Remove a configuration setting

	Args   : setting
	Returns: true on success or undef on failure

=back

=cut
sub remove_config
{
	my $self = shift;
	my $setting = shift;

	if(!$setting)
	{
		$@ = "Setting is required";
		return undef;
	}

	if($self->db->search({ 'setting' => $setting })->delete())
	{
		return 1;
	}

	return undef;
}

=head2 get_all_settings

=over 4

	Get an arrayref of hashes of all configuration settings

	Args   : none
	Returns: arrayref of all configuration settings

=back

=cut
sub get_all_settings
{
	my $self = shift;

	my @res = $self->db->table('intranet_settings')->all;
	@res = $self->db->strip(@res) if @res;

	return \@res;
}

=head2 config_keys

=over 4

	Get a list of all config keys and values matching the given key ( key.Setting = value ).

=back

=cut
sub config_keys
{
	my $self = shift;
	my $param = shift;

	if(!$param)
	{
		return undef;
	}

	my @res = $self->db->table('intranet_settings')->search({ 'setting' => { '-like' => '%'.$param.'%' } })->all;

	# Clean up result set
	@res = $self->db->strip(@res) if @res;

	return \@res;
}

=head2 _set_config

=over 4

	This is a private method to update a configuration setting in the database.

	Args   : param, value
	Returns: boolean 1 for success or undef on failure

=back

=cut
sub _set_config
{
	my $subname = '_set_config';

	my $self = shift;

	my ($param, $value) = @_;

	if(not defined($param))
	{
		$@ = "$subname: Settings parameter not defined.";
		return undef;
	}

	if(not defined($value))
	{
		$@ = "$subname: Settings value not defined.";
		return undef;
	}

	my $sql;

	if($self->db->table('intranet_settings')->update_or_create({ 'setting' => $param, 'value' => $value }, { 'key' => 'setting' }))
	{
		return 1;
	}
	else
	{
		return undef;
	}

}

1;
