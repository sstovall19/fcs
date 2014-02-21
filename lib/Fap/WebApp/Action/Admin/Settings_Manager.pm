#!/usr/bin/perl

use strict;
BEGIN { print STDERR "I AM IN " . __PACKAGE__ . "\n\n"; }

sub process_Settings_Manager
{
	my $self = shift;

	$self->title('Configuration Settings Manager');

	my $action = $self->valid->param('action');

	if($action eq 'remove_setting')
	{
		my $setting = $self->valid->param('setting');

		if(!$setting)
		{
			$self->write_log(level => 'WARN', log => "Attempt to remove configuration setting without a defined setting");
			return $self->json_process({ error => "Invalid configuration setting"});
		}

		if($self->remove_config($setting))
		{
			$self->write_log(level => 'VERBOSE', log => "Removed setting $setting");
			return $self->json_process({ success => 1 });
		}
	}
	elsif($action eq 'update_setting')
	{
		my $setting = $self->valid->param('setting');
		my $value = $self->valid->param('value', 'text');

		if(!$setting)
		{
			$self->write_log(level => 'WARN', log => "Attempt to update configuration setting without a defined setting");
			return $self->json_process({ error => "Invalid configuration setting"});
		}

		if($self->config($setting, $value))
		{
			$self->write_log(level => 'VERBOSE', log => "Updated configuration setting $setting to $value");
			return $self->json_process({ success => 1 });
		}
			
	}
	my $settings = $self->get_all_settings;

	$self->tt_append(var => 'SETTINGS', val => $settings);

	return $self->tt_process('Admin/Settings_Manager.tt');
}

sub Admin_Settings_Manager_init_permissions
{
	my $self = shift;

	my $perm = {
		VERSION => 1,
		LEVELS => 'w',
		DESC => 'Manage Framework Configuration Settings',
	};

	return $perm;
}

1;

