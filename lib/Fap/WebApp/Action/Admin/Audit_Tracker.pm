#!/usr/bin/perl

use strict;

sub process_Audit_Tracker
{
	my $self = shift;

	my $action = $self->valid->param('action');

	if($action eq 'clear_audit_log')
	{
		# Not implemented
	}
	elsif($action eq 'view_audit_log')
	{
		my $user = $self->valid->param('user');
		my $range_start = $self->valid->param('range_start', 'url');
		my $range_end = $self->valid->param('range_end', 'url');
		my $module = $self->valid->param('module', 'url');
		my $server_id = $self->valid->param('server_id', 'server_id');
		my $customer_id = $self->valid->param('customer_id', 'numbers');
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

		my $logs = $self->read_audit(userid => $user, range => $date_range, customer_id => $customer_id, server_id => $server_id, module => $module, function => $function );

		$logs = [ $logs ] if ref($logs) ne 'ARRAY';

		$self->tt_append(var => 'results', val => $logs);

		return $self->json_process;
	}

	$self->title('Audit Log Viewer');
	$self->tt_append(var => 'USER_LIST', val => $self->user->load_all_users);

	return $self->tt_process('Admin/Audit_Tracker.tt');
}

sub Admin_Audit_Tracker_init_permissions
{
	my $self = shift;

	my $perm = {
		VERSION => 1,
		DESC => "View Audit Logs",
		LEVELS => 'r',
	};

	return $perm;
}

1;
