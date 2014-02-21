#!/usr/bin/perl

use strict;

sub process_Reset_Password
{
	my $self = shift;

	$self->title('Reset Password');
	my $q = $self->valid;
	my $action = $q->param('action');

	# Reset password form submitted
	if($action eq 'save_password')
	{
		# Get form input
		my $existing_password = $q->param('password');
		my $new_password = $q->param('new_password');
		my $confirm_password = $q->param('confirm_password');

		# Make sure we have our required input
		if(!$existing_password)
		{
			$self->alert('Existing password is required.',1);
			$self->write_log(level => 'VERBOSE', log => "Existing password was not provided.");
		}
		elsif(!$new_password)
		{
			$self->alert('New password is required.',1);
			$self->write_log(level => 'VERBOSE', log => "New password was not provided.");
		}
		elsif(!$confirm_password)
		{
			$self->alert('Confirmation password is required.',1);
			$self->write_log(level => 'VERBOSE', log => "Confirmation password was not provided.");
		}
		elsif($new_password ne $confirm_password)
		{
			$self->alert('Confirmation password does not match new password.',1);
			$self->write_log(level => 'VERBOSE', log => "Confirmation password mismatch.");
		}
		elsif(!$self->strong_password($new_password))
		{
			$self->alert($@,1);
			$self->write_log(level => 'VERBOSE', log => "New password did not meet constraints");
		}
		elsif($existing_password eq $new_password)
		{
			$self->alert("New password must be different than current password");
			$self->write_log(level => 'VERBOSE', log => "New password and current password are the same");
		}
		else
		{
			# Load user
			my $user = $self->user($self->session->param('username'));

			# Verify that the existing password was correct
			if($user->verify_password($existing_password))
			{
				# Upodate the password for the now loaded user
				if($user->update_password($new_password))
				{
					$self->info('Your password has been updated.');
					$self->alert(undef,1); # Clear out the alert in case it's been set by something else
					$self->write_log(level => 'VERBOSE', log => "Password updated for user");
					$self->session->clear('password_expired');  # Remove the expired password session flag
				}
			}
			else
			{
				$self->alert('Existing password is incorrect.',1);
				$self->write_log(level => 'VERBOSE', log => "Existing password is incorrect $@.");
			}
		}
	}

	# Display the template
	return $self->tt_process('Core/Reset_Password.tt');
}

sub Core_Reset_Password_init_permissions
{
	return { GLOBAL => 1 };
}
1;
