#!/usr/bin/perl

use strict;
use Sub::Delete;

sub process_Rebuild_Database
{
	my $self = shift;

	$self->title('Framework permission and search database rebuild application');

	# Get application list including Core apps
	my $apps = $self->_build_menu_hash(1);

	# Get entire permission list
	my $permissions = $self->permission->get_permissions_list;

	# We'll store left over child permissions here
	my %child_perms;

	# We'll store add and update status here
	my %new_perms;

	# Store applications that had a searchable method found in them here
	my $searchable_apps = $self->get_searchable_applications();
	my @searchable = @{$searchable_apps};

	# Cycle through our menu list	
	foreach my $cat ( keys %{$apps} )
	{
		foreach my $subcat ( keys %{$apps->{$cat}} )
		{
			foreach my $app ( keys %{$apps->{$cat}->{$subcat}} )
			{
				my $app_path;
				my $app_name;

				if($subcat eq 'Base')
				{
					$app_path = $cat . '/' . $app . '.pm';
					$app_name = $cat . '.' . $app;
				}
				else
				{
					$app_path = $cat . '/' . $subcat . '/' . $app . '.pm';
					$app_name = $cat . '.' . $subcat . '.' . $app;
				}

				# We don't need to rebuild ourself
				next if $app_path eq 'Admin/Rebuild_Database.pm';

				# Get the current child permissions for this app
				$child_perms{$app_name} = $permissions->{PERMISSIONS}->{$app_name}->{PERMISSIONS} if $permissions->{PERMISSIONS}->{$app_name}->{PERMISSIONS};

				$self->write_log(level => 'DEBUG', log => "Going to rebuild database for $app_path ( $app_name )");

				# Remove the init methods, otherwise, we will use the previous application's methods if the required app doesn't have one
				#delete_sub __PACKAGE__."::init_searchable";
				*init_permissions = undef;
				*init_searchable = undef;

				# Load up the application
				require('applications/'.$app_path);
				my $current_permissions = init_permissions();

				if(__PACKAGE__->can('init_searchable'))
				{
					&init_searchable($self);

					if(grep { $_->{'mode'} eq $app_name } @searchable)
					{
						map {
							$_->{'updated'} = 1 if $_->{'mode'} eq $app_name;
						} @searchable;
					}
					else
					{
						push(@searchable, { mode => $app_name, added => 1 });
					}
				}
				else
				{
					if($self->remove_searchable_application($app_name))
					{
						map {
							$_->{'removed'} = 1 if $_->{'mode'} eq $app_name;
						} @searchable;
					}
					else
					{
						$self->write_log(level => 'ERROR', log => "Could not remove searchable app: $@");
					}
				}	

				# Get current module permissions as seen by the framework
				#my $current_permissions = $self->get_module_permissions($app_name, 1);
				if($self->seed_permissions($app_name, $current_permissions))
				{
					$self->write_log(level => 'VERBOSE', log => [ "SEEDED permissions for $app_name", $current_permissions ]);
				}
				else
				{
					$self->write_log(level => 'ERROR', log => "Could not SEED permissions for $app_name: $@");
				}
	
				# Populate added or updated for the application
				if($permissions->{'PERMISSIONS'}->{$app_name})
				{
					$new_perms{$app_name}{'updated'} = 1;
				}
				else
				{
					$new_perms{$app_name}{'added'} = 1;
				}

				# Populate added or updated for each child permission
				foreach my $c ( keys %{$current_permissions->{'PERMISSIONS'}} )
				{
					if($permissions->{'PERMISSIONS'}->{$app_name}->{'PERMISSIONS'}->{$c})
					{
						$new_perms{$app_name}{'PERMISSIONS'}{$c}{'updated'} = 1;
					}
					else
					{
						$new_perms{$app_name}{'PERMISSIONS'}{$c}{'added'} = 1;
					}
				}

				# Remove this app from the permissions list since we're rebuilding it
				delete $permissions->{'PERMISSIONS'}->{$app_name};

				# Remove valid child permissions from the child list
				foreach my $child ( keys %{$current_permissions->{PERMISSIONS}} )
				{
					delete $child_perms{$app_name}->{$child};
				}
			}
		}
	}

	# Remove ourself from the list of parents to remove
	delete $permissions->{PERMISSIONS}->{'Admin.Rebuild_Database'};

	$self->write_log(level => 'DEBUG', log => [ "Left over permissions", $permissions->{PERMISSIONS}, "Left over child permissions", \%child_perms, "UPDATE STATUS", \%new_perms ]);

	# Remove dead children permissions
	foreach my $parent ( keys %child_perms )
	{
		foreach my $child ( keys %{$child_perms{$parent}} )
		{
			$self->write_log(level => 'DEBUG', log => "Remove child permission $child FROM parent $parent");

			if($self->permission->remove_permission($child, $parent))
			{
				$self->write_log(level => 'VERBOSE', log => "Removed child permission from parent $parent");
				$child_perms{$parent}->{$child}->{'removed'} = 1;
			}
			else
			{
				$self->write_log(level => 'ERROR', log => "Could not remove child permission from parent $parent: $@");
				$self->alert("Could not remove child permission from parent $parent");
			}
		}
	}

	# Remove dead parent permissions
	foreach my $p ( keys %{$permissions->{PERMISSIONS}} )
	{
		if($self->permission->remove_permission($p))
		{
			$self->write_log(level => 'VERBOSE', log => "Removed parent permission $p");
			$permissions->{PERMISSIONS}->{$p}->{removed} = 1;
		}
		else
		{
			$self->write_log(level => 'ERROR', log => "Could not remove parent permission $p: $@");
			$self->alert("Could not remove parent permission $p $@");
		}
	}

	# Append template vars
	$self->tt_append(var => 'CHILD_PERMS', val => \%child_perms);
	$self->tt_append(var => 'PARENT_PERMS', val => $permissions->{PERMISSIONS});
	$self->tt_append(var => 'NEW_PERMS', val => \%new_perms);
	$self->tt_append(var => 'SEARCH_UPDATES', val => \@searchable);

	$self->write_log(level => 'DEBUG', log => "PACKAGE " . __PACKAGE__);
	return $self->tt_process('Admin/Rebuild_Database.tt');
}

sub Admin_Rebuild_Database_init_permissions
{
	my $self = shift || return undef;

	my $perm = {
		VERSION => 2,
		DESC => "Rebuild permission and search database",
		LEVELS => 'r',
		GLOBAL => 1,
	};

	return $perm;
}

1;
