#!/usr/bin/perl

# Start of documentation header 
 
=head1 NAME 
 
Fap::Collector::User
 
=head1 VERSION 
 
$Id: User.pm 1253 2013-02-01 17:03:29Z jweitz $ 
 
=head1 SYNOPSIS 
 
use Fap::Collector::User

=head1 DESCRIPTION 

	All API user and authentication methods.
 
=head1 EXAMPLES 
 
=over 4 
 
	See examples in class methods.

=back 

=head1 CLASS METHODS

=over 4

Method usage.

=back

=cut
package Fap::Collector::User;

use strict;
use vars qw($VERSION @EXPORT);

use base 'Fap::Collector';

use Digest;
use Math::Random::Secure 'irand';
use Scalar::Util ();

$VERSION = '1.00';

require Exporter;

@EXPORT = qw(
	create_api_key_hash
	update_api_key
	verify_api_key
	generate_random_hex
	load_user
	load_all_users
	user_info
	user
	load_user
	reset_lockout
	is_locked_out	
	add_user
	increment_lockout
	api_key_is_expired
	remove_user
	verify_user_ip
	add_user_ip
	check_user_permission
	add_user_permission
	remove_user_permission
);

sub import
{
	goto &Exporter::import;
}

# Non-negative integer controlling the cost of the hash function. The number of operations is proportional to 2^cost.
# Note that changing this value requires password hashes to be re-computed.
use constant DIGEST_COST => 13;
# The default login failures before lockout
use constant LOCKOUT_LIMIT => 10;

# This is the number of days after which an API key expires ( 0 = never expire ).
use constant API_KEY_EXPIRES => 0;


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
		if(!$self->load_user($username))
		{
			return undef;
		}
	}

	return $self;
}

=head2 user

=over 4

	Handles creation of a new FONUser instance.

	Args   : [ $user_id_or_user_is_loaded ]
	Returns: FONUser instance

=back

=cut
sub user
{
	my $cgiapp = shift;
	my $username = shift;

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

=head2 create_api_key_hash

=over 4

	Creates a random salt and hashed api_key

	Args   : $api_key
	Returns: api_key_hash, salt

=back

=cut
sub create_api_key_hash
{
	my $self = shift;
	my $api_key = shift;

	if(!$api_key)
	{
		$@ = "API key is required";
		return undef;
	}

	# Create random salt ( 16 chars )
	my $salt = $self->generate_random_hex(16);
	my $bcrypt = Digest->new('Bcrypt');

	$bcrypt->cost(DIGEST_COST);
	$bcrypt->salt($salt);
	$bcrypt->add($api_key);

	return ( $bcrypt->hexdigest, $salt );
}
=head2 update_api_key

=over 4

	Update the loaded user's api_key

	Args   : $password
	Returns: true on success or undef on failure

=back

=cut
sub update_api_key
{
	my $self = shift;
	my $api_key = shift;

	if(&_user_is_loaded($self))
	{
		if($api_key)
		{
			# Generate a new password hash and salt for the user
			my ($api_hash, $salt) = $self->create_api_key_hash($api_key);

			if($self->user_info('salt', $salt) && $self->user_info('password', $api_hash))
			{
				# Set updated password time
				if($self->user_info('api_key_updated', time()))
				{
					return 1;
				}
				else
				{
					# No sense doing anything else here because they will get redirected to the password reset page
					$@ = "Could not update api_key_updated: $@";
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
			$@ = "API key is required";
			return undef;
		}
	}
	else
	{
		$@ = "User not loaded";
		return undef;
	}

}

=head2 sub verify_api_key

=over 4

	Verify the api key and IP address for the currently loaded username

	Args   : $password, [ userinfo_hash ]
	Returns: true on success or undef on failure

=back

=cut
sub verify_api_key
{
	my $self = shift;
	my $api_key = shift;;

	if(!$api_key)
	{
		$@ = "No API key provided.";
		return undef;
	}

	# Make suer that a username has been loaded
	if(!&_user_is_loaded($self))
	{
		$@ = "User not loaded";
		return undef;
	}

	my $salt = $self->user_info('salt');

	if(!$salt)
	{
		$@ = "Loaded user does not have a defined salt";
		return undef;
	}

	my $bcrypt = Digest->new('Bcrypt');
	
	$bcrypt->cost(DIGEST_COST);
	$bcrypt->salt($salt);
	$bcrypt->add($api_key);

	if($bcrypt->hexdigest eq $self->user_info('api_key'))
	{
		return 1;
	}
	else
	{
		return undef;
	}
}

=head2 verify_user_ip

=over 4

	Verify if a loaded user is allowed to access the API from the given IP address

=back

=cut
sub verify_user_ip
{
	my $self = shift;
	my $ip = $ENV{'REMOTE_ADDR'};

	if(!$ip)
	{
		$@ = "User IP address could not be determined";
		return undef;
	}

	if(!&_user_is_loaded($self))
	{
		$@ = "No user has been loaded.";
		return undef;
	}

	my $user_id = $self->user_info('id');

	if(!$user_id)
	{
		$@ = "No user ID is available for the loaded user";
		return undef;
	}

	my $res = $self->db->table("collector_user_ip")->search({ user_id => $user_id, ip_address => $ip }, { limit => 1, rows => 1 } );

	if($res && $res->first)
	{
		return $res->first->user_id;
	}
	else
	{
		return undef;
	}
}

=head2 add_user_ip

=over 4

	Add an IP address to the access list for a given user

	Args   : $ip_address
	Returns: true on success or undef

=back

=cut
sub add_user_ip
{
	my $self = shift;
	my $ip = shift;

	if(!$ip)
	{
		$@ = "IP address is required";
		return undef;
	}

	if(!&_user_is_loaded($self))
	{
		$@ = "No user has been loaded";
		return undef;
	}

	# Don't add it twice
	if($self->verify_user_ip($ip))
	{
		return 1;
	}

	my $user_id = $self->user_info('id');

	if(!$user_id)
	{
		$@ = "No user id is available for the loaded user";
		return undef;
	}

	my $data = {
		user_id => $user_id,
		ip_address => $ip
	};

	if($self->db->table("collector_user_ip")->create($data))
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

	Add an application to a loaded API user

	Args   : $application
	Returns: true on success undef on failure

=back

=cut
sub add_user_permission
{
	my $self = shift;
	my $application = shift;

	if(!&_user_is_loaded($self))
	{
		$@ = "User is not loaded";
		return undef;
	}

	if(!$application)
	{
		$@ = "Application is required";
		return undef;
	}

	# Just return true if we already have permission
	return 1 if $self->check_user_permission($application);

	if($self->db->table("collector_permissions")->create({ user_id => $self->user_info('id'), application => $application }))
	{
		return 1;
	}
	else
	{
		return undef;
	}
}

=head2 remove_user_permission

=over 4

	Remove an applkication from a loaded API user

	Args   : $application
	Returns: true on success or undef on failure

=back

=cut
sub remove_user_permission
{
	my $self = shift;

	my $application = shift;

	if(!&_user_is_loaded($self))
	{
		$@ = "User is not loaded";
		return undef;
	}

	if(!$application)
	{
		$@ = "Application is required";
		return undef;
	}

	# Just return if the user doesn't have this permission in the first place
	return 1 if !$self->check_user_permission($application);

	if($self->db->table("collector_permissions")->search({ user_id => $self->user_info('id'), application => $application })->delete)
	{
		return 1;
	}
	else
	{
		return undef;
	}
}

=head2 check_user_permission

=over 4

	Check to see if a user has access to an application

	Args   : $user_id, $application
	Returns: true on access or undef on failure

=back

=cut
sub check_user_permission
{
	my $self = shift;
	my $application = shift;

	if(!&_user_is_loaded($self))
	{
		$@ = "User is not loaded";
		return undef;
	}

	if(!$application)
	{
		$@ = "Application is required";
		return undef;
	}

	my $res = $self->db->table("collector_permissions")->search({ user_id => $self->user_info('id'), application => $application }, { limit => 1, rows => 1 });

	if($res && $res->first)
	{
		return $res->first->id;
	}
	else
	{
		return undef;
	}
}

=head2 _user_is_loaded

=over 4

	Private method that simply returns the loaded username if any

=back

=cut
sub _user_is_loaded
{
	my $self = shift;

	if($self->{FONAuth}->{_user_info})
	{
		return $self->{FONAuth}->{_user_info}->{username};
	}
	else
	{
		return undef;
	}
}

# Get or set user information from the database
sub user_info
{
	my $self = shift;
	
	my($field, $value) = @_;

	if(&_user_is_loaded($self))
	{
		# We want all user data
		if(!$field)
		{
			if($self->{FONAuth}->{_user_info})
			{
				return $self->{FONAuth}->{_user_info};
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
				return $self->{FONAuth}->{_user_info}->{$field} = $value;
			}
		}
		else
		{
			if($self->{FONAuth}->{_user_info})
			{
				return $self->{FONAuth}->{_user_info}->{$field};
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

	if(@_ == 1)
	{
		if($_[0] =~ /^\d+$/)
		{
			$params{'id'} = shift;
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

	# Store sql fields and values
	my %search_keys;

	foreach my $key ( keys %params )
	{
		if($key ne 'id' && $key ne 'username')
		{
			$@ = "Invalid user identifier";
			return undef;
		}
		$search_keys{$key} = $params{$key};
	}

	if(%search_keys)
	{
		# We should remove any loaded user data
		delete $self->{FONAuth}->{_user_info};
		delete $self->{FONAuth}->{_user_resultset};

		my $res = $self->db->table("collector_users")->search(\%search_keys, { limit => 1, rows => 1 });

		if($res && $res->first)
		{
			$self->{FONAuth}->{_user_resultset} = $res->first;
			my %user_info = $res->first->get_columns;
			return $self->{FONAuth}->{_user_info} = \%user_info;
		}
		else
		{
			$@ = "User not found";
			return undef;
		}
	}
	else
	{
		$@ = "User identifier required";
		return undef;
	}
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

	my @users = $self->db->table("collector_users")->all;

	return \@users;
}

sub unload_user
{
	my $self = shift;
	delete $self->{FONAuth}->{_user_info};
}

sub _save_user_info
{
	my $self = shift;
	
	my %params = @_;

	if(&_user_is_loaded($self))
	{
		my %updates;

		my @fields; # Fields to be updated
		my @values; # Values for each field

		foreach my $field ( keys %params )
		{
			if(not defined($params{$field}))
			{
				$@ = "A value is required to update user fields.";
				return undef;
			}
			$updates{$field} = $params{$field};

			push @fields, $field;
			push @values, $params{$field};
		}

		if($self->{FONAuth}->{_user_resultset})
		{
			$self->{FONAuth}->{_user_resultset}->set_columns(\%updates);

			if($self->{FONAuth}->{_user_resultset}->update())
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

	if(&_user_is_loaded($self))
	{
		my $login_failures = $self->user_info('lockout');

		if(not defined($login_failures))
		{
			if($self->can('logger'))
			{
				$self->logger("Could not retrieve current failed login count for user, assuming locked out");
			}
			return LOCKOUT_LIMIT;
		}

		if($login_failures >= LOCKOUT_LIMIT)
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

	if(&_user_is_loaded($self))
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
	
	if(&_user_is_loaded($self))
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

	my $first_name = $params{'first_name'};
	my $last_name = $params{'last_name'};
	
	my $email = $params{'email'};

	my $api_key = $self->generate_random_hex(32);

	if(!$username)
	{
		$@ = "Username is required.";
		return undef;
	}

	if(!$api_key)
	{
		$@ = "API key is required.";
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

	if($self->load_user($username))
	{
		$self->unload_user;
		$@ = "Username already exists";
		return undef;
	}

	my($api_key_hash, $salt); # We will create a unique, random salt for each user
	($api_key_hash, $salt) = $self->create_api_key_hash($api_key); # Get salt and update api_key

	my $user_data = {
		first_name => $first_name,
		last_name => $last_name,
		username => $username,
		api_key => $api_key_hash,
		salt => $salt,
		api_key_updated => time(),
		email => $email
	};

	if($self->db->table("collector_users")->create($user_data))
	{
		return $api_key;
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
	my $self = shift;
	my $username = shift;
	my $unload;

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

	if(!$username && &_user_is_loaded($self))
	{
		$username = $self->user_info('username');
	}

	if(!$username)
	{
		$@ = "No username provided or loaded";
		return undef;
	}

	if(&_user_is_loaded($self) && $username eq $self->user_info('username'))
	{
		$unload = 1;
	}

	if($self->db->table("collector_users")->search({ username => $username })->delete)
	{
		$self->unload_user if $unload;
		return 1;
	}
	else
	{
		return undef;
	}
}

=head2 api_key_is_expired

=over 4

	Check if the loaded user's api key is expired

	Args   : none
	Returns: true on expired or undef on failure

=back

=cut
sub api_key_is_expired
{
	my $self = shift;

	if(&_user_is_loaded($self))
	{
		# Get the number of days allowed before password expiration
		my $expire_offset = API_KEY_EXPIRES;

		# If we don't expire
		if(!$expire_offset)
		{
			return undef;
		}
	
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

1;
