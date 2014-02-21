#!/usr/bin/perl

=head1 Permission Management Application

=over4

	This application is used to manage framework permissions.  This includes:

	* Roles - Add / Edit / Remove
	* Role permissions - Add / Edit / Remove
	* User permissions - Add / Edit / Remove


	Template file:

		tt/Admin/Permission_Management.tt


	Application Permissions:

		Only application level write access - all or nothing.  No permissions are checked from the template, just access to the application by the framework.

=back

=cut
use strict;

sub process_Permission_Management
{
	my $self = shift;

	my $action = $self->valid->param('action');

	# Add or update a role
	if($action eq 'add_role')
	{
		# Grab validated input
		my $role_id = $self->valid->param('role_id', 'numbers');
		my $role_name = $self->valid->param('role_name', 'text');
		my $role_desc = $self->valid->param('role_desc', 'text');

		# If a role id is defined, then we are updating an existing role
		if($role_id)
		{
			my $role = $self->permission;

			# Load up the role
			if($role && $role->load_role(intranet_role_id => $role_id))
			{
				# Change role name
				if($role_name)
				{
					if($role->role_info('name', $role_name))
					{
						$self->write_log(level => 'INFO', log => "Updated role $role_id name to $role_name");
					}
					else
					{
						$self->write_log(level => 'ERROR', log => "Could not update role $role_id name to $role_name: $@");
						$self->alert("Could not update role name: $@");
						return $self->json_process;
					}
				}

				# Change role desc
				if($role_desc)
				{
					if($role->role_info('description', $role_desc))
					{
						$self->write_log(level => 'INFO', log => "Updated role $role_id description to $role_desc");
					}
					else
					{
						$self->write_log(level => 'ERROR', log => "Could not update role $role_id description to $role_desc: $@");
						$self->alert("Could not update role description: $@");
						return $self->json_process;
					}
				}

				# Simply set success for the JSON output which will be handled by the javascript on the page
				$self->tt_append(var => 'success', val => 1);

				return $self->json_process;
			}
			else
			{
				$self->write_log(level => 'ERROR', log => "Invalid role provided for update");
				$self->alert("Invalid role ID");
				return $self->json_process;
			}
		}
		else # Add a new role
		{
			my $role = $self->permission;

			# Add the new role and send back the new role info via JSON
			if(my $role_info = $role->add_role($role_name, $role_desc))
			{
				$self->write_log(level => 'VERBOSE', log => "Created new role $role_name");

				$self->tt_append(var => 'success', val => "New role has been added, please wait...");
				$self->tt_append(var => 'role', val => $role_info);
					
				return $self->json_process;
			}
			else
			{
				$self->write_log(level => 'ERROR', log => "Could not create role $role_name: $@");
				$self->alert("Could not create role $@");

				return $self->json_process;
			}
		}
	}
	elsif($action eq 'remove_role')
	{
		my $role_id = $self->valid->param('role_id', 'numbers');

		if($role_id)
		{
			my $perm = $self->permission;
			if(my $role = $perm->load_role(intranet_role_id => $role_id))
			{
				if($perm->remove_role($role_id))
				{
					$self->write_log(level => 'VERBOSE', log => "Removed role $role->{'name'}");
					$self->info("Removed role $role->{'name'}");
					return $self->json_process;
				}
				else
				{
					$self->write_log(level => 'ERROR', log => "Could not remove role $role->{'name'}: $@");
					$self->alert("Could not remove role $role->{'name'}: $@");
					return $self->json_process;
				}
			}
			else
			{
				$self->write_log(level => 'WARN', log => "Attempted to remove invalid role id $role_id: $@");
				$self->alert("Invalid role");
				return $self->json_process;
			}
		}
		else
		{
			$self->write_log(level => 'WARN', log => "Missing role ID when attempting to remove role");
			$self->alert("Role ID is required");
			return $self->json_process;
		}
	}
	elsif($action eq 'add_users_to_role') 
	{
		# Get valid params
		my $role_id = $self->valid->param('role_id', 'numbers');
		my @users = $self->valid->param('users[]', 'numbers');

		# Make sure there are actually users to add
		if(!@users)
		{
			$self->write_log(level => 'WARN', log => "No users selected to add to role");
			$self->alert('No users were selected');
			return $self->json_process;
		}

		if(!$role_id)
		{
			$self->write_log(level => 'WARN', log => "No role id to add users to");
			$self->alert('Invalid role ID');
			return $self->json_process;
		}

		my $perm = $self->permission;

		# Validate the role id
		if(!$perm->load_role(intranet_role_id => $role_id))
		{
			$self->write_log(level => 'ERROR', log => "Could not load role: $@");
			$self->alert('Invalid role ID');

			return $self->json_process;
		}

		# Store added users here
		my @added;

		# Store failed adds here
		my @failed;

		# Add users one by one
		foreach my $user ( @users )
		{
			if($perm->add_user_to_role($user, $role_id))
			{
				$self->write_log(level => 'VERBOSE', log => "Added user id $user to role id $role_id");
				push(@added, $user);
			}
			else
			{
				$self->write_log(level => 'ERROR', log => "Could not add user id $user to role id $role_id: $@");
				push(@failed, $user);
			}
		}

		$self->tt_append(var => 'added', val => \@added);
		$self->tt_append(var => 'failed', val => \@failed);

		# Produce an error message for failed users
		if(my $fail = scalar @failed)
		{
			$self->alert("Unable to add $fail users");
		}

		return $self->json_process;
	}
	elsif($action eq 'remove_users_from_role')
	{
		# Get valid params	
		my $role_id = $self->valid->param('role_id', 'numbers');
		my @users = $self->valid->param('users[]', 'numbers');

		# Make sure that we actually have users to remove
		if(!@users)
		{
			$self->write_log(level => 'WARN', log => "No users selected to remove from role");
			$self->alert('No users were selected');
			return $self->json_process;
		}

		if(!$role_id)
		{
			$self->write_log(level => 'WARN', log => "No role id to remove users from");
			$self->alert('Invalid role ID');
			return $self->json_process;
		}

		my $perm = $self->permission;

		# Validate the role id
		if(!$perm->load_role(intranet_role_id => $role_id))
		{
			$self->write_log(level => 'ERROR', log => "Could not load role: $@");
			$self->alert('Invalid role ID');

			return $self->json_process;
		}

		# Store removed users here
		my @removed;

		# Store failed removals here
		my @failed;

		# Remove each user one by one and store results
		foreach my $user ( @users )
		{
			if($perm->remove_user_from_role($user, $role_id))
			{
				$self->write_log(level => 'VERBOSE', log => "Removed user id $user from role id $role_id");
				push(@removed, $user);
			}
			else
			{
				$self->write_log(level => 'ERROR', log => "Could not remove user id $user from role id $role_id: $@");
				push(@failed, $user);
			}
		}

		$self->tt_append(var => 'removed', val => \@removed);
		$self->tt_append(var => 'failed', val => \@failed);

		# Produce an error message for failed removes
		if(my $fail = scalar @failed)
		{
			$self->alert("Unable to remove $fail users");
		}

		return $self->json_process;
	}
	elsif($action eq 'add_user_permission')
	{
		# Grab valid params
		my $user_id = $self->valid->param('user_id', 'numbers');
		my $permission_id = $self->valid->param('permission_id', 'numbers');

		if(!$user_id)
		{
			$self->write_log(level => 'WARN', log => "No user id for adding user permission");
			$self->alert('Invalid user ID');
			return $self->json_process;
		}

		if(!$permission_id)
		{
			$self->write_log(level => 'WARN', log => "No permission id for adding user permission");
			$self->alert('Invalid Permission ID');
			return $self->json_process;
		}

		# Load up the user
		if($self->load_user(intranet_user_id => $user_id))
		{
			# Add the permission
			if(my $p = $self->add_user_permission($user_id, $permission_id))
			{
				$self->write_log(level => 'VERBOSE', log => "Added user permission $permission_id to user $user_id");
				$self->info('Added user permission');

				# Add the new permission data to the JSON output
				$self->tt_append(var => 'add_user_permission', val => $p);

				# return json data
				return $self->json_process;
			}
			else
			{
				$self->write_log(level => 'ERROR', log => "Could not add user permission $permission_id to user $user_id : $@");
				$self->alert("Could not add user permission");
				
				return $self->json_process;
			}
		}
		else
		{
			$self->write_log(level => 'ERROR', log => "User not found: $@");
			$self->alert('Invalid user ID');
			return $self->json_process;
		}
	}
	elsif($action eq 'remove_user_permission')
	{
		my $user_id = $self->valid->param('user_id', 'numbers');
		my $permission_id = $self->valid->param('permission_id', 'numbers');

		if(!$user_id)
		{
			$self->write_log(level => 'WARN', log => "No user id to remove user permission");
			$self->alert('Invalid user ID');
			return $self->json_process;
		}

		if(!$permission_id)
		{
			$self->write_log(level => 'WARN', log => "No user id to remove user permission");
			$self->alert('Invalid Permission ID');
			return $self->json_process;
		}

		# Load up this user
		if($self->user->load_user(intranet_user_id => $user_id))
		{
			# Remove permission
			if($self->permission->remove_user_permission($user_id, $permission_id))
			{
				$self->write_log(level => 'VERBOSE', log => "Removed permission $permission_id from user $user_id");
				$self->info("Removed user permission");

				return $self->json_process;
			}
			else
			{
				$self->write_log(level => 'ERROR', log => "Could not remove user permission $permission_id from user $user_id : $@");
				$self->alert('Could not remove user permission');

				return $self->json_process;
			}
		}
		else
		{
			$self->write_log(level => 'ERROR', log => "Invalid user ID: $@");
			$self->alert('Invalid user ID');
		
			return $self->json_process;
		}
		
	}
	elsif($action eq 'change_role_permission')
	{
		# Get valid params
		my $role_id = $self->valid->param('role_id', 'numbers');
		my $permission_id = $self->valid->param('permission_id', 'numbers');
		my $permission_level = $self->valid->param('permission_level', 'letters');

		if(!$role_id)
		{
			$self->write_log(level => 'WARN', log => "Cannot update role permissions without role id");
			$self->alert('Invalid role ID');

			return $self->json_process;
		}

		if(!$permission_id)
		{
			$self->write_log(level => 'WARN', log => "Cannot update role permissions without a permission_id");
			$self->alert('Invalid permission ID');

			return $self->json_process;
		}

		my $perm = $self->permission;

		# Validate and load the permission
		if(!$perm->load_permission(intranet_permission_id => $permission_id))
		{
			$self->write_log(level => 'ERROR', log => "Invalid permission id $permission_id: $@");
			$self->alert('Invalid permission ID');
		
			return $self->json_process;
		}

		# Validate and load the role
		if(!$perm->load_role(intranet_role_id => $role_id))
		{
			$self->write_log(level => 'ERROR', log => "Invalid role id $role_id: $@");
			$self->alert('Invalid role ID');

			return $self->json_process;
		}

		# If a permission level is defined, then we should add / update the permission level.  add_permission_to_role automatically handles updating the role if it already exists.
		if($permission_level)
		{
                	if($perm->add_permission_to_role(access => $permission_level))
			{
				$self->write_log(level => 'INFO', log => "Added permission " . $perm->permission_info('name') . " to role " . $perm->role_info('name') . " with $permission_level access");
				$self->tt_append(var => 'level', val => $permission_level);
			}
			else
			{
				$self->write_log(level => 'ERROR', log => "Could not add permission " . $perm->permission_info('name') . " to role " . $perm->role_info('name') . " because $@");
				$self->alert("Could not add permission to role: $@");
			}

			return $self->json_process;
		}
		else
		{
			# No level was provided, so we want to simply remove the permission from the role
			if($perm->remove_permission_from_role())
			{
				$self->write_log(level => 'INFO', log => "Removed permission " . $perm->permission_info('name') . " from role " . $perm->role_info('name'));
				$self->tt_append(var => 'level', val => "");
			}
			else
			{
				$self->write_log(level => 'ERROR', log => "Could not remove permission " . $perm->permission_info('name') . " from role " . $perm->role_info('name') . " because $@");
				$self->alert("Could not remove permission from role: $@");
			}

			return $self->json_process;
		}
	}
	# This is for populating the role permissions when expanded
	elsif($action eq 'load_role_permissions')
	{
		my $role_id = $self->valid->param('role_id', 'numbers');

		if(!$role_id)
		{
			$self->write_log(level => 'WARN', log => "Cannot load role permissions without role id");
			$self->alert("Invalid role id");

			return $self->json_process;
		}

		# We need the role id in the json output
		$self->tt_append(var => 'role_id', val => $role_id);

		my $perm = $self->permission;

		if($perm->load_role(intranet_role_id => $role_id))
		{
			my $permissions = $self->permission->get_role_permissions($role_id);
			$self->tt_append(var => 'permissions', val => $permissions);
		}
		else
		{
			$self->write_log(level => 'ERROR', log => "Invalid role ID $role_id");
			$self->alert('Invalid role');
		}

		# We need a list of users in this role for the user selection boxes
		my $role_users = $perm->get_role_users;

		$self->tt_append(var => 'users', val => $role_users);

		return $self->json_process;
	}
	# For populating the user permissions on expansion
	elsif($action eq 'load_user_permissions')
	{
		my $user_id = $self->valid->param('user_id', 'numbers');

		if(!$user_id)
		{
			$self->write_log(level => 'WARN', log => "Cannot load user permissions without a user id");
			$self->alert('Invalid user id');

			return $self->json_process;
		}

		# Need the user id in the json output
		$self->tt_append(var => 'user_id', val => $user_id);

		# Load up permissions
		my $permissions = $self->permission->get_user_permissions($user_id);

		$self->tt_append(var => 'permissions', val => $permissions);

		return $self->json_process;
		
	}
	# Update / add / remove user permission
	elsif($action eq 'change_user_permission')
	{
		my $user_id = $self->valid->param('user_id', 'numbers');
		my $permission_id = $self->valid->param('permission_id', 'numbers');
		my $permission_level = $self->valid->param('permission_level', 'letters');

		if(!$user_id)
		{
			$self->write_log(level => 'WARN', log => "Cannot update user permissions without user id");
			$self->alert('Invalid user ID');

			return $self->json_process;
		}

		if(!$permission_id)
		{
			$self->write_log(level => 'WARN', log => "Cannot update user permissions without a permission_id");
			$self->alert('Invalid permission ID');

			return $self->json_process;
		}

		my $perm = $self->permission;

		# Validate and load permission
		if(!$perm->load_permission(intranet_permission_id => $permission_id))
		{
			$self->write_log(level => 'ERROR', log => "Invalid permission id $permission_id: $@");
			$self->alert('Invalid permission ID');
		
			return $self->json_process;
		}

		# Load / validate user
		my $user = $self->user($user_id);

		if(!$user)
		{
			$self->write_log(level => 'ERROR', log => "Invalid user ID $user_id: $@");
			$self->alert('Invalid user ID');

			return $self->json_process;
		}

		# Update or add the permission
		if($permission_level)
		{
			if($perm->load_user_permission($user_id, $permission_id))
			{
				if($perm->user_permission_info('access', $permission_level))
				{
					$self->write_log(level => 'INFO', log => "Updated user permission $permission_id for user " . $user->user_info('username') . " to level $permission_level");
					$self->tt_append(var => 'level', val => $permission_level);
				}
				else
				{
					$self->write_log(level => 'INFO', log => "Could not update user permission $permission_id for user " . $user->user_info('username') . " to level $permission_level because: $@");
					$self->alert("Could not update user permission for " . $user->user_info('username') . ": $@");
				}

				return $self->json_process;
			}
			else
			{
				if($perm->add_user_permission($user_id, $permission_id, $permission_level))
				{
					$self->write_log(level => 'INFO', log => "Added permission " . $perm->permission_info('name') . " to user " . $user->user_info('username') . " with $permission_level access");
					$self->tt_append(var => 'level', val => $permission_level);
				}
				else
				{
					$self->write_log(level => 'ERROR', log => "Could not add permission " . $perm->permission_info('name') . " to user " . $user->user_info('username') . " because $@");
					$self->alert("Could not add permission to role: $@");
				}

				return $self->json_process;
			}
		}
		else
		{
			# We want to remove the user permission here
			if($perm->remove_user_permission($user_id, $permission_id))
			{
				$self->write_log(level => 'INFO', log => "Removed permission " . $perm->permission_info('name') . " from user " . $user->user_info('username'));
				$self->tt_append(var => 'level', val => "");
			}
			else
			{
				$self->write_log(level => 'ERROR', log => "Could not remove permission id $permission_id from user " . $user->user_info('username') . " because $@");
				$self->alert("Could not remove permission $permission_id from user " . $user->user_info('username') . ": $@");
			}

			return $self->json_process;
		}
	}
	else
	{
		# This is for loading the actual page - the template requires the list of roles, users and permissions

		my $roles = $self->permission->load_all_roles;
		my $users = $self->user->load_all_users;
		my $permissions = $self->permission->load_permission;

		my %perm;

		map { 
			if($_->{'parent_id'})
			{
				$perm{$_->{'parent_id'}}{'child'}{$_->{'intranet_permission_id'}} = $_;
			}		
			else
			{
				$perm{$_->{'intranet_permission_id'}}{'perm'} = $_;
			}
		} @{$permissions};

		$self->tt_append(var => 'ROLES', val => $roles);
		$self->tt_append(var => 'PERMISSIONS', val => \%perm);
		$self->tt_append(var => 'USERS', val => $users);

		$self->title("Permission Management Application");

		return $self->tt_process('Admin/Permission_Management.tt');
	}
}

# Permissions - Note: only write permission should be here.  The template itself does not handle permissions for this application
sub Admin_Permission_Management_init_permissions
{
	my $perm = {
		DESC => 'Role and User level permission management interface.',
		LEVELS => 'w',
		VERSION => 1,
	};

	return $perm;
}

1;
