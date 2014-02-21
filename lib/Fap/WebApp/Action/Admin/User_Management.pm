#!/usr/bin/perl

=head1 User Management Application

=over4

	This application is for adding, removing and editing users.

	You can also enable and disable users, see a permission overview and eeset a user's password.


	Configuration keys used by this application:

		* core.FROM_EMAIL - Email from address when resetting a password for a user
		* user.USERNAME_MIN_LENGTH - minimum length of user names
		* user.USERNAME_MAX_LENGTH - maximum length of user names
		* user.FIRST_NAME_MIN_LENGTH - minimum length of first name
		* user.FIRST_NAME_MAX_LENGTH - maximum length of first name
		* user.LAST_NAME_MIN_LENGTH - minimum length of last name
		* user.LAST_NAME_MIN_LENGTH - maximum length of last name

	Since this application only uses write permission for access, there is no need for individual permission checks.

=back

=cut
use strict;

sub process_User_Management
{
	my $self = shift;

	my $action = $self->valid->param('action');

	if($action eq 'add_user')
	{
		# Get validated form input
		my $username = $self->valid->param('username');
		my $password = $self->valid->param('password');
		my $conf_password = $self->valid->param('conf_password');
		my $first_name = $self->valid->param('first_name');
		my $last_name = $self->valid->param('last_name');
		my $email = $self->valid->param('email');
		my @roles = $self->valid->param('roles[]');

		# Get config values
		my $username_min = $self->config('user.USERNAME_MIN_LENGTH') || 15;
		my $username_max = $self->config('user.USERNAME_MAX_LENGTH') || 36;
		my $first_name_min = $self->config('user.FIRST_NAME_MIN_LENGTH') || 2;
		my $first_name_max = $self->config('user.FIRST_NAME_MAX_LENGTH') || 36;
		my $last_name_min = $self->config('user.LAST_NAME_MIN_LENGTH') || 2;
		my $last_name_max = $self->config('user.LAST_NAME_MAX_LENGTH') || 36;
		
		if(!$username || length($username) > $username_max || length($username) < $username_min)
		{
			$self->write_log(level => 'WARN', log => "Invalid username length: $username");
			$self->alert('Please enter a username between ' . $username_min .' and ' . $username_max . ' characters');

			return $self->json_process;
		}

		if(!$password)
		{
			$self->write_log(level => 'WARN', log => "No password provided for new user");
			$self->alert('Please enter a password for this user');

			return $self->json_process;
		}

		if(!$self->user->strong_password($password))
		{
			$self->write_log(level => 'WARN', log => "Provided password is not strong enough");
			$self->alert($@);

			return $self->json_process;
		}

		if($password ne $conf_password)
		{
			$self->write_log(level => 'WARN', log => "Confirmation password does not match");
			$self->alert('Confirmation password does not match');

			return $self->json_process;
		}

		if(!$first_name || length($first_name) < $first_name_min || length($first_name) > $first_name_max)
		{
			$self->write_log(level => 'WARN', log => "Invalid first name length: $first_name");
			$self->alert("First name must be between $first_name_min and $first_name_max characters");

			return $self->json_process;
		}

		if(!$last_name || length($last_name) < $last_name_min || length($last_name) > $last_name_max)
		{
			$self->write_log(level => 'WARN', log => "Invalid last name length: $last_name");
			$self->alert("Last name must be between $last_name_min and $last_name_max characters");

			return $self->json_process;
		}

		if(!$email || !$self->valid->email($email))
		{
			$self->write_log(level => 'WARN', log => "Email address $email is invalid");
			$self->alert('Invalid email address');

			return $self->json_proces;
		}

		# Try adding the user to the system
		my $user = $self->user->add_user(
			username => $username,
			password => $password,
			first_name => $first_name,
			last_name => $last_name,
			email => $email	
		);

		# Success?
		if($user)
		{
			# Load user
			my $user_info = $self->user->load_user($username);

			# Add user to roles
			if(@roles)
			{
				foreach my $role ( @roles )
				{
					if($self->permission->add_user_to_role($user_info, $role))
					{
						$self->write_log(level => 'VERBOSE', log => "Added new user to role id $role");
					}
					else
					{
						$self->write_log(level => 'ERROR', log => "Could not add new user to role id $role: $@");
						$self->alert("Could not add user to role id $role: $@");
					}
				}
			}

			$self->tt_append(var => 'success', val => 'User added');
			$self->tt_append(var => 'user', val => $user_info);

			return $self->json_process;
		}
		else
		{
			$self->write_log(level => 'ERROR', log => "Could not add user: $@");
			$self->alert('Could not add new user, please try again');
	
			return $self->json_process;
		}
	}
	# Populate the user permissions tab
	elsif($action eq 'show_permissions')
	{
		my $username =$self->valid->param('username');
	
		if($username)
		{
			if(my $user = $self->user->load_user($username))
			{
				my $roles = $self->permission->get_user_roles($user);
				my $perms = $self->permission->get_user_permissions($user);
				my $effective_perms = $self->permission->get_permissions_by_user($user);
				$self->tt_append(var => 'user_roles', val => $roles);
				$self->tt_append(var => 'user_permissions', val => $perms);
				$self->tt_append(var => 'effective_permissions', val => $effective_perms);

				return $self->json_process; 
			}
			else
			{
				$self->write_log(level => 'ERROR', log => "Attempt to load permissions on invalid user $username");
				$self->alert('Invalid username');
				return $self->json_process;
			}
		}
		else
		{
			$self->write_log(level => 'ERROR', log => "Attempt to load permissions without username");
			$self->alert('User name is required');
			return $self->json_process;
		}
	}
	elsif($action eq 'disable_user')
	{
		# Disable a user
		my $username = $self->valid->param('username');
		my $disabled = $self->valid->param('disabled');

		if(!$username)
		{
			$self->write_log(level => 'ERROR', log => "Attempt to disabled user without username");
			$self->alert('Invalid username');
			return $self->json_process;
		}

		$disabled ||= 0;

		if(my $user = $self->user($username))
		{
			if(defined $user->user_info('disabled', $disabled))
			{
				if($disabled)
				{
					$user->user_info('disabled_time', $self->mysql_timestamp);
					$self->write_log(level => 'DEBUG', log => "FROM UNIX: " . $@);
				}
				else
				{
					$user->user_info('disabled_time', '0000-00-00 00:00:00');
				}

				my $msg =  ($disabled) ? "User is now disabled" : "User is now enabled";
				$self->write_log(level => 'VERBOSE', log => "$msg - $username");
				$self->tt_append(var => 'success', val => $msg);
				return $self->json_process;
			}
			else
			{
				$self->write_log(level => 'ERROR', log => "Could not update user disabled for $username: $@");
				$self->alert("Unable to change user information: $@");
				return $self->json_process;
			}
		}
		else
		{
			$self->write_log(level => 'ERROR', log => "Attempt to disable invalid username $username");
			$self->alert('Invalid user');
			return $self->json_process;
		}
	}
	elsif($action eq 'remove_user')
	{
		my $username = $self->valid->param('username');

		if($username)
		{
			if(my $user = $self->user($username))
			{
				my $perm = $self->permission;

				# First remove user from any roles
				my $roles = $perm->get_user_roles($user->user_info);

				foreach my $role ( @{$roles} )
				{
					if($perm->remove_user_from_role($user->user_info, $role))
					{
						$self->write_log(level => 'VERBOSE', log => "Removed user from role $role->{'name'}");
					}
					else
					{
						$self->write_log(level => 'ERROR', log => "could not remove user from role $role->{'name'}: $@");
						$self->alert("Cannot remove user from role: $role->{'name'}");
						return $self->json_process;
					}
				}				

				# Remove user permissions if any
				my $user_perms = $perm->get_user_permissions($user->user_info);

				foreach my $p ( @{$user_perms} )
				{
					if($perm->remove_user_permission($user->user_info, $p))
					{
						$self->write_log(level => 'VERBOSE', log => "Removed user permission $p->{'name'}");
					}
					else
					{
						$self->write_log(level => 'ERROR', log => "Unable to remove user permission $p->{'name'}: $@");
						$self->alert("Could not remove user permission $p->{'name'}");
						return $self->json_process;
					}
				}

				if($user->remove_user)
				{
					$self->write_log(level => 'VERBOSE', log => "Removed user $username");
					$self->tt_append(var => 'success', val => "User has been removed");
					return $self->json_process;
				}
				else
				{
					$self->write_log(level => 'ERROR', log => "Could not remove user $username: $@");
					$self->alert("Could not remove user: $@");
					return $self->json_process;
				}
			}
			else
			{
				$self->write_log(level => 'ERROR', log => "Invalid user while attempting to remove user: $@");
				$self->alert('Inavlid username');
				return $self->json_process;
			}
		}
		else
		{
			$self->write_log(level => 'WARN', log => "Attempt to remove user without username");
			$self->alert('Username is required');

			return $self->json_process;
		}
	}
	elsif($action eq 'generate_pass')
	{
		# Used to auto fill change password form
		my $rpass = $self->user->generate_random_hex(10);

		$self->tt_append(var => 'password', val => $rpass);
		return $self->json_process;	
	}
	elsif($action eq 'update_user')
	{
		# Update basic user information
		my $username = $self->valid->param('username');
		my $fn = $self->valid->param('first_name');
		my $ln = $self->valid->param('last_name');
		my $email = $self->valid->param('email');

		if(!$username)
		{
			$self->write_log(level => 'ERROR', log => "Attempt to update user information without a username");
			$self->alert('Invalid username');
			return $self->json_process();
		}

		if(!$fn)
		{
			$self->write_log(level => 'ERROR', log => "First name is required");
			$self->alert('First name is required');
			return $self->json_process();
		}

		if(!$ln)
		{
			$self->write_log(level => 'ERROR', log => "Last name is required");
			$self->alert('Last name is required');
			return $self->json_process();
		}

		if(!$email)
		{
			$self->write_log(level => 'ERROR', log => "Email is required");
			$self->alert('Email is required');
			return $self->json_process();
		}

		if(!$self->valid->email($email))
		{
			$self->write_log(level => 'ERROR', log => "Invalid email address");
			$self->alert('Invalid email address');
			return $self->json_process();
		}

		if(my $user = $self->user($username))
		{
			$user->user_info('first_name', $fn);
			$user->user_info('last_name', $ln);
			$user->user_info('email', $email);

			$self->tt_append(var => 'success', val => "User updated");
		}
		else
		{
			$self->write_log(level => 'ERROR', log => "Invalid user");
			$self->alert('Invalid user');
		}

		return $self->json_process();
	}
	elsif($action eq 'reset_password')
	{
		my $username = $self->valid->param('username');
		my $new_pass = $self->valid->param('new_password');
		my $conf_pass = $self->valid->param('confirm_password');
		my $send_email = $self->valid->param('send_email');

		if(!$username)
		{
			$self->write_log(level => 'ERROR', log => "Change password without username");
			$self->alert('No username to change password for');
			
			return $self->json_process;
		}

		if(!$new_pass)
		{
			$self->write_log(level => 'ERROR', log => "New password is required");
			$self->alert('New password is required');
			return $self->json_process;
		}

		if(!$conf_pass || $conf_pass ne $new_pass)
		{
			$self->write_log(level => 'ERROR', log => "Confirmation password must match new password");
			$self->alert('New password and confirmation password do not match');
			return $self->json_process;
		}

		if(!$self->user->strong_password($new_pass))
		{
			$self->write_log(level => 'ERROR', log => "New password is not strong enough");
			$self->alert($@);
			return $self->json_process;
		}

		if(my $user = $self->user($username))
		{
			if($user->update_password($new_pass))
			{
				# Reset lockout
				$user->reset_lockout;


				# Expire password
				$user->user_info('password_updated', 0);

				# Do we send them an email about it?
				if($send_email)
				{
					my $from = $self->config('core.FROM_EMAIL') || 'noreply@fonality.com';

					my $sent = $self->mail->send_html_email(
						to => $user->user_info('email'),
						from => $from,
						subject => "Your password has been changed",
						template => 'email/Admin/password_updated.tt',
						vars => { 'USER_INFO' => $user->user_info, NEW_PASS => $new_pass }
					);

					if($sent)
					{
						$self->write_log(level => 'INFO', log => "Sent password change email to $username");
					}
					else
					{
						$self->write_log(level => 'ERROR', log => "Could not deliver email to $username : $@");
						$self->alert('Unable to send email');
					}
				}

				$self->tt_append(var => 'success', val => "Password has been updated");
				return $self->json_process;
			}
			else
			{
				$self->write_log(level => 'ERROR', log => "Could not update user password for $username : $@");
				$self->alert("Unable to update password, please try again");
				return $self->json_process;
			}
		}
		else
		{
			$self->write_log(level => 'ERROR', log => "Attempt to change password on invalid user");
			$self->alert('User does not exist');
			return $self->json_process;
		}	
	}
	elsif($action eq 'searchable')
	{
		my $q = $self->valid->param('query');

		if($q)
		{
			if(my $user = $self->user($q))
			{
				my $res = {
					mode => 'Admin.User_Management',
					anchor => '#userid_'.$user->user_info('id'),
					label => "View user ",
				};

				return $self->json_process({ results => [ $res ] });
			}
		}

		return $self->json_process({ no_result => 1 });
	}	

	my $users = $self->user->load_all_users;
	my $roles = $self->permission->load_all_roles;

	$self->tt_append(var => 'USER_LIST', val => $users);
	$self->tt_append(var => 'ROLE_LIST', val => $roles);

	return $self->tt_process('Admin/User_Management.tt');
}

sub searchable
{
	my $self = shift;
	my $q = $self->valid->param('query');

	if($q)
	{
		if(my $user = $self->user->load_user($q))
		{
			my $res = {
				mode => 'Admin.User_Management',
				params => { '#userid_'.$user->{'id'} },
				label => "View user ",
			};

			return $self->json_process({ results => $res });
		}
	}

	return $self->json_process({ no_result => 1 });
}

sub Admin_User_Management_init_permissions
{
	my $self = shift;

	my $perm = { 
		DESC => "User management interface access",
		LEVELS => 'w',
		VERSION => 3,
	};

	return $perm;
}

sub Admin_User_Management_init_searchable
{
	my $self = shift;

	$self->add_searchable_application('Admin.User_Management', '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}');
}

1;
