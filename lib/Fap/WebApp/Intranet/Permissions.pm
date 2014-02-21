#!/usr/bin/perl
# Start of documentation header 
 
=head1 NAME 
 
CGI::Application::Plugin::FONPermissions
 
=head1 VERSION 
 
$Id: Permissions.pm 2271 2013-03-14 20:26:08Z mhollenbeck $ 
 
=head1 SYNOPSIS 
 
use CGI::Application::Plugin::FONPermissions

=head1 DESCRIPTION 

	Permission handling methods
 
=head1 EXAMPLES 
 
=over 4 
 
	See examples in class methods.

=back 

=head1 CLASS METHODS

=over 4

Method usage.

=back

=cut
package Fap::WebApp::Intranet::Permissions;

use strict;
use vars qw($VERSION @EXPORT);
use base 'Fap::WebApp::Intranet';
use Scalar::Util ();

$VERSION = '1.00';

require Exporter;

@EXPORT = qw(
	permission
	instance
	load_role
	load_all_roles
	add_role
	remove_role
	unload_role
	role_info
	add_user_to_role
	remove_user_from_role
	user_has_role
	add_permission
	remove_permission
	load_permission
	unload_permission
	permission_info
	add_user_permission
	remove_user_permission
	user_permission_info
	load_user_permission
	unload_user_permission
	add_permission_to_role
	remove_permission_from_role
	get_role_permissions
	get_user_permissions
	get_permissions_list
	get_permissions_by_user
	get_user_roles
	get_role_users
);

sub import
{
	goto &Exporter::import;
}

=head2 new

=over 4

	Creates a new new instance.

	This should generally not be used directly.  To retrieve a new instance, simply call permission instead.

=back

=cut
sub new {
	my $class  = shift;
	my $cgiapp = shift;
	my %params = @_;
	my $self   = {};

	bless $self, $class;
	$self->{cgiapp} = $cgiapp;
	Scalar::Util::weaken($self->{cgiapp});

	return $self;
}

=head2 permission

=over 4

	Create and return a new permission instance.

	Note, You can run methods directly without keeping the instance around by calling the method name like so:

		$self->permission->method_name(@arguments);

	This use is less efficient if you plan to perform multiple permission tasks however, in that case, create a permission instance and keep it around.


	Args   : none
	Returns: permission instance

	Examples:

		my $permission_instance = $self->permission;
		$permission_instance->method_name(@args);

		my $permission_info = $self->permission->load_permission('Permission Name');

=back

=cut
sub permission
{
	my $cgiapp = shift;

	return __PACKAGE__->instance($cgiapp);
}

sub instance
{
	my $class = shift;
	my $cgiapp = shift;

	return $class->new($cgiapp);
}

=head2 load_role

=over 4

	Load and return role data.

	Once a role is loaded, you can modify the role or use the loaded role in methods which require a role id or name.


	Args   : one of role_id, role_name or key value pairs of id and / or name
	Returns: Hashref of role data or undef on error

	Examples:

		# This returns the role information associated with 'Role Name', but this data cannot be altered or re-used in this format.
		my $role = $self->permission->load_role('Role Name');


		# Create a permission instance, load the role with the name 'Role Name' and change the description		
		my $perm = $self->permission;
		$perm->load_role('Role Name');
		$perm->role_info('description', 'New Description For Role');

		# Load role by key value pair
		$perm->load_role(id => 23);
		$perm->load_role(name => 'Role Name');

		# Load role by id
		$perm->load_role(23);

=back

=cut
sub load_role
{
	my $self = shift;
	my %params;

	if(@_==1)
	{
		if($_[0] =~ /^\d+/)
		{
			$params{'intranet_role_id'} = $_[0];
		}
		else
		{
			$params{'name'} = $_[0];
		}
	}
	else
	{
		%params = @_;
	}

	# Store SQL fields and values here
	my %search_keys;


	# Make sure we have valid identifiers to load the role
	foreach my $key ( keys %params )
	{
		if($key ne 'intranet_role_id' && $key ne 'name')
		{
			$@ = "Invalid role identifier $key";
			return undef;
		}

		if(not defined $params{$key})
		{
			$@ = "Role identifier $key was not defined";
			return undef;
		}
		$search_keys{$key} = $params{$key};
	}	
	use Data::Dumper;
	print STDERR Dumper(%search_keys);


	if(%search_keys)
	{
		# Unload current role
		$self->unload_role();
		
		my $res = $self->db->table('intranet_role')->search(\%params, { limit => 1 });

		if($res && $res->first)
		{
			$self->{'FONPermissions'}->{'_role_resultset'} = $res->first;
			my %role_info = $res->first->get_columns;
			return $self->{'FONPermissions'}->{'_role_info'} = \%role_info;
		}
		else
		{
			$@ = "Role not found";
			return undef;
		}
	}
	else
	{
		$@ = "No search parameters";
		return undef;
	}
}

=head2 load_all_roles

=over 4

	Load a list of all roles.

	Args   : none
	Returns: array ref of all roles

=back

=cut
sub load_all_roles
{
	my $self = shift;

	my @res = $self->db->table('intranet_roles')->all;
	@res = $self->db->strip(@res) if @res;

	return \@res;
}

=head2 add_role

=over 4

	Add a new role to the framework.

	If the role name already exists, it will update the existing role.

	Args   : $role_name, [ $role_description ]
	Returns: Hashref of inserted or updated role information or undef on error

=back

=cut	
sub add_role
{
	my $self = shift;
	my ($role, $description) = @_;

	if(!$role)
	{
		$@ = "Role name required";
		return undef;
	}

	# To prevent conflicts while adding or removing users / permissions to roles.
	if($role =~ /^\d+$/)
	{
		$@ = "Role must contain at least one letter";
		return undef;
	}

	$description ||= '';

	my $sql;
	my @args = ($role, $description);

	if(my $existing_role = $self->load_role($role))
	{
		$self->role_info('name', $role) || return undef;
		$self->role_info('description', $description) || return undef;
	}
	else
	{
		my $role_info = {
			'name'		=> $role,
			'description'	=> $description,
		};

		if($self->db->table('intranet_role')->create($role_info))
		{
			return $self->load_role($role);
		}

		return undef;
	}

}

=head2 remove_role

=over 4

	Removes a role from the framework

	You must provide either a role id, role name or have already loaded a role via load_role

	Args   : [ $role_id | $role_name ]
	Returns: true on success or undef on failure

	Examples:

		# Remove role by name
		my $perm = $self->permission;
		$perm->remove_role('Role Name');

		# Remove role by id
		my $perm = $self->permission;
		$perm->remove_role(36);

		# Remove loaded role
		my $perm = $self->permission;
		$perm->load_role(id => 36);
		$perm->remove_role;

=back

=cut		
sub remove_role
{
	my $self = shift;
	my $role = shift;

	if(!$role && !&_role_is_loaded($self))
	{
		$@ = "No role name provided";
		return undef;
	}

	if($role)
	{
		$self->load_role($role);
	}

	my $role_id = $self->role_info('intranet_role_id');

	if(!$role_id)
	{
		$@ = "Invalid role";
		return undef;
	}

	# Delete all user references to this role
	if($self->db->table('intranet_user_role_xref')->search({ 'role_id' => $role_id })->delete())
	{
		$self->write_log('level' => 'VERBOSE', 'log' => "Users removed from role " . $self->role_info('name'));
	}
	else
	{
		$self->write_log('level' => 'WARN', 'log' => "unable to remove any users from role " . $self->role_info('name'));
	}

	if($self->db->table('intranet_roles')->search({ 'intranet_role_id' => $role_id })->delete())
	{
		$self->write_log('level' => 'VERBOSE', 'log' => "Removed role " . $self->role_info('name'));
		$self->unload_role;
		return 1;
	}
	else
	{
		$self->write_log('level' => 'WARN', 'log' => "Unable to remove role $@");
		return undef;
	}
}

=head2 unload_role

=over 4

	Unload role data that was previously loaded via load_role

	Args   : none
	Returns: nothing

=back

=cut
sub unload_role
{
	my $self = shift;
	delete $self->{'FONPermissions'}->{'_role_info'};
	delete $self->{'FONPermissions'}->{'_role_resultset'};
}

=head2 role_info

=over 4

	Get or set loaded role information

	Args   : $key_name, [ $key_value ]
	Returns: $key_value

	Examples:

		$perm->role_info('id');  # Return the id of the currently loaded role

		$perm->role_info('description', 'New Description'); # Set the loaded role's description to 'New Description'

=back

=cut
sub role_info
{
	my $self = shift;
	my ($key, $value) = @_;

	if(!$key)
	{
		$@ = "No role key provided";
		return undef;
	}

	if(!&_role_is_loaded($self))
	{
		$@ = "No role loaded";
		return undef;
	}

	if(defined $value)
	{
		if(&_save_role_info($self, $key => $value))
		{
			return $self->{'FONPermissions'}->{'_role_info'}->{$key} = $value;
		}
		else
		{
			return undef;
		}
	}
	if(not defined $value)
	{
		return $self->{FONPermissions}->{_role_info}->{$key};
	}
}

=head2 _save_role_info

=over 4

	Private method used to change role info via role_info

	Args   : $cgiapp, %key_value_pairs
	Returns: true on success or undef on failure

=back

=cut
sub _save_role_info
{
	my $self = shift;
	my %params = @_;

	if(!&_role_is_loaded($self))
	{
		$@ = "No role loaded";
		return undef;
	}

	# Store SQL fields and values here
	my %updates;

	# Make sure we have valid identifiers to load the role
	foreach my $key ( keys %params )
	{
		if($key ne 'name' && $key ne 'description')
		{
			$@ = "Invalid role identifier $key";
			return undef;
		}

		if(not defined $params{$key})
		{
			$@ = "Role identifier $key was not defined";
			return undef;
		}

		$updates{$key} = $params{$key};
	}	

	if(%updates)
	{
		if($self->{'FONPermissions'}->{'_role_resultset'})
		{
			$self->{'FONPermissions'}->{'_role_resultset'}->set_columns(\%updates);

			if($self->{'FONPermissions'}->{'_role_resultset'}->update())
			{
				return 1;
			}
			else
			{
				$@ = "Could not update fields $@";
				return undef;
			}
		}
		else
		{
			$@ = "Role result set is not loaded";
			return undef;
		}
	}
}

=head2 _role_is_loaded

=over 4

	Private method used to verify whether or not a role is loaded

	Args   : none
	Returns: true if role is loaded or undef if not

=back

=cut
sub _role_is_loaded
{
	my $self = shift;

	if(exists $self->{FONPermissions}->{_role_info} && defined($self->{FONPermissions}->{_role_info}))
	{
		return 1;
	}
	else
	{
		return undef;
	}
}

=head2 add_user_to_role

=over 4

	Adds the given user id to the provided role id / hash or loaded role


	Args   : $user_id_or_user_hash, [ $role_id_or_name_or_role_hash ]
	Returns: true on success or undef on failure

	Examples:

		# Add user with username jweitz@fonality.com to the role named 'Role Name'
		my $perm = $self->permission;
		my $user = $self->user->load_user('jweitz@fonality.com');
		$perm->add_user_to_role($user, 'Role Name');

		# Add user with user id 23 to Role id 18
		my $user = $self->user(23);
		$self->permission->add_user_to_role($user, 18);

		# Add user with user id 23 to role id 18 using a loaded role
		my $user = $self->user(23);
		my $perm = $self->permission;
		$perm->load_role(18);
		$perm->add_user_to_role($user);

=back

=cut		
sub add_user_to_role
{
	my $self = shift;
	my ($user_id, $role_id) = @_;

	# If we were passed a loaded user hash, just grab the id from the hash
	if(ref($user_id) eq 'HASH')
	{
		if(exists $user_id->{'intranet_user_id'})
		{
			$user_id = $user_id->{'intranet_user_id'};
		}
		else
		{
			$user_id = undef;
		}
	}

	# User id cannot be a user name, but must be a user id
	if($user_id !~ /^\d+$/)
	{
		$@ = "User id is required";
		return undef;
	}

	# If we received a load_role hash, get the id from it
	if(ref($role_id) eq 'HASH')
	{
		if(exists $role_id->{'intranet_role_id'})
		{
			$role_id = $role_id->{'intranet_role_id'};
		}
		else
		{
			$role_id = undef;
		}
	}

	# Make sure we have a role or one is loaded
	if(!$role_id && !&_role_is_loaded($self))
	{
		$@ = "No role id loaded or provided.";
		return undef;
	}

	# If we have a role id, then load it to verify that this role exists
	if($role_id =~ /^\d+$/)
	{
		$self->load_role(intranet_role_id => $role_id);
	}
	else
	{
		# Load by name
		$self->load_role(name => $role_id);
	}

	# Validate this role
	$role_id = $self->role_info('intranet_role_id');

	if(!$role_id)
	{
		$@ = "Invalid role";
		return undef;
	}

	# Don't insert another row if they are already in the role
	if($self->user_has_role($user_id, $role_id))
	{
		
		# user already in this role
		return 1;
	}
	else
	{
		if($self->db->table('intranet_user_role_xref')->create({ 'intranet_user_id' => $user_id, 'role_id' => $role_id }))
		{
			return 1;
		}
		else
		{
			return undef;
		}
	}
}

=head2  remove_user_from_role

=over 4

	Removes the given user from the provided role id / name or loaded role

	Args   : $user_id_or_hash, [ $role_id_name_or_hash ]
	Returns: true on success or undef on failure

	Examples:

		# Remove user with username jweitz@fonality.com from role name 'Role Name'
		my $user = $self->user->load_user('jweitz@fonality.com');
		$self->permission->remove_user_from_role($user, 'Role Name');

		# Remove user id 23 from loaded role
		my $perm = $self->permission;
		$perm->load_role('Role Name');
		$perm->remove_user_from_role(23);

		# Remove user id 23 from role id 16
		$self->remove_user_from_role(23, 16);

=back

=cut
sub remove_user_from_role
{
	my $self = shift;
	my ($user_id, $role_id) = @_;

	# Get the user id from the load_user hash if that is what we were given
	if(ref($user_id) eq 'HASH')
	{
		if(exists $user_id->{'intranet_user_id'})
		{
			$user_id = $user_id->{'intranet_user_id'};
		}
		else
		{
			$user_id = undef;
		}
	}

	# Make sure we didn't get a user name rather than user id - This could be udpated to run load_user, but this should probably be loaded outside of permissions
	if($user_id !~ /^\d+$/)
	{
		$@ = "User id is required";
		return undef;
	}

	# If we have a load_role hash, then grab the id from it
	if(ref($role_id) eq 'HASH')
	{
		if(exists $role_id->{'intranet_user_id'})
		{
			$role_id = $role_id->{'intranet_user_id'};
		}
		else
		{
			$role_id = undef;
		}
	}

	# Make sure that we have a role or check to see if one is loaded and use that one
	if(!$role_id && !&_role_is_loaded($self))
	{
		$@ = "No role id loaded or provided.";
		return undef;
	}

	# Load role by id to verify that it's valid
	if($role_id =~ /^\d+$/)
	{
		$self->load_role(intranet_role_id => $role_id);
	}
	else
	{
		# Load by role name
		$self->load_role(name => $role_id);
	}

	# Validate this role
	$role_id = $self->role_info('intranet_role_id');

	# Make sure we found the role
	if(!$role_id)
	{
		$@ = "Invalid role";
		return undef;
	}

	# Make sure that this use actually is assigned to this role
	if($self->user_has_role(intranet_role_id => $role_id))
	{
		if($self->db->table('intranet_user_role_xref')->search({ 'intranet_user_id' => $user_id, 'role_id' => $role_id })->delete())
		{
			return 1;
		}
		else
		{
			return undef;
		}
	}
	else
	{
		# User is not in this role
		return 1;
	}
}

=head2 user_has_role

=over 4

	Determine if user is assigned to the given or loaded role

	Args   : $user_id_or_hash, [ $role_id_name_or_hash ]
	Returns: True or undef if not assigned to the role

=back

=cut
sub user_has_role
{
	my $self = shift;
	my ($user_id, $role_id) = @_;

	if(ref($user_id) eq 'HASH')
	{
		if(exists $user_id->{'intranet_user_id'})
		{
			$user_id = $user_id->{'intranet_user_id'};
		}
		else
		{
			$user_id = undef;
		}
	}

	if($user_id !~ /^\d+$/)
	{
		$@ = "User id is required";
		return undef;
	}

	if(ref($role_id) eq 'HASH')
	{
		if(exists $role_id->{'intranet_rolw_id'})
		{
			$role_id = $role_id->{'intranet_role_id'};
		}
		else
		{
			$role_id = undef;
		}
	}

	if(!$role_id && !&_role_is_loaded($self))
	{
		$@ = "No role id loaded or provided.";
		return undef;
	}

	if($role_id =~ /^\d+$/)
	{
		$self->load_role(intranet_role_id => $role_id);
	}
	else
	{
		$self->load_role(name => $role_id);
	}

	$role_id = $self->role_info('intranet_role_id');

	# Make sure we actually were able to load the requested role
	if(!$role_id)
	{
		$@ = "Invalid role";
		return undef;
	}

	my $res = $self->db->table('intranet_user_role_xref')->search({ 'intranet_user_id' => $user_id, 'role_id' => $role_id }, { 'limit' => 1 });

	if($res && $res->first)
	{
		return 1;
	}
	else
	{
		return undef;
	}
}

=head2 add_permission

=over 4

	Adds a new permission to the framework.  The default access level is r ( read ).

	Level should be a string containing r for read and/or w for write.

	Args   : $permission_name, $parent_id, [ $description ], [ $access ]
	Returns: true on success or undef on failure

	Examples:

		# Add a new permission with parent id 3
		$self->permission->add_permission('Permission Name', 3, 'Description of Perm', 'rw');

		# Add a new permission with no parent
		my $perm = $self->permission;
		$perm->add_permission('Permission Name', undef, 'Description of Permission', 'w');

=back

=cut
sub add_permission
{
	my $self = shift;
	my ($permission, $parent_id, $description, $access) = @_;

	if(!$permission)
	{
		$@ = "Permission name required";
		return undef;
	}

	if($permission =~ /^\d+$/)
	{
		$@ = "Permission name must not be all numbers";
		return undef;
	}

	# Can't have an undef description
	$description ||= '';
	
	# Fix up permissions
        $access ||= 'r';

        if($access !~ /^[rw]+$/)
        {
                $@ = "Invalid permission level";
                return undef;
        }

	# Verify parent information if provided
	if($parent_id)
	{
		if(ref($parent_id) eq 'HASH')
		{
			if(exists $parent_id->{'intranet_permission_id'})
			{
				$parent_id = $parent_id->{'intranet_permission_id'};
			}
			else
			{
				$@ = "Invalid parent permission format";
				return undef;
			}
		}

		# Should we load by id or name?
		if($parent_id =~ /^\d+$/)
		{
			$self->load_permission(intranet_permission_id => $parent_id);
		}
		else
		{
			$self->load_permission(name => $parent_id);
		}

		# Validate the parent permission - we don't want an invalid parent id
		$parent_id = $self->permission_info('intranet_permission_id');

		if(!$parent_id)
		{
			$@ = "Invalid parent permission";
			return undef;
		}
	}
	else
	{
		$parent_id = undef;
	}

	# Check to see if we already have this permission
	if($self->load_permission(name => $permission, parent_id => $parent_id))
	{
		$@ = "Permission $permission already exists";
		return undef;
	}

	my $permission_data = {
		'name'		=> $permission,
		'parent_id'	=> $parent_id,
		'description'	=> $description,
		'access'	=> $access
	};

	if($self->db->table('intranet_permission')->create($permission_data))
	{
		return $self->load_permission('name' => $permission);
	}
	else
	{
		$@ = "Could not add permission $permission ( parent: $parent_id ): $@";
		return undef;
	}
}

=head2 remove_permission

=over 4

	Removes a permission from the framework based on provided permission or loaded permission

	If the loaded or provided permission has a parent permission; the parent_id is required.


	Args   : [ $permission_id_or_hash ], [ $parent_id_or_hash ]
	Returns: true on success or undef on failure

	Examples:

		# Remove permission id 33 with parent id 6
		$self->permission->remove_permission(33, 6);

		# Remove loaded permission
		my $perm = $self->permission;
		$perm->load_permission('Permission Name');
		$perm->remove_permission;

		# More complex example
		my $perm = $self->permission;
		if(my $p = $perm->load_permission(id => 23))
		{
			my $parent_id = $perm->permission_info('id');
			$perm->remove_permission($p, $parent_id);
		}

		
=back

=cut
sub remove_permission
{
	my $self = shift;
	my ($permission_id, $parent_id) = @_;

	if(!$permission_id && !&_permission_is_loaded($self))
	{
		$@ = "No permission loaded or provided";
		return undef;
	}

	if(ref($permission_id) eq 'HASH')
	{
		if(exists $permission_id->{'intranet_permission_id'})
		{
			$permission_id = $permission_id->{'intranet_permission_id'};
		}
		else
		{
			$@ = "Invalid permission format";
			return undef;
		}
	}

	if(ref($parent_id) eq 'HASH')
	{
		if(exists $parent_id->{'intranet_permission_id'})
		{
			$parent_id = $parent_id->{'intranet_permission_id'};
		}
		else
		{
			$@ = "Invalid parent permission format";
			return undef;
		}
	}

	# Make sure we deal with the parent first so that we don't leave the parent loaded
	if($parent_id)
	{
		if($parent_id =~ /^\d+/)
		{
			$self->load_permission(intranet_permission_id => $parent_id);
		}
		else
		{
			$self->load_permission(name => $parent_id);
		}

		$parent_id = $self->permission_info('intranet_permission_id');

		if(!$parent_id)
		{
			$@ = "Invalid parent permission";
			return undef;
		}
	}

	# Set parent id to 0 if there isn't one
	$parent_id ||= undef;

	if($permission_id =~ /^\d+/)
	{
		$self->load_permission(intranet_permission_id => $permission_id, parent_id => $parent_id);
	}
	else
	{
		$self->load_permission(name => $permission_id, parent_id => $parent_id);
	}

	$permission_id = $self->permission_info('intranet_permission_id');

	if(!$permission_id)
	{
		$@ = "Invalid permission $@";
		return undef;
	}

	# Default parent id is 0 ( no parent )
	$parent_id ||= undef;

	if($self->db->table('intranet_permission')->search({ 'intranet_permission_id' => $permission_id, 'parent_id' => $parent_id })->delete())
	{
		$self->unload_permission;
		return 1;
	}
	else
	{
		$@ = "Could not remove permission $permission_id ( parent $parent_id ): $@";
		return undef;
	}
}

=head2 load_permission

=over 4

	Load a permission into the instance by name, id or key/value list

	Args   : $permission_id_name_or_key_value_pairs
	Returns: hash of permission properties

	Examples:

		# Get properties of the permission named 'Perm Name'
		my $perm_info = $self->permission->load_permission('Perm Name');

		# Get properties of the permission with id 23
		my $perm_info = $self->permission->load_permission(23);

		# Load permission with id 23 into a returned instance
		my $perm = $self->permission;
		$perm->load_permission(id => 23);

=back

=cut		
sub load_permission
{
	my $self = shift;
	my %params;

	if(@_==1)
	{
		if($_[0] =~ /^\d+$/)
		{
			$params{'intranet_permission_id'} = $_[0];
		}
		else
		{
			$params{'name'} = $_[0];
		}
	}
	else
	{
		%params = @_;
	}

	# Store SQL fields and values here
	my %search_fields;

	# Unload current permission
	$self->unload_permission();

	# Make sure we have valid identifiers to load the permission
	foreach my $key ( keys %params )
	{
		if($key ne 'intranet_permission_id' && $key ne 'name' && $key ne 'parent_id')
		{
			$@ = "Invalid permission identifier $key";
			return undef;
		}

		# This is no longer working all of a sudden, but I don't want to remove it quite yet as it could be important
		#if(not defined $params{$key} && $params{$key} != 'parent_id')
		#{
		#	$@ = "Permission identifier $key was not defined";
		#	return undef;
		#}

		$search_fields{$key} = $params{$key};
	}	

	# Check to see if we should limit our results to a particular permission
	if(%search_fields)
	{	
		my $res = $self->db->table('intranet_permission')->search(\%search_fields, { limit => 1 });

		if($res && $res->first)
		{
			$self->{'FONPermissions'}->{'_permission_resultset'} = $res->first;
			my %permission_info = $res->first->get_columns;
			return $self->{'FONPermissions'}->{'_permission_info'} = \%permission_info;
		}
		else
		{
			$@ = "Permission not found";
			return undef;
		}

	}
	else
	{
		my @res = $self->db->table('intranet_permission')->all();
		@res = $self->db->strip(@res);

		return $self->{'FONPermissions'}->{'_permission_list'} = \@res;
	}
}

=head2 unload_permission

=over 4

	Unload the currently loaded permission.  This should rarely be used publicly, and generally is used by load_permission to reset the internal hash data when loading a new permission.

	Args   : none
	Returns: nothing

=back

=cut
sub unload_permission
{
	my $self = shift;
	delete $self->{'FONPermissions'}->{'_permission_info'};
	delete $self->{'FONPermissions'}->{'_permission_resultset'};
}


=head2 permission_info

=over 4

	Retrieve or set a permission key

	Args   : $key_name, [ $key_value ]
	Returns: $key_value

	Examples:

		my $perm = $self->permission;
		$perm->load_permission(id => 23);
		$perm->permission_info('name'); # Get the name of permission id 23

		$perm->permission_info('description', 'New Description'); # Set the description of the permission to 'New Description'

=back

=cut
sub permission_info
{
	my $self = shift;
	my ($key, $value) = @_;

	if(!$key)
	{
		$@ = "No permission key provided";
		return undef;
	}

	# Make sure that there is actually a permission loaded
	if(!&_permission_is_loaded($self))
	{
		$@ = "No role loaded";
		return undef;
	}
	
	# If the value is defined, we need to update the database and hash
	if(defined $value)
	{
		if(&_save_permission_info($self, $key => $value))
		{
			return $self->{FONPermissions}->{_permission_info}->{$key} = $value;
		}
		else
		{
			return undef;
		}
	}
	if(not defined $value) # Just return the key value
	{
		return $self->{FONPermissions}->{_permission_info}->{$key};
	}

}

=head2 _save_permission_info

=over 4

	Private method used to udpate the permission database via permission_info

	Args   : $key_name, $key_value
	Returns: $key_value

=back

=cut
sub _save_permission_info
{
	my $self = shift;
	my %params = @_;

	if(!&_permission_is_loaded($self))
	{
		$@ = "No permission loaded";
		return undef;
	}

	# Store SQL fields and values here
	my %updates;

	# Make sure we have valid identifiers to load the role
	foreach my $key ( keys %params )
	{
		if($key ne 'name' && $key ne 'parent_id' && $key ne 'description' && $key ne 'access')
		{
			$@ = "Invalid permission identifier $key";
			return undef;
		}

		if(not defined $params{$key})
		{
			$@ = "Permission identifier $key was not defined";
			return undef;
		}

		$updates{$key} = $params{$key};
	}	

	$self->{'FONPermissions'}->{'_permission_resultset'}->set_columns(\%updates);

	if($self->{'FONPermissions'}->{'_permission_resultset'}->update())
	{
		return 1;
	}
	else
	{
		$@ = "Could not update fields: $@";
		return undef;
	}
}

=head2 _permission_is_loaded

=over 4

	Private method used to determine if a permission has been loaded

	Args   : none
	Returns: true if a permission is loaded or undef if not

=back

=cut
sub _permission_is_loaded
{
	my $self = shift;
	if(exists $self->{FONPermissions}->{_permission_info})
	{
		return 1;
	}
	else
	{
		return undef;
	}
}

=head2 add_user_permission

=over 4

	Adds a permission to an individual user.   This is used grant a permissoin to a user outside of the permissoins inherited by the user's role(s).

	Permission access level can be one or both of r or w ( Default 'r' )


	Args   : $user_id_or_hash, [ $permission_id_or_hash ], [ 'r' | 'w' ]
	Returns: true on success or undef on failure

	Examples:

		# Add the permission named 'Permission Name' to user jweitz@fonality.com
		my $user = $self->user('jweitz@fonality.com');
		my $permission = $self->permission->load_permission('Permission Name');
		$self->permission->add_user_permission($user, $permission, 'w');

		# Load a permission and add it with write access level to a user with username jweitz@fonality.com
		my $user = $self->user('jweitz@fonality.com');
		my $perm = $self->permission;
		$perm->load_permission('Permission Name');
		$perm->add_user_permission($user,undef,'w');

=back

=cut
sub add_user_permission
{
	my $self = shift;
	my ($user_id, $permission_id, $access) = @_;

	if(!$user_id)
	{
		$@ = "User id is required";
		return undef;
	}

	if(ref($user_id) eq 'HASH')
	{
		if(defined($user_id->{'intranet_user_id'}))
		{
			$user_id = $user_id->{'intranet_user_id'};
		}
		else
		{
			$@ = "Invalid user format";
			return undef;
		}
	}

	if(!$permission_id && !&_permission_is_loaded($self))
	{
		$@ = "No permission loaded or provided";
		return undef;
	}

	if(ref($permission_id) eq 'HASH')
	{
		if(defined($permission_id->{'intranet_permission_id'}))
		{
			$permission_id = $permission_id->{'intranet_permission_id'};
		}
		else
		{
			$@ = "Invalid permission format";
			return undef;
		}
	}

	if($permission_id)
	{
		$self->load_permission($permission_id);
	}

	my $permission_id = $self->permission_info('intranet_permission_id');

	if(!$permission_id)
	{
		$@ = "Invalid permission";
		return undef;
	}

	$access ||= 'r';

	# If the user permission already exists, just set and return the access level
	if($self->load_user_permission($user_id, $permission_id))
	{
		return $self->user_permission_info('access', $access);
	}
	else
	{
		my $user_permission_data = {
			'intranet_user_id'	=> $user_id,
			'permission_id'		=> $permission_id,
			'access'		=> $access
		};

		if($self->db->table('intranet_user_permission_xref')->create($user_permission_data))
		{
			return 1;
		}
		else
		{
			return undef;
		}
	}

}

=head2 remove_user_permission

=over 4

	Removes the provided or loaded permission from the given user

	Args   : $user_id_or_hash, [ $permission_id_name_or_hash ]
	Returns: true on success or undef on failure

	Examples:

		# Remove permissoin 'Permission Name' from a user with username jweitz@fonality.com
		my $user = $self->user('jweitz@fonality.com');
		$self->permission->remove_user_permission($user, 'Permission Name');

		# Remove permission 'Permission Name' from the same user but using a loaded permission in a permission instance
		my $user = $self->user('jweitz@fonality.com');
		my $perm = $self->permission;
		$perm->load_permission('Permission Name');
		$perm->remove_user_permission($user);

=back

=cut
sub remove_user_permission
{
	my $self = shift;
	my ($user_id, $permission) = @_;

	if(!$user_id)
	{
		$@ = "User id is required";
		return undef;
	}

	if(ref($user_id) eq 'HASH')
	{
		if(defined($user_id->{'intranet_user_id'}))
		{
			$user_id = $user_id->{'intranet_user_id'};
		}
		else
		{
			$@ = "Invalid user format";
			return undef;
		}
	}

	# We need a permission id / name / hash or one needs to be loaded
	if(!$permission && !&_permission_is_loaded($self))
	{
		$@ = "No permission loaded or provided";
		return undef;
	}

	if($permission)
	{
		if(ref($permission) eq 'HASH')
		{
			if(defined($permission->{'intranet_permission_id'}))
			{
				$permission = $permission->{'intranet_permission_id'};
			}
			else
			{
				$@ = "Invalid permission format";
				return undef;
			}
		}
		$self->load_permission($permission);
	}

	# Validate this permission
	my $permission_id = $self->permission_info('intranet_permission_id');

	if(!$permission_id)
	{
		$@ = "Invalid permission";
		return undef;
	}

	# Just call it removed if they don't even have this user permission. No need to throw an error
	if(!$self->load_user_permission($user_id, $permission_id))
	{
		return 1;
	}

	if($self->db->table('intranet_user_permission_xref')->search({ 'intranet_user_id' => $user_id, 'permission_id' => $permission_id })->delete())
	{
		$self->unload_user_permission;
		return 1;
	}
	else
	{
		return undef;
	}
}

=head2 user_permission_info

=over 4

	Get or set user permission data

	Args   : $key_name, [ $key_value ]
	Returns: $key_value

	Examples:

		my $perm = $self->permission;
		my $user = $self->user('jweitz@fonality.com');
		$perm->load_user_permission($user, 'Permission Name');
		my $id = $perm->user_permission_info('id');

=back

=cut
sub user_permission_info
{
	my $self = shift;
	my ($key, $value) = @_;

	if(!$key)
	{
		$@ = "No permissoin key provided";
		return undef;
	}

	# Make sure that a user permission has been loaded
	if(!&_user_permission_is_loaded($self))
	{
		$@ = "NO user permission loaded";
		return undef;
	}

	# Do we need to update the key value?
	if(defined $value)
	{
		$self->{FONPermissions}->{_user_permission}->{$key} = &_save_user_permission_info($self, $key, $value);

		return $self->{FONPermissions}->{_user_permission}->{$key} ;
	}

	return $self->{FONPermissions}->{_user_permission}->{$key};
}

=head2 _save_user_permission_info

=over 4

	Private method used to update the database when changing user_permission_info key values

	Args   : $cgiapp, $key, $value
	Returns: $key_value

=back

=cut
sub _save_user_permission_info
{
	my $self = shift;
	my ($key, $value) = @_;

	if(!$key)
	{
		$@ = "No permission key provided";
		return undef;
	}

	if(!defined $value)
	{
		$@ = "Value is not defined";
		return undef;
	}

	if(!&_user_permission_is_loaded($self))
	{
		$@ = "User permission not loaded";
		return undef;
	}

	if($self->{'FONPermissions'}->{'_user_permission_resultset'})
	{
			$self->{'FONPermissions'}->{'_user_permission_resultset'}->set_columns({ $key => $value });

			if($self->{'FONPermissions'}->{'_user_permission_resultset'}->update())
			{
				return $value;
			}
			else
			{
				return $self->user_permission_info($key);
			}
	}
	else
	{
		$@ = "User permission result set is not available";
		return $self->user_permission_info($key);
	}
}

=head2 _user_permission_is_loaded

=over 4

	Private method used to determine if a user permission has been loaded

	Args   : none
	Returns: nothing

=back

=cut
sub _user_permission_is_loaded
{
	my $self = shift;
	return exists $self->{FONPermissions}->{_user_permission};
}

=head2 load_user_permission

=over 4

	Load a user permission into the instance and return the permission info.  

	Args   : $user_id_or_hash, [ $permission_id_name_or_hash ]
	Returns: $user_permission_hash or undef on failure

	Examples:

		# Load user permission named 'Permission Name' for user with username 'jweitz@fonality.com'
		my $user = $self->user->load_user('jweitz@fonality.com');
		my $perm = $self->permission;
		my $u_perm = $perm->load_user_permission($user, 'Permission Name');

		# Load user permission for permission loaded into a permission instance
		my $user = $self->user->load_user('jweitz@fonality.com');
		my $perm = $self->permission;
		$perm->load_permission('Permission Name');
		my $u_perm = $perm->load_user_permission($user);		

=back

=cut
sub load_user_permission
{
	my $self = shift;
	my ($user_id, $permission) = @_;

	$self->unload_user_permission;

	if(!$user_id)
	{
		$@ = "User id is required";
		return undef;
	}

	if(ref($user_id) eq 'HASH')
	{
		if(defined($user_id->{'intranet_user_id'}))
		{
			$user_id = $user_id->{'intranet_user_id'};
		}
		else
		{
			$@ = "Invalid user format";
			return undef;
		}
	}

	if(!$permission && !&_permission_is_loaded($self))
	{
		$@ = "No permission loaded or provided";
		return undef;
	}

	# If a permission id was provided, then load it up for verification
	if($permission)
	{
		if(ref($permission) eq 'HASH')
		{
			if(defined($permission->{'intranet_permission_id'}))
			{
				$permission = $permission->{'intranet_permission_id'};
			}
			else
			{
				$@ = "Invalid permission format";
				return undef;
			}
		}

		$self->load_permission($permission);
	}

	my $permission_id = $self->permission_info('intranet_permission_id');

	if(!$permission_id)
	{
		$@ = "Invalid permission";
		return undef;
	}

	my $res = $self->db->table('intranet_user_permission_xref')->search({ 'intranet_user_id' => $user_id, 'permission_id' => $permission_id }, { 'limit' => 1 });

	if($res && $res->first)
	{
		$self->{'FONPermissions'}->{'_user_permission_resultset'} = $res->first;
		my %perm_info = $res->first->get_columns;
		return $self->{'FONPermissions'}->{'_user_permission'} = \%perm_info;
	}
}

=head2 unload_user_permission

=over 4

	Private method used to clear any loaded user permission from the instance

	Args   : none
	Returns: nothing

=back

=cut
sub unload_user_permission
{
	my $self = shift;
	delete $self->{'FONPermissions'}->{'_user_permission'};
	delete $self->{'FONPermissions'}->{'_user_permission_resultset'};
}

=head2 add_permission_to_role

=over 4

	Adds a permission to the supplied or loaded role with the given access level ( r, w or rw )

	Args   :
		permission_id, role_id, permission_level

		or

		permission_hash, role_hash, permission_level

		or

		role_id => $role_id, permission_id => $permission_id, access => $permission_level


	Returns: True on success or undef on failure

	Examples:

		my $permission = $self->permission->load_permission(name => 'Some.Permission');
		my $role = $self->permission->load_role('Some Role');

		$self->permission->add_permission_to_role($permission, $role, 'r');

		||

		$self->permission->add_permission_to_role('Some.Permission', 'Some Role', 'rw');

		or

		my $p = $self->permission;

		$p->load_role('Some Role');
		$p->load_permission('Some.Permission');

		$p->add_permission_to_role($);


=back

=cut
sub add_permission_to_role
{
	my $self = shift;

	my %params;

	if(@_==1)
	{
		$params{'access'} = shift;
	}
	elsif(@_==3)
	{
		$params{'permission_id'} = shift;
		$params{'role_id'} = shift;
		$params{'access'} = shift;
	}
	else
	{
		%params = @_;
	}	

	if(ref($params{'role_id'}) eq 'HASH')
	{
		if(defined($params{'role_id'}->{'intranet_role_id'}))
		{
			$params{'role_id'} = $params{'role_id'}->{'intranet_role_id'};
		}
		else
		{
			$@ = "Invalid role format";
			return undef;
		}
	}

	if(ref($params{'permission_id'}) eq 'HASH')
	{
		if(defined($params{'permission_id'}->{'intranet_permission_id'}))
		{
			$params{'permission_id'} = $params{'permission_id'}->{'intranet_permission_id'};
		}
		else
		{
			$@ = "Invalid permission format";
			return undef;
		}
	}

	if(!$params{'role_id'} && !_role_is_loaded($self))
	{
		$@ = "No role id loaded or provided";
		return undef;
	}

	if(!$params{'permission_id'} && !_permission_is_loaded($self))
	{
		$@ = "No permission loaded or required";
		return undef;
	}

	if($params{'role_id'})
	{
		if($params{'role_id'} =~ /^\d+$/)
		{
			$self->load_role(intranet_role_id => $params{'role_id'});
		}
		else
		{
			$self->load_role(name => $params{'role_id'});
		}
	}

	my $role_id = $self->role_info('intranet_role_id');

	if(!$role_id)
	{
		$@ = "Invalid role";
		return undef;
	}

	if($params{'permission_id'})
	{
		if($params{'permission_id'} =~ /^\d+$/)
		{
			$self->load_permission(intranet_permission_id => $params{'permission_id'});
		}
		else
		{
			$self->load_permission(name => $params{'permission_id'});
		}
	}

	my $permission_id = $self->permission_info('intranet_permission_id');

	if(!$permission_id)
	{
		$@ = "Invalid permission";
		return undef;
	}
		
	# Just default the permission access level to read only
	$params{'access'} ||= 'r';

	if($params{'access'} !~ /^[rw]+$/)
	{
		$@ = "Invalid permission access level";
		return undef;
	}

	# Load or create a new intranet_role_xref row
	my $role_xref = $self->db->table('intranet_role_xref')->find_or_create({ 'role_id' => $role_id, 'permission_id' => $permission_id });

	if($role_xref)
	{
		$self->write_log(level => 'DEBUG', log => [ "GOING TO UPDATE ROLE $role_id PERM $permission_id to $params{'access'}" ]);
		$role_xref->set_columns({ 'access' => $params{'access'} });

		if($role_xref->update())
		{
			return 1;
		}

		return undef;

	}

	# This should not happen ( only if there is a DBIx problem )
	return undef;
}

=head2 remove_permission_from_role

=over 4

	Removes the provided or loaded permission from the provided or loaded role

	Args   : [ ( $permission_id_name_or_hash, $role_id_name_or_hash ) ] or key value pairs of [ ( permission_id => $permission_id_name_or hash, role_id => $rold_id_name_or_hash ) ]
	Returns: true on success or undef on failure

	Examples:

		# Remove loaded permission from loaded role
		my $perm = $self->permission;
		$perm->load_role('Role Name');
		$perm->load_permission('Permission Name');
		$perm->remove_permission_from_role;

		# Remove permission from role by id
		my $role = $self->permission->load_role('Role Name');
		my $perm = $self->permission->load_permission('Permission Name');
		$self->permission->remove_permission_from_role($permission, $role);

=back

=cut
sub remove_permission_from_role
{
	my $self = shift;
	my %params;

	if(@_==2)
	{
		$params{'permission_id'} = shift;
		$params{'role_id'} = shift;
	}
	else
	{
		%params = @_;
	}

	if(ref($params{'permission_id'}) eq 'HASH')
	{
		if(defined($params{'permission_id'}->{'intranet_permission_id'}))
		{
			$params{'permission_id'} = $params{'permission_id'}->{'intranet_permission_id'};
		}
		else
		{
			$@ = "Invalid permission format";
			return undef;
		}
	}

	if(ref($params{'role_id'}) eq 'HASH')
	{
		if(defined($params{'role_id'}->{'intranet_role_id'}))
		{
			$params{'role_id'} = $params{'role_id'}->{'intranet_role_id'};
		}
		else
		{
			$@ = "Invalid role format";
			return undef;
		}
	}

	if($params{'permission_id'})
	{
		if($params{'permission_id'} =~ /^\d+$/)
		{
			$self->load_permission(intranet_permission_id => $params{'permission_id'});
		}
		else
		{
			$self->load_permission(name => $params{'permission_id'});
		}
	}

	my $permission_id = $self->permission_info('intranet_permission_id');

	if(!$permission_id)
	{
		$@ = "Invalid permission";
		return undef;
	}

	if($params{'role_id'})
	{
		if($params{'role_id'} =~ /^\d+$/)
		{
			$self->load_role(intranet_role_id => $params{'role_id'});
		}
		else
		{
			$self->load_role(name => $params{'role_id'});
		}
	}
	
	my $role_id = $self->role_info('intranet_role_id');

	if(!$role_id)
	{
		$@ = "Invalid role";
		return undef;
	}

	if($self->db->table('intranet_role_xref')->search({ 'role_id' => $role_id, 'permission_id' => $permission_id })->delete())
	{
		return 1;
	}
	else
	{
		return undef;
	}
}

=head2 get_user_permissions

=over 4

	Get a list of all user permissions or single permission for the provided user

	Args   : $user_id_or_hash, [ $permission_id_name_or_hash ]
	Returns: listref of user permissions

=back

=cut
sub get_user_permissions
{
	my $self = shift;
	my ($user_id, $permission_id) = @_;

	# SQL args
	my @args;

	if(!$user_id)
	{
		$@ = "User id is required";
		return undef;
	}

	if(ref($user_id) eq 'HASH')
	{
		if(defined $user_id->{'intranet_user_id'})
		{
			$user_id = $user_id->{'intranet_user_id'};
		}
		else
		{
			$@ = "Invalid user format";
			return undef;
		}
	}

	# Handle permission_id
	if($permission_id)
	{
		# Convert permission hash to permission id
		if(ref($permission_id) eq 'HASH')
		{
			if(defined $permission_id->{'intranet_permission_id'})
			{
				$permission_id = $permission_id->{'intranet_permission_id'};
			}
			else
			{
				$@ = "Invalid permission format";
				return undef;
			}
		}

		# Verify this is a valid permission
		$self->load_permission($permission_id);

		$permission_id = $self->permission_info('intranet_permission_id');

		if(!$permission_id)
		{
			$@ = "Invalid permission";
			return undef;
		}
	}

	my $search = { 'intranet_user_permission_xrefs.intranet_user_id' => $user_id };

	if($permission_id)
	{
		$search->{'me.intranet_permission_id'} = $permission_id;
	}

	my @res = $self->db->table('intranet_permission')->search(
		$search,
		{
			'select' => [
				'me.intranet_permission_id',
				'me.name',
				'me.description',
				'me.parent_id',
				'intranet_user_permission_xrefs.intranet_user_permission_xref_id',
				'intranet_user_permission_xrefs.access',
				'intranet_user_permission_xrefs.permission_id',
				'intranet_user_permission_xrefs.intranet_user_id'
			],
			'as' => [
				'intranet_permission_id',
				'name',	
				'description',
				'parent_id',
				'intranet_user_permission_xref_id',
				'access',
				'permission_id',
				'intarnet_user_id'
			],
			'prefetch' => 'intranet_user_permission_xrefs',
			'order_by' => 'me.parent_id',
		}
	)->all;

	@res = $self->db->strip(@res) if @res;

	return \@res;
}

=head2 get_role_permissions

=over 4

	Get a list of all ( or defined ) permissions assigned to a role for the given or loaded role.

	Args   : [ $role_id_name_or_hash ], [ $permission_id_name_or_hash ]
	Returns: listref of all associated permissions

	Examples:

		# Get all permissions for role 'Role Name'
		my $perm_list = $self->permission->get_role_permissions('Role Name');

		# Load a role into an instance and retrieve permissions
		my $perm = $self->permission;
		$perm->load_role('Role Name');
		my $perm_list = $perm->get_role_permissions;

=back

=cut
sub get_role_permissions
{
	my $self = shift;
	my ($role_id, $permission_id) = @_;

	# SQL query arguments
	my @args;

	# If role wasn't provided, check to see if a role is loaded and use that role's id
	if(!$role_id)
	{
		if (_role_is_loaded($self))
		{
			$role_id = $self->role_info('intranet_role_id');
		}
		else
		{
			$@ = "Role is required";
			return undef;
		}
	}

	# Convert role hash to id
	if(ref($role_id) eq 'HASH')
	{
		if(defined($role_id->{'intranet_role_id'}))
		{
			$role_id = $role_id->{'intranet_role_id'};
		}
		else
		{
			$@ = "Invalid role format";
			return undef;
		}
	}

	# Handle permission_id
	if($permission_id)
	{
		if(ref($permission_id) eq 'HASH')
		{
			if(defined($permission_id->{'intranet_permission_id'}))
			{
				$permission_id = $permission_id->{'intranet_permission_id'};
			}
			else
			{
				$@ = "Invalid permission format";
				return undef;
			}
		}

		$permission_id = $self->load_permission($permission_id);
		$permission_id = $self->permission_info('intranet_permission_id');
	}

	# Search parameters
	my $search_params = { 'intranet_role_xrefs.role_id' => $role_id };

	# Alternate search by permission ID - to validate existence
	$search_params->{'me.permission_id'} = $permission_id if $permission_id;

	my @res = $self->db->table('intranet_permission')->search(
		$search_params,
		{
			'+select' => [
				'intranet_role_xrefs.access'
			],
			'+as'	=> [
				'access',
			],
			'join' => [
				'intranet_role_xrefs'
			],
			'order_by' =>
			{
				'-asc' => 'me.parent_id'
			},
		}
	)->all;

	@res = $self->db->strip(@res) if @res;

	return \@res;
}

=head2 get_role_users

=over 4

	Retrieve a list of all users that are members of a role.

	Args   : role
	Returns: arrayref of users

=back

=cut
sub get_role_users
{
	my $self = shift;
	my $role_id = shift;

	# SQL query arguments
	my @args;

	# If role wasn't provided, check to see if a role is loaded and use that role's id
	if(!$role_id)
	{
		if (_role_is_loaded($self))
		{
			$role_id = $self->role_info('intranet_role_id');
		}
		else
		{
			$@ = "Role is required";
			return undef;
		}
	}

	# Convert role hash to id
	if(ref($role_id) eq 'HASH')
	{
		if(defined($role_id->{'intranet_role_id'}))
		{
			$role_id = $role_id->{'intranet_role_id'};
		}
		else
		{
			$@ = "Invalid role format";
			return undef;
		}
	}

	if(!$role_id)
	{
		$@ = "Role id is required";
		return undef;
	}

	my @res = $self->db->table('intranet_user_role_xref')->search({ 'role_id' => $role_id })->all;

	@res = $self->db->strip(@res) if @res;

	return \@res;
}

=head2 get_permissions_list

=over 4

	Retrieve a hash containing all permissions in the framework.

	The returned hash contains:

		Key ROLE_XREF which is used to determine parent permissions and hierarchy

		Key PERMISSIONS contains all permissions and their child permissions which will contain their own PERMISSOINS key if applicable.

		Here is what the hash might look like:

		PERMISSIONS' => {
			'Sales.Test' => { # This would be a module / application access permission
			       'DESC' => 'Sales Test Module',
			       'LEVEL' => 'w'
                         },
			'Billing.Netsuite.Order_Tracker' => { # Base module permission with child permission
				'PERMISSIONS' => {
					'View Connect+ Orders' => {
						'DESC' => 'View New Connect+ Orders in the Example Netsuite Application',
						'LEVEL' => 'rw'
					},
				}
				'DESC' => 'NetSuite Order Tracker',
				'LEVEL' => 'w'
			}
		}

	Args   : none
	Returns: hashref of permissions

=back

=cut
sub get_permissions_list
{
	my $self = shift;

	my $permission_list = $self->load_permission;

	my %permissions;

	foreach my $p ( @{$permission_list} )
	{
		# get_role_permissions will return an empty array ( to be friendly to other methods ) so just skip if $p is empty
		next unless $p;

		# Add this permission to the XREF table
		$permissions{'ROLE_XREF'}{$p->{'intranet_permission_id'}} = { NAME => $p->{'name'}, PARENT => $p->{'parent_id'} };

		# If we don't have a parent already defined, there is no way to add this permission to the hash
		if($p->{'parent_id'} > 0 && !exists($permissions{'ROLE_XREF'}{$p->{'parent_id'}}))
		{
			next;
		}

		my $parent_id = $p->{'parent_id'};

		my $p_table = \%permissions;

		while($parent_id)
		{
			# For readability's sake, get the parent's permission key and store it here
			my $parent_key = $permissions{'ROLE_XREF'}{$parent_id}{'NAME'};

			# Change the reference to the parent's permission key
			$p_table = $p_table->{'PERMISSIONS'}->{$parent_key};

			# Check for an additional parent
			$parent_id = $permissions{'ROLE_XREF'}{$parent_id}{'PARENT'};
		}

		# If we already have this permission available, only redefine it if we've got a write permission
		if(exists($p_table->{'PERMISSIONS'}->{$p->{'name'}}) && defined($p_table->{'PERMISSIONS'}->{$p->{'name'}}) && $p->{'access'} eq 'r')
		{
			next;
		}

		$p_table->{PERMISSIONS}->{$p->{'name'}} = {
			LEVEL => $p->{'access'},
			DESC => $p->{'description'}
		};
	}

	return \%permissions;
	

}

=head2 get_permissions_by_user

=over 4

	Retrieve a user permission hash for the given user including both role and user specific permissions.

	A single permission can also be returned by passing a second argument containing permission name, id or hash.

	The format will be the same as get_permissions_list produces.


	Args   : $user_id_or_hash, [ $permission_id_name_or_hash ]
	Returns: User permission hash or undef if no permissions are found

=back

=cut
sub get_permissions_by_user
{
	my $self = shift;
	my ($user_id, $permission_id) = @_;

	if(!$user_id)
	{
		$@ = "User id is required";
		return undef;
	}

	if(ref($user_id) eq 'HASH')
	{
		if(defined($user_id->{'intranet_user_id'}))
		{
			$user_id = $user_id->{'intranet_user_id'};
		}
		else
		{
			$@ = "Invalid user format";
			return undef;
		}
	}
	my $key = "intranet_permissions_$user_id";
	my $ret = $self->db->cache->get($key);
	return $ret if ($ret);
	# Get a list of all user roles
	my $roles = $self->get_user_roles($user_id);

	if(!@{$roles})
	{
		return undef;
	}

	# Store premissions here
	my %permissions;

	# Hold all permissions here
	my @permission_list;

	foreach my $role ( @{$roles} )
	{
		my $role_permissions = $self->get_role_permissions($role->{'intranet_role_id'}, $permission_id);
		push(@permission_list, @{$role_permissions}) if ( $role_permissions && ref($role_permissions) eq 'ARRAY' );
	}

	if(my $user_permissions = $self->get_user_permissions($user_id))
	{
		push(@permission_list, @{$user_permissions});
	}

	foreach my $p ( @permission_list )
	{
		# get_role_permissions will return an empty array ( to be friendly to other methods ) so just skip if $p is empty
		next unless $p;

		# Add this permission to the XREF table
		$permissions{'ROLE_XREF'}{$p->{'intranet_permission_id'}} = { NAME => $p->{'name'}, PARENT => $p->{'parent_id'} };

		# If we don't have a parent already defined, there is no way to add this permission to the hash
		if($p->{'parent_id'} > 0 && !exists($permissions{'ROLE_XREF'}{$p->{'parent_id'}}))
		{
			next;
		}

		my $parent_id = $p->{'parent_id'};

		my $p_table = \%permissions;

		while($parent_id)
		{
			# For readability's sake, get the parent's permission key and store it here
			my $parent_key = $permissions{'ROLE_XREF'}{$parent_id}{'NAME'};

			# Change the reference to the parent's permission key
			$p_table = $p_table->{'PERMISSIONS'}->{$parent_key};

			# Check for an additional parent
			$parent_id = $permissions{'ROLE_XREF'}{$parent_id}{'PARENT'};
		}

		# If we already have this permission available, only redefine it if we've got a write permission
		if(exists($p_table->{'PERMISSIONS'}->{$p->{'name'}}) && defined($p_table->{'PERMISSIONS'}->{$p->{'name'}}) && $p->{'access'} eq 'r')
		{
			next;
		}

		$p_table->{PERMISSIONS}->{$p->{'name'}} = {
			LEVEL => $p->{'access'},
			DESC => $p->{'description'}
		};
	}

	$self->db->cache->set($key,\%permissions,300);
	return \%permissions;
	
}

=head2 get_user_roles

=over 4

	Retrieve a listref of all roles that a given user is assigned to

	Args   : $user_id_or_hash
	Returns: listref of roles or undef on failure

=back

=cut
sub get_user_roles
{
	my $self = shift;
	my $user_id = shift;

	if(!$user_id)
	{
		$@ = "User id is required";
		return undef;
	}

	if(ref($user_id) eq 'HASH')
	{
		if(defined($user_id->{'intranet_user_id'}))
		{
			$user_id = $user_id->{'intranet_user_id'};
		}
		else
		{
			$@ = "Invalid user format";
			return undef;
		}
	}

	my @res = $self->db->table('intranet_role')->search(
		{ 'intranet_user_role_xrefs.intranet_user_id' => $user_id },
		{ 
			'select' => [
				'me.intranet_role_id',
				'intranet_user_role_xrefs.intranet_user_id',
				'intranet_user_role_xrefs.role_id',
				'me.name',
				'me.description',
			],
			'as' => [
				'intranet_role_id',
				'intranet_user_id',
				'role_id',
				'name',
				'description',
			],
			, 'prefetch' => 'intranet_user_role_xrefs'
		}
	)->all;

	@res = $self->db->strip(@res) if @res;

	return \@res;

}

1;
