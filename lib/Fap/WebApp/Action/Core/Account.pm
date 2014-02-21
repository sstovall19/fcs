#!/usr/bin/perl
# Display basic session and user information
use strict;

sub process_Account
{
	my $self = shift;

	$self->title('My Account');
	$self->user($self->session->param('username'));
	$self->tt_append(var => 'USER_INFO', val => $self->user_info);
	$self->write_log(level => 'DEBUG', log => $self->session->param);
	$self->tt_append(var => 'SESSION_EXPIRES', val => $self->session->ctime + $self->session->expire());
	$self->tt_append(var => 'SESSION_STARTED', val => $self->session->ctime);
	$self->tt_append(var => 'PASSWORD_EXPIRES', val => $self->user_info('password_updated') + $self->config('Auth.password_expires') * 24 * 60 * 60);
	return $self->tt_process('Core/Account.tt');
}

sub Core_Account_init_permissions
{
	my($self, $module_name) = @_;

	return { GLOBAL => 1 };
}
1;
