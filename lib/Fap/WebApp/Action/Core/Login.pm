#!/usr/bin/perl

use strict;
use Digest;
# This is the duration of time in seconds that the login process will sleep after a failure.
use constant LOGIN_FAILURE_SLEEP => 3;

=head2 process_Login

=over 4

	Main entry point.

=back

=cut
sub process_Login
{
	my $self = shift;

	$self->title('Fonality User Login');

	my $action = $self->valid->param('action');

	if($action eq 'login')
	{
		$self->tt_append(var => '_redirect', val => $self->query->param('_redirect'));

		if($self->login())
		{
			return $self->redirect('/?m=Core.Main');
		}
		else
		{
			$self->alert('Incorrect username or password.');
		}
	}
	elsif($action eq 'logout')
	{
		$self->logout();
		$self->info('You have been logged out.');
	}
		
	return $self->tt_process('Core/Login.tt');

}

=head2 login

=over 4

	Check for valid credentials and create a new session on success.

	A new session will always be created to prevent session hijacking.

	The form input parameters username and password should be set prior to calling this method unless you pass them as optional arguments.


	Args   : [username], [password]
	Returns: Username on success or undef on failure

=back

=cut	
sub login
{
	my $self = shift;

	my $username = $self->valid->param('username');
	my $password = $self->valid->param('password');

	# Make sure both user name and password are set
	if(!$username)
	{
		$self->write_log(level => 'VERBOSE', log => "No username provided");
		return undef;
	}

	if(!$password)
	{
		$self->write_log(level => 'VERBOSE', log => "No password provided");
		return undef;
	}

	# Load the supplied user
	if(my $user = $self->user($username))
	{
		# Check if user is disabled
		if($user->is_disabled)
		{
			$self->write_log(level => 'VERBOSE', log => "Login attempt by disabled user");
			$self->login_wait();
			return undef;
		}

		if($user->verify_password($password))
		{
			$self->write_log(level => 'VERBOSE', log => "Verified password for $username.");

			# Check for user lockout
			if($user->is_locked_out)
			{
				$self->write_log(level => 'VERBOSE', log => "Not creating session for locked out user.");
				$self->login_wait();
				return undef;
			}

			# Recreate session if one already exists, this helps to prevent session hijacking
			if($self->session->id)
			{
				$self->write_log(level => 'DEBUG', log => "Session already exists, recreating a new session");
				$self->session_recreate();
			}
			
			# Define session username param
			$self->session->param('username', $username);

			# Reset lockout
			$user->reset_lockout();

			# Check if password is expired and set a session value that will be used in prerun to redirect the user.
			# This redirection is handled in the CGI::Application::pre_run callback and is checked before loading any application
			if($user->password_is_expired)
			{
				$self->session->param('password_expired', 1);
			}

			return 1;
		}
		else
		{
			# Failure - increment lockout count
			$self->write_log(level => 'ERROR', log => "Failed login attempt for $username, incrementing login failure count");
			$user->increment_lockout();
			$self->login_wait();
			return undef;
		}
	}
	else
	{
		# Incorrect username
		$self->write_log(level => 'ERROR', log => "No such username $username");
		$self->login_wait();
		return undef;
	}

}

=head2 login_wait

=over 4

	Sleeps for LOGIN_FAILURE_SECONDS.

	This is to be used in between all login failures.

=back

=cut
sub login_wait
{
	my $self = shift;
	my $sleep = $self->config('auth.LOGIN_FAILURE_SLEEP') || LOGIN_FAILURE_SLEEP;
	sleep $sleep;
}

=head2 logout

=over 4

	Destroys a session

	Args   : none
	Returns: nothing

=back

=cut
sub logout
{
	my $self = shift;

	if($self->session->delete)
	{	
		$self->session->flush;
		$self->write_log(level => 'VERBOSE', log => "User log out");
		return 1;
	}
	else
	{
		$self->write_log(level => 'ERROR', log => "Could not log out user - unable to delete session: $!");
		return undef;
	}
}

=head2 init_permissions

=over 4

	Permission method.

	See CGI::Application::Plugin::FONPermissions

=back

=cut
sub Core_Login_init_permissions
{
        my($self, $module_name) = @_;

	my $perm = {
		GLOBAL => 1,
		GUEST => 1,
	};

	return $perm;
}


1;
