#!/usr/bin/perl
# Start of documentation header 
 
=head1 NAME 
 
Fap::WebApp::Intranet
 
=head1 VERSION 
 
$Id: Intranet.pm 2376 2013-03-21 21:48:15Z jweitz $ 
 
=head1 SYNOPSIS 
 
use Fap::WebApp::Intranet;
my $intranet = Fap::WebApp::Intranet->new();
$intranet->run();

=head1 DESCRIPTION 

=over 4

	This is the main intranet module utilizing CGI::Application.

	All applications are run using this module which contains the core functionality of the Intranet framework.

	An entry script index.cgi initializes and runs the CGI::Application.

=back

=head1 CLASS METHODS

=over 4

Method usage.

=back

=cut 
package Fap::WebApp::Intranet;
BEGIN {
	print STDERR "COMPILING WEBAPP!\n";
}
print STDERR "HI THERE\n\n\n";
use Fap::WebApp;
use base 'Fap::WebApp';

use strict;

# CGI Application Plugins ( Published )
#use CGI::Application::Plugin::Apache qw(:all);
use CGI::Application::Plugin::TT;
use CGI::Application::Plugin::Session;
use Time::HiRes;
# Fonality specific CGI::APP / Intranet Plugins
use Fap::WebApp::Intranet::Log;
use Fap::WebApp::Intranet::Config; 
use Fap::WebApp::Intranet::Validation;
use Fap::WebApp::Intranet::Mail;
use Fap::WebApp::Intranet::Search;
use Fap::WebApp::Intranet::Permissions;
use Fap::WebApp::Intranet::User;

# Fonality Fap
use Fap;
use Fap::Model::Fcs;

# Other modules
use Data::Dumper;
use File::Find::Rule;
use JSON;
use POSIX 'strftime';

=head2 cgiapp_init

=over 4

	This hook should contain all of the various CGI::Application configuration settings.

	This includes Plugin configuration, such as CGI::Application::Plugin::Session.

=back

=head3 Defining application and tt paths

=over 4

	You can init Fap::WebApp::Intranet with a framework_name parameter which will allow you to set different application and tt paths for the given framework name.

	For example:

		my $framework = Fap::WebApp::Intranet->new(PARAMS => { framework_name => 'Public_System' });
		$framework->run();

	This will allow you to set the following configuration params:

		'Public_System.application_path'
		'Public_System.tt_path'

	The framework will then use these directories to locate applications and templates, allowing you to easily separate the framework from the application specific code.

	Here is an example:

		my $framework = Fap::WebApp::Intranet->new(PARAMS => { framework_name => 'Public_System' });

		$framework->config('Public_System.application_path', '/var/www/html/Public_System/applications');
		$framework->config('Public_System.tt_path', '/var/www/html/Public_System/tt');

		$framework->run();

		So regardless of the path of the initializing script, applications can be separately located in a different location.  You will only need an index.cgi and whatever image, css, js or other files you need to render your pages.

		If not using a framework_name, the config key path.application_path and path.tt_path will be used or defaulted to ./applications and ./tt directories.

=back

=cut

sub cgiapp_init
{
	my $self = shift;
	# Display errors using the display_error function
	$self->error_mode('display_error');

	# Set application and TT paths
	#$self->{'application_path'} = $self->config($self->{__PARAMS}->{framework_name} . '.application_path') || $self->config('path.application_path') || './applications';
	$self->{application_path} = Fap->path_to("lib/Fap/WebApp/Action");
	$self->{'tt_path'} = Fap->path_to("templates/tt");# $self->config($self->{__PARAMS}->{framework_name} . '.tt_path') || $self->config('path.tt_path') || './tt';

	# Set TT options
	my $opts = {
                        #POST_CHOMP   => 1,
                        TRIM         => 1,
                        PRE_CHOMP    => 1,
                        INCLUDE_PATH => [Fap->path_to("templates/tt"),$self->{'tt_path'}.'/UI', $self->{'tt_path'}.'/email' ],
                        RECURSIVE    => 1,
                        COMPILE_DIR  => Fap->tmp_dir, # Permissions on web-dev2 prevent this from working
                };
	if ($ENV{MOD_PERL}) {
		$opts->{COMPILE_DIR} = Fap->tmp_dir;
	}

	$self->tt_config(
		TEMPLATE_OPTIONS => $opts,
	);

	# This will handle checking permissions via the template
	$self->tt_obj->context->define_vmethod(
		'hash', 'can', sub {
			return $self->check_permissions(@_);
		}
	);

	# Setup the session handler
	$self->{_cookie_expires} = $self->config('cookie_expiry') || '+24h';
	$self->{_cookie_path} = $self->config('cookie_path') || '/';

	$self->session_config(
		CGI_SESSION_OPTIONS	=> [
						'driver:File;serializer:MessagePack',
						$self->query,
						{Directory=>"/dev/shm/sessions"},
						#{
							#IdColName	=> 'guid',
							#DataColName	=> 'session',
							#ResultSet => $self->db->schema->resultset('IntranetSession'),
						#},
					],
		DEFAULT_EXPIRY		=> $self->{_cookie_expires},
		COOKIE_PARAMS		=> {
						-expires	=> $self->{_cookie_expires},
						-path		=> $self->{_cookie_path},	
		},
		SEND_COOKIE		=> 1,
	);
}

=head2 setup

=over 4

	CGI::Application setup callback.

	Defines default start mode and function to retrieve requested mode using CGI::App::Plugin::FONValidation

	See CGI::Application perldoc for more info

=back

=cut
sub setup
{
	my $self = shift;

	$self->start_mode('Core.Main');
	$self->mode_param(sub { my $self = shift; return $self->valid->param('mode') || $self->valid->param('m'); });
	$self->run_modes({
		AUTOLOAD	=> \&auto_load,
	});
}

=head2 cgiapp_postrun

=over 4

	This hook is called after everything has run.  Use this for any cleanup that might be necessary.

=back

=cut
sub cgiapp_postrun
{
	my $self = shift;
	$self->session->flush if $self->session_loaded;
}

=head2 cgiapp_prerun

=over 4

	This hook is run after initialization but before any applications ( run modes ) are executed.

	Logging of user access and password expiration handling is done here.

=back

=cut
sub cgiapp_prerun
{
	my $self = shift;
	
	# Authentication check here


	if( $self->{'username'} = $self->check_auth() )
	{
		$self->write_log(level => 'DEBUG', log => "Access authenticated for $self->{'username'}.");

		# Make sure that this user has not been disabled
		if($self->user($self->check_auth)->is_disabled)
		{
			$self->write_log(level => 'VERBOSE', log => "User is disabled - killing session and sending to log in page");
			$self->session->delete;
			$self->session->flush;
			$self->prerun_mode('Core.Login');
		}

		# Check for expired password and redirect the user to the reset password form
		if($self->session->param('password_expired'))
		{
			$self->write_log(level => 'VERBOSE', log => "Password is expired, redirecting to update password.");
			$self->prerun_mode('Core.Reset_Password');
			$self->alert('Your password has expired, please create a new password.');
		}
	}
	else
	{

		#if(!$self->{__PARAMS}->{ALLOW_GUESTS})
		#{
			#$self->prerun_mode('Core.Login');
		#}
	}
}

=head2 tt_pre_process

=over 4

	This hook is run immediately before a template is processed.

	Currently, this hook handles:

		* Exceptions for missing template files to display a friendly error message.
		* Adds TT_DUMP variable to the template which contains Data::Dumper output of all template variables if log.TT_DUMP is enabled.
		* Builds the navigation menu hash

	The variables passed to this method are:

		1. CGI::App instance
		2. Template file that will be processed
		3. Template variables.

	See CGI::Application::Plugin:TT for more information.		

=back

=cut
sub tt_pre_process
{
	my($self, $file, $vars) = @_;

	$self->write_log(level => 'DEBUG', log => [ "Going to process template $file" ]);	

	my $tt_config = $self->tt_config();

	my $template_exists = grep { -e $_ . '/' . $file } @{$tt_config->{TEMPLATE_OPTIONS}->{INCLUDE_PATH}};
	$self->write_log(level => 'DEBUG', log => "TEMPLATE EXISTS: $template_exists");

	# Make sure the template exists
	if(!$template_exists)
	{
		$self->write_log(level => 'ERROR', log => "Template file $file does not exist.");

		if(grep { -e $_ . '/error.tt' } @{$tt_config->{TEMPLATE_OPTIONS}->{INCLUDE_PATH}})
		{
			return $self->display_error('The requested template could not be found.');
		}
		else
		{
			$self->write_log(level => 'ERROR', log => "The error.tt template could not be found");
			return $self->show_error("The requested template could not be found. Additionally, the error template could  not be found.");
		}
	}

	# Build menu hash
	my $menu = $self->_build_menu_hash();

	# Retrieve all form data
	my %form_data;

	foreach my $param ( $self->query->param )
	{
		$form_data{$param} = $self->valid->param($param);
		$self->write_log(level => 'DEBUG', log => "PARAM: $param");
	}

	# Add template vars debug hash dump
	if($vars && keys %{$vars})
	{
		# Add session variables to the template
		$vars->{'SESSION'} = $self->session->param_hashref();

		if($self->session->param('username'))
		{
			$vars->{'USER_INFO'} = $self->user->load_user($self->session->param('username'));
		}	
		# Add data dumper
		$vars->{'TT_VAR_DUMP'} = Dumper( $vars ) if $self->config('log.TTDUMP');

		# Add menu
		$vars->{'NAV_MENU'} = $menu;

		# Add form data
		$vars->{'FORM'} = \%form_data;

		$self->tt_params($vars);
	}
	else
	{
		# Add session variables to the template
		$self->{'tt_vars'}->{'SESSION'} = $self->session->param_hashref();

		if($self->session->param('username'))
		{
			$self->{'tt_vars'}->{'USER_INFO'} = $self->user->load_user($self->session->param('username'));
		}

		# Add menu
		$self->{'tt_vars'}->{'NAV_MENU'} = $menu;

		# Add form data
		$self->{'tt_vars'}->{'FORM'} = \%form_data;

		# Add data dumper
		$self->{'tt_vars'}->{'TT_VAR_DUMP'} = Dumper( $self->{tt_vars} ) if $self->config('log.TTDUMP');
		$self->tt_params($self->{tt_vars});
	}
	return;
}

sub tt_post_process {
    my ($self, $htmlref) = @_;
	$self->{output} = $$htmlref;
    return;
  }

=head2 auto_load

=over 4

	This method is used by CGI::Application to load the application specified in the mode parameter.

	The module name should be in the format:

		* Module_Name
			Loads module: applications/Module_Name.pm

		* Directory.Module_Name
			Loads module: applications/Directory/Module_Name.pm

		* Directory.Directory2.Module_Name
			Loads module: applications/Directory/Directory2/Module_Name.pm


	If the application is not found, an error message will be displayed.

	If the application is found, it will be loaded and executed.

	Args   : mode
	Returns: nothing

=back

=cut
sub auto_load
{
	my $self = shift;
	my $mode = shift;
	my $no_run = shift;

	my $t = Time::HiRes::time;

	my @dir;
	if (length("$ENV{SCRIPT_NAME}$ENV{PATH_INFO}") && 0) {
		@dir = split("/",substr("$ENV{SCRIPT_NAME}$ENV{PATH_INFO}",1));
		$mode = join(".",@dir);
	} else {
	 	@dir = split('\.', $mode);
	}

	my $module_path = join('/', @dir);
	my $mode_function = "process_" . $dir[-1];
	my $module_name = $dir[-1];
	my $ret;
	my $exetime=0;
	my $loadtime = 0;

	

	$self->write_log(level => 'VERBOSE', log => "Trying to run $mode via AUTOLOAD located in $module_path.pm" );
	$self->write_log(level => 'VERBOSE', log => "PATH: " . $self->{'application_path'} . "/$module_path.pm" );

	if( -f $self->{'application_path'} . "/$module_path.pm" )
	{
		$self->write_log(level => 'VERBOSE', log => "Found applications/$module_path.pm - Going to load it.");
		my $t = Time::HiRes::time();
		require( $self->{'application_path'} . "/$module_path.pm" );
		$loadtime = Time::HiRes::time-$t;
	}
	else
	{
		my $error = "Application does not exist.";
		$self->write_log(level => 'ERROR', log => $error . ' : ' . $module_path );
		$ret = $self->display_error( $error );
	}

	# Verify that we have permission to run this module

	my $perms = $self->get_module_permissions($mode);
	my $t = Time::HiRes::time();
	my $has = $self->has_module_permissions($mode);
	 print STDERR "$ENV{REQUEST_URI} has perms: ".( Time::HiRes::time-$t)."\n";

	
	

	if($perms && $has) {
		#$self->get_module_permissions($mode) && $self->has_module_permissions($mode))
		# Make sure that we've actually loaded a module with the proper method available
		if(__PACKAGE__->can($mode_function))
		{
			my $t = Time::HiRes::time();
			$self->{'_APPLICATION'} = $mode;
			$self->{'autoload'}->{$mode_function} = \&$mode_function;
			$self->{'autoload'}->{$mode_function}($self);
			$exetime = Time::HiRes::time()-$t;
		}
		else
		{
			$self->write_log(level => 'ERROR', log => "Cannot run requested mode $mode because entry point method does not exist.");
			$ret =  $self->display_error("Cannot run that mode");
		}
	}
	else
	{
		$self->write_log(level => 'WARN', log => "No permission to run $module_name");

		# If the user is not logged in, then send to the login page
		if( !$self->check_auth() )
		{
			$ret =  $self->auto_load('Core.Login');
		}

		$ret =  $self->display_error("You do not have permission to run this application.");
	}
	print STDERR "$mode_function ($ENV{HTTP_REFERER}): $loadtime/$exetime/".(Time::HiRes::time()-$t)."\n";
	print STDERR join(", ",map {"$_ = ".$self->query->param($_)} $self->query->param );
}


=head2 get_module_permissions

=over 4

	Add the given module's permissions to the _PERMISSIONS hash.

	Each module should contain a method called init_permissions which contains a listref of permissions.

	sub init_permissions
	{
	        my($self, $module_name) = @_; # If you need to, you can retrieve data from the database or something using the Intranet instance and $module name

	        my $perm = {
	                GLOBAL => 0, # Any logged in user has access?
	                MODULE => 'Sales.Test', # Module permission name ( optional, to be used to inherit another module's perms or if module name has changed )
	                PERMISSIONS => # Application Permissoins
	                {
	                        'support_contracts' => 
	                        {
	                                LEVELS => ['r', 'w'], # r = Read, w = Write
	                                NAME => 'Customer Support Contracts', # Name to be displayed in permission management application
	                                DESC => 'View or Edit Customer Support Contracts', # Description to be displayed in the permission management application
	                                PERMISSIONS => # Child permissions ( Children may not have children of their own )
	                                {
	                                        'change_date' =>
	                                        {
	                                                LEVELS => ['w'],
	                                                NAME => 'Support Date',
	                                                DESC => 'Edit Support Contract Start or End Dates'
	                                        },
	                                        'change_level' =>
	                                        {
	                                                LEVELS => ['w'],
	                                                NAME => 'Support Level',
	                                                DESC => 'Edit Support Level'
	                                        }
	                                }
	                        }
	                }
	        };

	        return $perm;
	}

	Note: There will always be a permission for the module itself, _PERMISSIONS->{$module_name}.


	Args   : $module_name
	Returns: true on success or undef on failure

=back

=cut
sub get_module_permissions
{
	my $self = shift;
	my $module_name = shift;
	my $force = shift;

	my $t = Time::HiRes::time();

	# Build the permission method name
	my $permission_method = $module_name . '_init_permissions';
	$permission_method =~ s/\./_/g;
	my $key = "module_permissions_$module_name-$force";
	my $ret = $self->db->cache->get($key);
	if ($ret) {
		$self->{_MODULE_PERMISSIONS}->{$module_name} = $ret;
		return $ret;
	}

	# Make sure that this module has an init_permissions method
	if(__PACKAGE__->can($permission_method))
	{
		if(!$self->{'_permission_methods'}{$module_name})
		{
			$self->{'_permission_methods'}{$module_name} = \&$permission_method;
		}

		$self->{_MODULE_PERMISSIONS}->{$module_name} = $self->{'_permission_methods'}{$module_name}($self, $module_name) || {};

		# Get last known permission version
		my $last_version = $self->config('permission_version.'.$module_name) || 0;
		my $current_version = $self->{_MODULE_PERMISSIONS}->{$module_name}->{VERSION} || 1;

		if($current_version > $last_version || $force)
		{
			$self->write_log(level => 'VERBOSE', log => "Seeding permissions for $module_name ( existing version: $last_version, new version: $current_version, Force: $force )");

			if($self->seed_permissions($module_name, $self->{_MODULE_PERMISSIONS}->{$module_name}))
			{
				$self->config('permission_version.'.$module_name, $current_version);
			}
		}
		else
		{
			$self->write_log(level => 'DEBUG', log => "Permissions are up to date for $module_name ( version $current_version, force: $force )");
		}

		$ret =  $self->{_MODULE_PERMISSIONS}->{$module_name} = $self->{'_permission_methods'}{$module_name}($self, $module_name) || {};
	}
	else
	{
		$self->write_log(level => 'WARN', log => "No init_permissions method found in $module_name");
		$@ = "Module $module_name is missing an init_permissions method";
		$ret =  undef;
	}
	if ($ret) {
		$self->db->cache->set($key,$ret,600);
	}
	return $ret;
}


=head2 check_permissions

=over 4

	This is used by the template to validate permissions.

	Use it like so from a template:

		[% IF PERMISSION.can('r') %]
			BASIC APPLICATION LEVEL READ PERMISSION
		[% END %]

		[% IF PERMISSION.can('some_child_permission', 'w') %]
			HAS CHILD PERMISSION some_child_permission WITH WRITE LEVEL
		[% END %]

		[% IF PERMISSION.can('r', undef, 'Billing.Support_Contracts') %]
			HAS READ ACCESS TO Billing.Support_Contracts APPLICATION
		[% END %]

		[% IF PERMISSION.can('some_child_permission', 'w', 'Billing.Support_Contracts') %]
			HAS WRITE ACCESS TO some_child_permission in the Billing.Support_Contracts APPLICATION %]
		[% END %]

	To check permissions from an application, use has_permission instead.

	Admittedly, this code could be slightly less 'verbose', but I'm leaving it this way for readability.

=back

=cut
sub check_permissions
{
	my $self = shift;
	my ($perm, $level, $app);

	my $permissions = shift;

	my $t = Time::HiRes::time();
	my $ret;
	#my $ret = $self->db->cache->get("check_permissions_".


	# Make sure we have a permission hash
	if(!$permissions || ref($permissions) ne 'HASH')
	{
		$ret =  undef;
	}

	# If we only have one argument, it's the permission level to check for on basic application permissions
	if(@_==1)
	{
		$level = shift;
	}
	else
	{
		($perm, $level, $app) = @_;
		if(!$level && ($perm eq 'r' || $perm eq 'w'))
		{
			$level = $perm;
			$perm = undef;
		}
	}

	# If we're looking for a specific app's perms..
	if($app)
	{
		$permissions = $permissions->{$app};
	}
	else
	{
		$permissions = $permissions->{$self->{_APPLICATION}};
	}


	# Default level is read
	$level ||= 'r';
	$self->write_log(level => 'DEBUG', log => [ "Checking these perms for $level access ( to $perm ):", $permissions ]);

	# Look for specific perm
	if($perm)
	{
		$permissions = $permissions->{PERMISSIONS};

		if($level eq 'r')
		{
			if ($permissions->{$perm}->{LEVEL} && ( $permissions->{$perm}->{LEVEL} eq 'r' || $permissions->{$perm}->{LEVEL} eq 'w'))
			{
				$ret =  1;
			}
			else
			{
				$ret =  undef;
			}
		}
		else
		{
			if($permissions->{$perm}->{LEVEL} && $permissions->{$perm}->{LEVEL} eq 'w')
			{
				$ret =  1;
			}
			else
			{
				$ret =  undef;
			}
		}
	}
	else
	{
		if($level eq 'r')
		{
			if($permissions->{LEVEL} && ( $permissions->{LEVEL} eq 'r' || $permissions->{LEVEL} eq 'w'))
			{
				$ret =  1;
			}
			else
			{
				# Check for global permission level ( which is always considered read )
				$ret =  ( $permissions->{GLOBAL} == 1 )?1 : undef;
			}
		}
		if($level eq 'w')
		{
			if($permissions->{'LEVEL'} && ( $permissions->{'LEVEL'} eq 'w' ))
			{
				$ret = 1;
			}
			else
			{
				$ret = undef;
			}
		}
	}

	return $ret;
}

=head2 has_permission

=over 4

	Use this method from your applications to handle permission access.

	Usage:

	if($self->has_permissions('r'))
	{
		# Basic application level read permission
	}

	if($self->has_permissions('some_child_permission', 'w'))
	{
		# Write level child permission for some_child_permission
	}

=back

=cut
sub has_permission
{
	my $self = shift;
	return $self->check_permissions($self->{_PERMISSIONS}->{PERMISSIONS}, @_);
	#return $self->check_permissions($self->{_APPLICATION_PERMISSIONS}, @_);
}

=head2 seed_permissions

=over 4

	This method seeds the permission database for a module.  This should be run if the permission version has changed.

	Args   : $perm_hash_ref
	Returns: true on success or undef on failure

=back

=cut
sub seed_permissions
{
	my $self = shift;
	my $module = shift;
	my $perm = shift;

	my $ret;

	if(!$module)
	{
		$@ = "Module name is required";
		$ret =  undef;
	}

	if(!$perm)
	{
		$@ = "No permission hash";
		$ret =  undef;
	}

	$self->write_log(level => 'DEBUG', log => [ "PERMISSION HASH $module", $perm ]);

	my $p = $self->permission;

	# Insert root permission
	my $levels = $perm->{LEVELS} || 'r';

	# See if the module permission already exists and just update it if so
	if($p->load_permission(name => $module))
	{
		$self->write_log(level => 'VERBOSE', log => "Updating existing module permission info for $module - DESC: $perm->{'DESC'} LEVELS: $perm->{'LEVELS'}");
		$p->permission_info('description', "$perm->{'DESC'}");
		$p->permission_info('access', "$perm->{'LEVELS'}");
		$perm->{'UPDATED'} = 1; # Flag in case we want to know if this was updated
	}
	else
	{
		if($p->add_permission($module, 0, $perm->{'DESC'}, $perm->{'LEVELS'}))
		{
			$self->write_log(level => 'VERBOSE', log => "Added new module permission $module");
			$perm->{'NEW'} = 1; # Flag in case we want to know if this is a new permission
		}
		else
		{
			$self->write_log(level => 'ERROR', log => "Could not add new module permission for $module: $@");
			$ret =  undef;
		}
	}

	# Set parent ( root ) id to module permission
	my $root_id = $p->permission_info('intranet_permission_id');

	# Iterate through permissions
	foreach my $parent ( keys %{$perm->{'PERMISSIONS'}} )
	{
		my $perm = $perm->{'PERMISSIONS'}->{$parent};

		if($p->load_permission(name => $parent, parent_id => $root_id))
		{
			$self->write_log(level => 'VERBOSE', log => "Updating existing child permission for $module ( $parent )");
			$p->permission_info('description', $perm->{'DESC'});
			$p->permission_info('access', $perm->{'LEVELS'});
			$perm->{'UPDATED'} = 1; # Flag in case we want to know if this perm has been updated
		}
		else
		{
			if($p->add_permission($parent, $root_id, $perm->{'DESC'}, $perm->{'LEVELS'}))
			{
				$self->write_log(level => 'VERBOSE', log => "Added new child permission for $module ( $parent )");
				$perm->{'NEW'} = 1; # Flag in case we want to know if this perm is new
			}
			else
			{
				$self->write_log(level => 'ERROR', log => "Could not add new child permission for $module ( $parent ): $@");
				$ret =  undef;
			}
		}

		my $parent_id = $p->permission_info('intranet_permission_id');

		foreach my $child ( keys %{$perm->{'PERMISSIONS'}} )
		{
			my $perm = $perm->{'PERMISSIONS'}->{$child};

			if($p->load_permission(name => $child, parent_id => $parent_id))
			{
				$self->write_log(level => 'VERBOSE', log => "Updating existing child permission for child $parent ( $child )");
				$p->permission_info('description', $perm->{'DESC'});
				$p->permission_info('access', $perm->{'LEVELS'});
				$perm->{'UPDATED'} = 1; # Flag in case we want to know if this perm has been updated
			}
			else
			{
				if($p->add_permission($child, $parent_id, $perm->{'DESC'}, $perm->{'LEVELS'}))
				{
					$self->write_log(level => 'VERBOSE', log => "Added new child permission for child $parent ( $child )");
					$perm->{'NEW'} = 1; # Flag in case we want to know if this perm is new
				}
				else
				{
					$self->write_log(level => 'ERROR', log => "Could not add new child permission for child $parent ( $child )");
					$ret =  undef;
				}	
			}
		}
	}
	return 1;
			
}
	
=head2 has_module_permissions

=over 4

	This method loads all permissions for the user and stores the permissions in $cgiapp->{'_PERMISSIONS}.

	If the user has permission to access the given module or the module has GLOBAL set to true, a true value is returned.  Otherwise, undef is returned.

	Run this method after running get_module_permissions which retrieves the module's available permissions and global permission settings.

	Args   : $module_name
	Returns: true on success or undef on failure

	Examples:

		my $module = 'Core.Some_Module';

		if($self->get_module_permissions($module) && $self->has_module_permissions($module))
		{
			# Continue to run application
		}
		else
		{
			# Handle permission failure
		}

=back

=cut
sub has_module_permissions
{
	my $self = shift;
	my $module_name = shift;

	if(!$module_name)
	{
		$@ = "Module name is required";
		return undef;
	}

	# Only load user permissions if the module provided a permisssion set
	if(my $mp = $self->{_MODULE_PERMISSIONS}->{$module_name})
	{
			# We need to load the actual user information from the database if we haven't already
			$self->{_USER_INFO} ||= $self->user->load_user($self->check_auth);
	
			# Just load all permissions
			if($self->{_PERMISSIONS} = $self->permission->get_permissions_by_user($self->{_USER_INFO}))
			{
				$self->write_log(level => 'DEBUG', log => "USER IS LOGGED IN!");

				if(defined $self->{_PERMISSIONS}->{PERMISSIONS} && defined $self->{_PERMISSIONS}->{PERMISSIONS}->{$module_name})
				{
					$self->write_log(level => 'DEBUG', log => [ "Found user permissions for $module_name", $self->{_PERMISSIONS}->{PERMISSIONS}->{$module_name} ]);

					# Add all permissions to the template
					$self->tt_append(var => 'PERMISSION', val => $self->{_PERMISSIONS}->{PERMISSIONS});

					# Add permissions to _APPLICATION_PERMISSIONS for application permission checking
					$self->{_APPLICATION_PERMISSIONS} = $self->{_PERMISSIONS}->{PERMISSIONS}->{$module_name};

					# Check to see if this module only offers write permission.  In that case, only return true if they actually have write permission
					if($self->{_MODULE_PERMISSIONS}->{$module_name}->{LEVELS} eq 'w' && $self->{_PERMISSIONS}->{PERMISSIONS}->{$module_name}->{LEVEL} eq 'r')
					{
						return undef;
					}

					return 1;
				}

				# If the user doesn't have the proper permissions, check to see if the module allows global access
				# Do this after checking permissions, since we'll need the permission data anyway
				if(ref($mp) && ref($mp) eq 'HASH' && $mp->{GLOBAL} == 1)
				{
					$self->write_log(level => 'DEBUG', log => "Module $module_name has global access enabled");
					return 1;
				}
			}
			else # Check for GUEST PERMISSIONS which means even a non-logged in user can access this resource
			{
				$self->write_log(level => 'DEBUG', log => "USER IS NOT LOGGED IN!");

				if(ref($mp) && ref($mp) eq 'HASH' && $mp->{GUEST} == 1)
				{
					$self->write_log(level => 'VERBOSE', log => "Module $module_name has GUEST access enabled");
					return 1;
				}
			}
		

		# No permission
		return undef;
	}
	else
	{
		$@ = "Module does not provide a permission set";
		return undef;
	}
}

=head2 check_auth

=over 4

	Validates a user's session.  This should be called before any module processing.

	Args   : none
	Returns: Logged in user name on valid authentication or undef if the user is not logged in

=back

=cut
sub check_auth
{
	my $self = shift;

	if(my $username = $self->session->param('username'))
	{
		$self->{_username} = $username;
		return $username;
	}

	return undef;
}

=head2 alert

=over 4

	Use this method to add an alert message to the template.  These will be displayed one message per line with an individual icon.

	If you set the overwrite variable, any existing alert messages will be replaced with the message that you define.

	Args   : message, [ bool overwrite ]
	Returns: current value of alert variable

	Examples:

		$self->alert('An error!');
		$self->alert('A new error!', 1);

=back

=cut

sub alert
{
	my $self = shift;
	my ($msg, $overwrite) = @_;

	if(!$msg && $overwrite)
	{
		delete $self->{'tt_vars'}->{'TT_ALERT'};
		return;
	}

	$msg = [ $msg ] if ( $overwrite || ( not exists $self->{'tt_vars'}->{'TT_ALERT'} && ref($msg) ne 'ARRAY' ));
	$self->tt_append(var => 'TT_ALERT', val => $msg, overwrite => $overwrite) if $msg;
	return $self->{'tt_vars'}->{'TT_ALERT'};
}

=head2 info

=over 4

	Use this method to add an informational message to the template.  These will be displayed one message per line with an individual icon.

	If you set the overwrite variable, any existing info messages will be replaced with the message that you define.

	Args   : message, [ bool overwrite ]
	Returns: nothing

	Examples:

		$self->info('Good job!');
		$self->info('Better job!', 1);

=back

=cut
sub info
{
	my $self = shift;
	my ($msg, $overwrite) = @_;

	if(!$msg && $overwrite)
	{
		delete $self->{'tt_vars'}->{'TT_INFO'};
		return;
	}

	$msg = [ $msg ] if ( $overwrite || ( not exists $self->{'tt_vars'}->{'TT_INFO'} && ref($msg) ne 'ARRAY' ));
	$self->tt_append(var => 'TT_INFO', val => $msg, overwrite => $overwrite) if $msg;
	return $self->{'tt_vars'}->{'TT_ALERT'};
}

=head2 title

=over 4

	Set the page heading ( which will appear before any alert or info messages ) and page title to the given value.

	The title will be displayed as <h3> just below the page navigation header.

	Args   : title
	Returns: nothing

=back

=cut
sub title
{
	my $self = shift;
	my $title = shift;

	$self->tt_append(var => 'TT_TITLE', val => $title, overwrite => 1);
}

=head2 show_error

=over 4

	This method displays a basic, fail-safe error message.  This should be used in the event of a critical error that prevents execution of anything.

	The template will not be displayed.

	Args   : error_message
	Returns: error message to CGI::Application

=back

=cut
sub show_error
{
	my ( $self, $error ) = @_;

	my $q = $self->query();

	my $title = "Oooops!";
	my $output = $q->start_html( -title => $title );

	$output .= "<h2>$title</h2>\n";
	$output .= "<b>$error</b>\n";

	$output .= $q->end_html();

	print STDERR "Content-type: text/html\n\n" . $output;
	die();
}

# This is just a shortcut to get the function name
sub _caller { ( caller(2) )[3] }

=head2 tt_append

=over 4

	This method is used to append TT variables to the build in template hash $self->{tt_vars}.

	Use this when you want to add a new key and value to the template or add a new element to an array or add another hash key to an existing hash.

	If the tt_vars hash key already exists and the overwrite option has not been specified, the method checks to see what type of variable you are appending to and does one of the following:

	String: Appends the text to the end of the existing string.
	Array : Adds a new array element onto the existing array.
	Hash  : Adds a new hash key with the given data in value

	You can use the overwrite parameter to overwrite any existing tt_vars key with the new data.

	Args: var => 'hash_key_name', val => 'value', [ overwrite => bool ]

	Returns: True on success or undef on error ( Error only occurs if no var or val is set ).

	Examples:

		$self->tt_append(var => 'things', val => ['one', 'two'], overwrite => 1);
		$self->tt_append(var => 'things', val => 'three');

		This will result in an array containing:

			one
			two
			three

		$self->tt_append(var => 'stuff', val => { this => 'that' });
		$self->tt_append(var => 'stuff', val => { those => 'these' });

		This will result in a hash containing:

			{ this => 'that', those => 'these' }

		
		$self->tt_append(var => 'str', val => 'some text.';
		$self->tt_append(var => 'str', val => ' more text.';

		This will result in a string containing:

			some text. more text.

=back

=cut
sub tt_append
{
	my $self = shift;

	my %params = @_;

	# Don't continue unless we have a parameter and value ( can be empty )
	unless($params{'var'} && defined($params{'val'}))
	{
		return undef;
	}

	# To overwrite, just remove the hash key
	if($params{'overwrite'} && exists($self->{'tt_vars'}->{$params{'var'}}))
	{
		delete $self->{'tt_vars'}->{$params{'var'}};
	}

	if( ref($self->{'tt_vars'}->{$params{'var'}}) eq 'ARRAY' )
	{
		if( ref($params{'val'}) eq 'ARRAY' )
		{
			foreach my $val ( @{$params{'val'}} )
			{
				push( @{$self->{'tt_vars'}->{$params{'val'}}}, $val );
			}
		}
		else
		{
			push( @{$self->{'tt_vars'}->{$params{'var'}}}, $params{'val'} );
		}
	}
	elsif( ref($self->{'tt_vars'}->{$params{'var'}}) eq 'HASH' && ref($params{'val'}) eq 'HASH' )
	{
		$self->{'tt_vars'}->{$params{'var'}} = {} unless ref ($self->{'tt_vars'}->{$params{'var'}}) eq 'HASH';

		if( ref($params{'val'}) eq 'ARRAY' )
		{
			foreach my $val ( @{$params{'val'}} )
			{ 
				foreach my $key ( keys %{$val} )
				{
					$self->{'tt_vars'}->{$params{'var'}}->{$key} = $val->{$key};
				}
			}
		}
		else
		{
			foreach my $key ( keys %{$params{'val'}} )
			{
				$self->{'tt_vars'}->{$params{'var'}}->{$key} = $params{'val'}->{$key};
			}
		}
	}
	else
	{
		if(ref($params{'val'}) eq 'ARRAY')
		{
			$self->{'tt_vars'}->{$params{'var'}} = [] unless ref($self->{'tt_vars'}->{$params{'var'}}) eq 'ARRAY';
			foreach my $val ( @{$params{'val'}} )
			{
				push( @{$self->{'tt_vars'}->{$params{'var'}}}, $val );
			}
		}
		elsif( !$self->{'tt_vars'}->{$params{'var'}} )
		{
			$self->{'tt_vars'}->{$params{'var'}} = $params{'val'};
		}
		else
		{
			$self->{'tt_vars'}->{$params{'var'}} .= " " . $params{'val'};
		}
	}		

	return 1;
}

=head2 json_process

=over 4

	This method will output the TT hash ( or a custom hash ) as JSON to the browser

	If you do not want to output to the browser, simply do not return the data.

	By default, this method will set the content type to application/json.  If you do not want that, then set the skip_content_type parameter.

	
	Args   : [ var_hashref ], [ skip_content_type ]
	Returns: JSON formatted output

	Examples:

		return $self->json_process(); # Returns the TT hash to the browser or to variable

		my $json = $self->json_process(\%variables); # Assigns %variables to $json in JSON format

=back

=cut
sub json_process
{
	my $self = shift;
	my ($vars, $skip_content_type) = @_;

	if(!$vars)
	{
		$vars = $self->{tt_vars};
	}

	if(!$skip_content_type)
	{
		$self->header_props(-type => 'application/json');
	}
	my $res = $self->json_encode($vars, 1);
	$self->{output} = $res;
	return $res;
}

sub json_decode
{
	my $self = shift;
	my $data = shift;

	$self->{'JSON'} ||= JSON->new->allow_nonref;

	return $self->{'JSON'}->decode($data);
}

sub json_encode
{
	my $self = shift;
	my $data = shift;
	my $pretty = shift;

	$self->{'JSON'} ||= JSON->new->allow_nonref;

	if($pretty)
	{
		return $self->{'JSON'}->pretty->encode($data);
	}
	else
	{
		return $self->{'JSON'}->encode($data);
	}
}

=head2 _build_menu_hash

=over 4

	This private method builds a hashref of all available applications in a way that can be used by the header template to automatically build the navigation menu.

	Args   : none
	Returns: A hashref containing all applications

=back

=cut
sub _build_menu_hash
{
	my $self = shift;
	my $include_core = shift;

	# This menu is different depending on your permission level.  Don't just use a generic key that will be used by everyone.
	my $cachekey = ref($self)."-menu-$include_core-" . $self->check_auth();	
	my $cached = $self->db->cache->get($cachekey);

	return $cached if ($cached);
	# Get all applications - substr removes the base directory applications/ from the path
	my @modules = File::Find::Rule->file()->name( '*.pm' )->relative()->in( $self->{'application_path'} );
	# Store the menu here
	my %menu;

	foreach my $module (@modules)
	{
		my @path = split('/', $module);

		# Ignore core modules
		next if (!$include_core && $path[0] eq 'Core');

		# Remove the file extension
		my $module = substr(pop(@path), 0, -3);
		
		# Make a reference to the menu hash to build the actual menu data
		my $menu_level = \%menu;
		my $perm_key = join('.', @path) . '.' .$module;

		# If there are no permissions to view this module, then don't add it to the menu hash
		if(!$self->{_PERMISSIONS}->{PERMISSIONS}->{$perm_key})
		{
			next;
		}

		# Add Base to the path if this is in the base category directory level
		push(@path, 'Base') if @path == 1;

		# Create the necessary hash keys
		foreach my $part ( @path )
		{
			$menu_level = $menu_level->{$part} ||= {};
		}	

		my $module_name = $module;
		$module_name =~ tr/_/ /;

		# Add module
		$menu_level->{$module} = $module_name;
	}
	$self->db->cache->set($cachekey,\%menu,600);
	return \%menu;
}

=head2 display_error

=over 4

	This method is used to display an error message wrapped inside of the template error.tt.

	The template file should include header.tt and footer.tt.

	Args   : $error_message
	Returns: nothing

=back

=cut
sub display_error
{
	my $self = shift;
	my $error = shift || 'Undefined error';

	
	$self->title("I'm sorry, but an error has occurred");
	$self->alert($error);
	
	if($self->query->param('to_json'))
	{
		return $self->json_process({ error => $error });
	}
	else
	{
		return $self->tt_process('error.tt');
	}

	exit;
}

=head2 mysql_timestamp

=over 4

	Generate a mysql timstamp using localtime or the given time

	Args   : [ time ]
	Returns: mysql_timestamp

=back

=cut
sub mysql_timestamp
{
	my $self = shift;
	my $use_time = shift;
	return strftime "%Y-%m-%d %H:%M:%S", $use_time ? $use_time : localtime();
}

=head2 reverse_date

=over 4

	Convert YYYY-MM-DD to MM-DD-YYYY

	Args   : date_string
	Returns: reversed date string

=back

=cut
sub reverse_date
{
	my $self = shift;
	my $date = shift || return undef;

        my ($year, $month, $day) = split(/-/, $date);

	if($year < 1000)
	{
		($month, $day, $year) = split(/-/, $date);
		$date = "$year-$month-$day";
		return $date
	}

        $date = "$month-$day-$year";
        return $date;
}

=head2 db

=over 4

	Get a DBIx instance for the given database ( default Fcs )

	Args   : database

=back

=cut
sub db
{
        my $self = shift;

	# Default DB is Fcs
	my $db = shift || 'Fcs';

	if($db eq 'Fcs')
	{
		$self->{'_schema'}->{$db} ||= Fap::Model::Fcs->new;
	}
	elsif($db eq 'Hus')
	{
		$self->{'_schema'}->{$db} ||= Fap::Model::Hus->new;
	}

        return $self->{'_schema'}->{$db};
}

=head2 trace_error

=over 4

	Wrapper for handling Fap->trace_error

	Args   : error(s)
	Returns: undef

	Usage:

		return $self->trace_error('error message');
		
		return $self->trace_error([message1, message2, { hash => array } ]);

=back

=cut
sub trace_error
{
	my ($self, $err) = @_;

	if(ref($err) eq 'ARRAY')
	{
		Fap->trace_error($_) for @{$err};
	}
	elsif(ref($err) eq 'HASH')
	{
		Fap->trace_error(Dumper( $err ));
	}
	else
	{
		Fap->trace_error($err);
	}

	$@ = $err;
	return undef;
}

sub redirect
{
	my $self     = shift;
	my $location = shift;
	my $status   = shift;

	# The eval may fail, but we don't care
	eval {
		$self->run_modes( dummy_redirect => sub { } );
		$self->prerun_mode('dummy_redirect');
	};

	if ($status)
	{
		$self->header_add( -location => $location, -status => $status );
	}
	else
	{
		$self->header_add( -location => $location );
	}

	$self->header_type('redirect');

	return;
}


1;
