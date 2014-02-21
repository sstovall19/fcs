#!/usr/bin/perl

use strict;

sub process_Log_Viewer
{
	my $self = shift;

	my $action = $self->valid->param('action');

	# Enable / disable log levels
	if($action eq 'toggle_log_level')
	{
		# Make sure that the user actually has permission to edit log levels
		if($self->has_permission('change_levels', 'w'))
		{
			my $log_level = $self->valid->param('log_level');
			my $value = $self->valid->param('value');

			if(!$log_level)
			{
				$self->write_log(level => 'WARN', log => "Attempt to toggle log value of undefined log_level");
				$self->alert('Log level not defined');
				return $self->json_process;
			}

			if(!defined($value))
			{
				$self->write_log(level => 'WARN', log => "Attempt to toggle log value without a defined value");
				$self->alert('No log value defined');
				return $self->json_process;
			}

			if($self->config('log.'.$log_level, $value))
			{
				$self->write_log(level => 'VERBOSE', log => "Toggled log level $log_level to new value $value");
				$self->tt_append(var => 'success', val => $value);
				return $self->json_process;
			}
			else
			{
				$self->write_log(level => 'ERROR', log => "Could not toggle log level $log_level to $value: $@");
				$self->alert("Unable to update log level: $@");
				return $self->json_process;
			}
		}
		else
		{
			# No permission to edit levels
			$self->write_log(level => 'WARN', log => "User does not have permission to edit levels");
			$self->alert("You do not have permission to update log levels");

			return $self->json_process;
		}
	}
	elsif($action eq 'distinct') # Get distinct field values based on search criterea
	{
		my $user = $self->valid->param('user');
		my $range_start = $self->valid->param('range_start', 'url');
		my $range_end = $self->valid->param('range_end', 'url');
		my @levels = $self->valid->param('log_level[]');
		my $ip = $self->valid->param('ip');
		my $module = $self->valid->param('module', 'url');
		my $function = $self->valid->param('function', 'url');
		my $distinct = $self->valid->param('distinct');

		if(!$distinct)
		{
			$self->write_log(level => 'WARN', log => "Cannot retrieve distinct column values without a distinct field");
			return $self->json_process;
		}

		my $date_range;

		if($range_start)
		{
			push @{$date_range}, $range_start;
		}

		if($range_end)
		{
			push @{$date_range}, $range_end;
		}

		my $logs = $self->read_log(userid => $user, range => $date_range, levels => \@levels, ip => $ip, module => $module, function => $function, distinct => $distinct );
		my @distinct_values = grep { $_ = $_->{$distinct} } @{$logs};

		$self->tt_append(var => 'values', val => \@distinct_values);

		return $self->json_process;
	
	}
	elsif($action eq 'search') # Search the log database
	{
		my $user = $self->valid->param('user');
		my $range_start = $self->valid->param('range_start', 'url');
		my $range_end = $self->valid->param('range_end', 'url');
		my @levels = $self->valid->param('log_level[]');
		my $ip = $self->valid->param('ip');
		my $module = $self->valid->param('module', 'url');
		my $function = $self->valid->param('function', 'url');
		my $start = $self->valid->param('start') || 0;
		my $limit = $self->valid->param('limit') || 100;
		my $date_range;

		if($range_start)
		{
			push @{$date_range}, $range_start;
		}

		if($range_end)
		{
			push @{$date_range}, $range_end;
		}

		$self->write_log(level => 'DEBUG', log => "USERID: $user");
		my $logs = $self->read_log(userid => $user, range => $date_range, levels => \@levels, ip => $ip, module => $module, function => $function );
		$logs = [ $logs ] if ref($logs) ne 'ARRAY';

		$self->tt_append(var => 'results', val => $logs);

		return $self->json_process;
	}

	$self->title('Log Viewer');

	my %log_levels;

	# Grab the log levels from the config table
	foreach (qw/DEBUG VERBOSE INFO ERROR WARN TTDUMP/)
	{
		$log_levels{$_} = $self->config('log.'.$_);
	}

	$self->tt_append(var => 'LOG_LEVELS', val => \%log_levels);

	$self->tt_append(var => 'USER_LIST', val => $self->user->load_all_users);

	return $self->tt_process('Admin/Log_Viewer.tt');	
}

sub Admin_Log_Viewer_init_permissions
{
	my($self, $module_name) = @_;

	my $perm = {
		DESC => 'System log viewing application',
		PERMISSIONS => # Application Permissoins
		{
			'change_levels' =>
			{
				LEVELS => 'rw',
				NAME => 'Change / view levels',
				DESC => 'This allows the user to enable and disable log levels with write access or view enabled log levels with read access'
			},
		},
		LEVELS => 'r',
		VERSION => 6
	};

	return $perm;
}

1;
