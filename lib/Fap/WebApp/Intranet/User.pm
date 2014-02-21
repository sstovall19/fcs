#!/usr/bin/perl

# Start of documentation header 
 
=head1 NAME 
 
CGI::Application::Plugin::FONUser
 
=head1 VERSION 
 
$Id: User.pm 2373 2013-03-21 21:41:04Z jweitz $ 
 
=head1 SYNOPSIS 
 
use CGI::Application::Plugin::FONUser

=head1 DESCRIPTION 

	All user and authentication methods.
 
=head1 EXAMPLES 
 
=over 4 
 
	See examples in class methods.

=back 

=head1 CLASS METHODS

=over 4

Method usage.

=back

=cut
package Fap::WebApp::Intranet::User;


use strict;
use vars qw($VERSION @EXPORT);
use base 'Fap::WebApp::Intranet';
use Fap::Util;
use Digest;
use Math::Random::Secure 'irand';
use Scalar::Util ();
use Data::Dumper;

$VERSION = '1.00';

require Exporter;

@EXPORT = qw(
	create_password
	update_password
	verify_password
	generate_random_hex
	load_user
	load_all_users
	user_info
	user
	load_user
	reset_lockout
	is_locked_out	
	is_disabled
	add_user
	increment_lockout
	password_is_expired
	strong_password
	remove_user	
);

sub import
{
	goto &Exporter::import;
}

# Non-negative integer controlling the cost of the hash function. The number of operations is proportional to 2^cost.
# Note that changing this value requires password hashes to be re-computed.
use constant DIGEST_COST => 13;

# The default login failures before lockout - this can be configured in the config key Auth.lockout_count
use constant DEFAULT_LOCKOUT => 10;

# This is the number of days after which a password expires.  Can be set in config key Auth.password_expires
use constant DEFAULT_PASSWORD_EXPIRES => 180;


sub new {
	my $class  = shift;
	my $cgiapp = shift;
	my $username = shift;
	my $self   = {};


	bless $self, $class;
	$self->{cgiapp} = $cgiapp;
	Scalar::Util::weaken($self->{cgiapp});

	if($username)
	{
		print "USERNAME2: $username\n";
		if(!$self->load_user($username))
		{
			print "COULD NOT LOAD USER?\n";
			return undef;
		}
	}

	return $self;
}

=head2 user

=over 4

	Handles creation of a new FONUser instance.

	Args   : [ $user_id_or_username ]
	Returns: FONUser instance

=back

=cut
sub user
{
	my $cgiapp = shift;
	my $username = shift;
print "USERNAME: $username\n";
	return __PACKAGE__->new($cgiapp, $username);
}

=head2 generate_random_hex

=over 4

	Generates a truly random hex string of given length. Default length is 16.

	If an odd number is provided, a string of one fewer characters than $length will be returned.

	This should be used for generating user salts and random passwords.

	Args   : $length
	Returns: Random hex string of $length

=back

=cut
sub generate_random_hex
{
	my $self = shift;
	my $length = shift;

	$length ||= 16;

	my $str = join "", map { unpack "H*", chr(irand(255)) } 1..$length/2;

	return $str;
}

=head2 create_password

=over 4

	Creates a random salt and hashed password.

	Args   : $password
	Returns: password_hash, salt

=back

=cut
sub create_password
{
	my $self = shift;
	my $password = shift;

	if(!$password)
	{
		$@ = "Password is required to create_password.";
		return undef;
	}

	# Create random salt ( 16 chars )
	my $salt = $self->generate_random_hex(16);
	my $bcrypt = Digest->new('Bcrypt');

	$bcrypt->cost(DIGEST_COST);
	$bcrypt->salt($salt);
	$bcrypt->add($password);

	return ( $bcrypt->hexdigest, $salt );
}

=head2 update_password

=over 4

	Update the loaded user's password.

	This will create a new salt in addition to updating the password.

	Args   : $password
	Returns: true on success or undef on failure

=back

=cut
sub update_password
{
	my $self = shift;
	my $password = shift;

	if(&_username($self))
	{
		if($password)
		{
			# Generate a new password hash and salt for the user
			my ($pw_hash, $salt) = $self->create_password($password);

			if($self->user_info('salt', $salt) && $self->user_info('password', $pw_hash))
			{
				# Set updated password time
				if($self->user_info('password_updated', time()))
				{
					return 1;
				}
				else
				{
					# No sense doing anything else here because they will get redirected to the password reset page
					$@ = "Could not update password_updated: $@";
					return undef;
				}
			}
			else
			{
				$@ = "Could not update user information: $@";
				return undef;
			}	
		}
		else
		{
			$@ = "Password is required";
			return undef;
		}
	}
	else
	{
		$@ = "User not loaded";
		return undef;
	}

}

=head2 sub verify_password

=over 4

	Verify the password for the currently loaded username

	Args   : $password, [ userinfo_hash ]
	Returns: true on success or undef on failure

=back

=cut
sub verify_password
{
	my $self = shift;
	my $password = shift;;

	if(!$password)
	{
		$@ = "No password provided.";
		return undef;
	}

	# Make suer that a username has been loaded
	if(!&_username($self))
	{
		$@ = "User not loaded";
		return undef;
	}

	# Retrieve the salt for this user
	my $salt = $self->user_info('salt');

	if(!$salt)
	{
		$@ = "User salt not defined";
		return undef;
	}

	my $bcrypt = Digest->new('Bcrypt');
	
	$bcrypt->cost(DIGEST_COST);
	$bcrypt->salt($salt);
	$bcrypt->add($password);

	if($bcrypt->hexdigest eq $self->user_info('password'))
	{
		return 1;
	}
	else
	{
		return undef;
	}
}

=head2 _username

=over 4

	Private method that simply returns the loaded username if any

=back

=cut
sub _username
{
	my $self = shift;

	if($self->{'FONAuth'}->{_user_info})
	{
		return $self->{'FONAuth'}->{_user_info}->{username};
	}
	else
	{
		return undef;
	}
}

sub _user_is_loaded
{
	return &_username(shift);
}

# Get or set user information from the database
sub user_info
{
	my $self = shift;
	
	my($field, $value) = @_;

	if(&_username($self))
	{
		# We want all user data
		if(!$field)
		{
			if($self->{'FONAuth'}->{_user_info})
			{
				return $self->{'FONAuth'}->{_user_info};
			}
			else
			{
				$@ = "User not loaded";
				return undef;
			}
		}

		if($field && defined($value))
		{
			# Update field in database
			if(&_save_user_info($self, $field, $value))
			{
				# set and return the new value
				return $self->{'FONAuth'}->{_user_info}->{$field} = $value;
			}
			else
			{
				return undef;
			}
		}
		else
		{
			if($self->{'FONAuth'}->{_user_info})
			{
				return $self->{'FONAuth'}->{_user_info}->{$field};
			}
			else
			{
				$@ = "User not loaded";
				return undef;
			}
		}
	}
	else
	{
		$@ = "User not loaded";
		return undef;
	}
}

sub load_user
{
	my $self = shift;
	my %params;

	use Time::HiRes;
	my $t = Time::HiRes::time;


	if(@_ == 1)
	{
		if($_[0] =~ /^\d+$/)
		{
			$params{'intranet_user_id'} = shift;
		}
		else
		{
			$params{'username'} = shift;
		}
	}
	else
	{
		%params = @_;
	}

	# Actually unique key
	my $key = 'load_user-' . join('-', map { $_ . $params{$_} } sort keys %params);
	my $ret = $self->db->cache->get($key);
	return $self->{'FONAuth'}->{'_user_info'} = $ret if ($ret);

	# Store sql fields and values
	my %search_keys;

	foreach my $key ( keys %params )
	{
		if($key ne 'intranet_user_id' && $key ne 'username')
		{
			$@ = "Invalid user identifier";
			$ret = undef;
		}
		$search_keys{$key} = $params{$key};
	}



	if(scalar(%search_keys))
	{
		# We should remove any loaded user data
		$self->unload_user;

		my $res = $self->db->table('intranet_user')->search(\%search_keys, { limit => 1 });

		if($res && $res->first)
		{
			$self->{'FONAuth'}->{'_user_info_resultset'} = $res->first;
			my %user_info = $res->first->get_columns;
			$ret = $self->{'FONAuth'}->{'_user_info'} = \%user_info;
			$self->db->cache->set($key,$ret,120);
		}
		else
		{
			$@ = "User not found";
			$ret = undef;
		}
	}
	else
	{
		$@ = "User identifier required";
		$ret = undef;
	}

	return $ret;
}

=head2 load_all_users

=over 4

	Load a list of all users

	Args   : none
	Returns: An arrayref of all users

=back

=cut
sub load_all_users
{
	my $self = shift;

	my @users = $self->db->table('intranet_user')->all;

	if(@users)
	{
		@users = $self->db->strip(@users);
		return \@users;
	}

	return undef;
}

sub unload_user
{
	my $self = shift;
	delete $self->{'FONAuth'}->{'_user_info'};
	delete $self->{'FONAuth'}->{'_user_info_resultset'};
}

sub _save_user_info
{
	my $self = shift;
	
	my %params = @_;

	if(&_user_is_loaded($self))
	{
		my %updates;

		foreach my $field ( keys %params )
		{
			if(not defined($params{$field}))
			{
				$@ = "A value is required to update user fields.";
				return undef;
			}
			$updates{$field} = $params{$field};
		}

		if($self->{'FONAuth'}->{'_user_info_resultset'})
		{
			$self->{'FONAuth'}->{'_user_info_resultset'}->set_columns(\%updates);

			if($self->{'FONAuth'}->{'_user_info_resultset'}->update())
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
			$@ = "User result set is not loaded";
			return undef;
		}
	}
	else
	{
		$@ = "Must load user before updating user information.";
		return undef;
	}	

	
}


=head2 is_locked_out

=over 4

	Check to see if user is locked out due to too many logins.

	Args   : none;
	Returns: true if user is locked out ( or failure ) or undef if not locked out

=back

=cut
sub is_locked_out
{
	my $self = shift;

	if(&_username($self))
	{
		my $lockout_limit = $self->config('Auth.lockout_count') || DEFAULT_LOCKOUT;
		my $login_failures = $self->user_info('lockout');

		if(not defined($login_failures))
		{
			if($self->can('write_log'))
			{
				$self->write_log(level => 'ERROR', log => "Could not retrieve current failed login count for user, assuming locked out");
			}
			return $lockout_limit;
		}

		if($login_failures >= $lockout_limit)
		{
			return $login_failures;
		}
		else
		{
			return undef;
		}
	}
	else
	{
		$@ = "User not loaded";
		return 1; # Default to locked out
	}
}

=head2 is_disabled

=over 4

	Check to see if the user has been disabled.

	Args   : none
	Returns: true on disabled or failure or undef if not disabled

=back

=cut
sub is_disabled
{
	my $self = shift;

	if(&_username($self))
	{
		if($self->user_info('disabled') > 0)
		{
			return $self->user_info('disabled_time');
		}
		else
		{
			return undef;
		}
	}
	else
	{
		$@ = "User not loaded";
		return 1; # Default to disabled
	}
}

=head2 increment_lockout

=over 4

	Increment the loaded user's lockout ( failed login ) count

	Args   : none
	Returns: true on success or undef on failure to update count

=back

=cut
sub increment_lockout
{
	my $self = shift;

	if(&_username($self))
	{
		my $login_failures = $self->user_info('lockout');
		$login_failures++;

		if($self->user_info('lockout', $login_failures))
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
		$@ = "User not loaded";
		return undef;
	}
}

=head2 reset_lockout

=over 4

	Reset the loaded user's lockout count.  Reset this at each login.

	Args   : none
	Returns: true on success or undef on failure to clear.

=back

=cut
sub reset_lockout
{
	my $self = shift;
	
	if(&_username($self))
	{
		my $reset = $self->user_info('lockout', 0);

		if(defined($reset))
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
		$@ = "User not loaded";
		return undef;
	}
}

=head2 add_user

=over 4

	Add a new user to the framework.

	Required args in key / value pairs:

		username
		password
		first_name
		last_name
		email


	Returns:  true on success or undef on failure

=back

=cut		
sub add_user
{
	my $self = shift;
	my %params = @_;

	my $username = $params{'username'};
	my $password = $params{'password'};

	my $first_name = $params{'first_name'};
	my $last_name = $params{'last_name'};

	my $email = $params{'email'};

	if(!$username)
	{
		$@ = "Username is required.";
		return undef;
	}

	if(!$password)
	{
		$@ = "Password is required.";
		return undef;
	}

	if(!$first_name)
	{
		$@ = "First name is required.";
		return undef;
	}

	if(!$last_name)
	{
		$@ = "Last name is required.";
		return undef;
	}

	if(!$email)
	{
		$@ = "Email address is required.";
		return undef;
	}

	my $salt; # We will create a unique, random salt for each user
	($password, $salt) = $self->create_password($password); # Get salt and update password

	my $user_data = {
		'first_name'		=> $first_name,
		'last_name'		=> $last_name,
		'username'		=> $username,
		'password'		=> $password,
		'salt'			=> $salt,
		'password_updated'	=> time(),
		'email'			=> $email
	};

	if($self->db->table('intranet_user')->search({ 'username' => $username })->first || $self->db->table('intranet_user')->create($user_data))
	{
		return 1;
	}
	else
	{
		return undef;
	}

}

=head2 remove_user

=over 4

	Remove the supplied or loaded user from the system completely

	Args   : [ user_id_name_or_hash ]
	Returns: true on success or undef on failure

=back

=cut
sub remove_user
{
	my ($self, $username) = @_;
	my $unload = undef;

	if($username && ref($username) eq 'HASH')
	{
		if(defined($username->{'username'}))
		{
			$username = $username->{'username'};
		}
		else
		{
			$@ = "Invalid user format";
			return undef;
		}
	}

	if(!$username && &_username($self))
	{
		$username = $self->user_info('username');
	}

	if(!$username)
	{
		$@ = "No username provided or loaded";
		return undef;
	}

	if(&_username($self) && $username eq $self->user_info('username'))
	{
		$unload = 1;
	}

	if($self->db->table('intranet_user')->search({ 'username' => $username })->delete)
	{
		$self->unload_user if $unload;
		return 1;
	}
	else
	{
		return undef;
	}
}

=head2 password_is_expired

=over 4

	Check if the loaded user's password is expired

	Args   : none
	Returns: true on expired or undef on failure

=back

=cut
sub password_is_expired
{
	my $self = shift;

	if(&_username($self))
	{
		# Get the number of days allowed before password expiration
		my $expire_offset = $self->config('Auth.password_expires') || DEFAULT_PASSWORD_EXPIRES;
	
		# Convert to seconds
		$expire_offset = $expire_offset * 24 * 60 * 60;

		# If the date of last password update is less than this number, then the password is expired
		my $expire_time = time() - $expire_offset;

		if($self->user_info('password_updated') < $expire_time)
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
		$@ = "User not loaded";
		return undef;
	}
}

=head2 strong_password

=over 4

	Check to see if provided password is considered to be strong by Fap::Util::weak_password.

	See Fap::Util::weak_password for more information.

	Args   : $password
	Returns: true if strong or undef if weak

=back

=cut
sub strong_password
{
	my $self = shift;
	my $password = shift;

	if(Fap::Util::weak_password($password))
	{
		return undef;
	}

	return 1;
}

1;
