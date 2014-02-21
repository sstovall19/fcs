#!/usr/bin/perl
use strict;

package Fap::Collector;

# This helps us to find locally installed copies of modules in DEV environments
use FindBin qw ($Bin);
use lib '/usr/local/fonality/lib';
use lib '/usr/local/fonality/fcs/lib';
use lib '/usr/local/fonality/perl5/lib/perl5';

use lib "$Bin";
use lib "$Bin/CGI";

use base 'CGI::Application';

use CGI::Application;
use CGI::Application::Plugin::REST qw(:all);

use Fap::Collector::Validation;
use Fap::Collector::User;

use Fap::Model::Fcs;
use Fap::Util;
use Data::Dumper;
use JSON;
use Data::UUID;
use POSIX('strftime');
use File::Basename;
use JSON;
use Try::Tiny;
=head2 setup

=over 4

	This method is used to setup the CGI::Application instance.

=back

=cut
sub setup
{
	my $self = shift;

	# Get the requested module
	my @request = split('/', Fap::Util::strip_nasties($self->query->path_info, 'url'));
	my $module = '/'.$request[1];
	$module =~ s/\.+//g;
	$self->{_APPLICATION} = $module;
	$self->{_APPLICATION} =~ s/^\///;

	$self->logger("Going to load $module");
	$self->logger("IP: $ENV{REMOTE_ADDR}");

	my $dir = dirname( $ENV{SCRIPT_FILENAME} );

	$self->logger("Running in $dir From $Bin");

	# Try to load this module...the init_routes is specialized for each application
	my $module_init = $request[1] . '_init_routes';

	if(__PACKAGE__->can($module_init))
	{
		$self->logger("Found init method: $module_init");
		$self->{'_init_routes'}->{$module} = \&$module_init;
		$self->{'_init_routes'}->{$module}($self);
	}
	else
	{
		$self->logger("Cannot find init method: $module_init");
	}


	if(-f $dir . '/applications/'.$module.'.pm')
	{
		$self->logger("Going to really load the module now in $Bin/applications");
		require $dir . '/applications/'.$module.'.pm';

		if(__PACKAGE__->can($module_init))
		{
			$self->logger("Found init method: $module_init");
			$self->{'_init_routes'}->{$module} = \&$module_init;
			$self->{'_init_routes'}->{$module}($self);
		}
	}
	else
	{
		$self->logger("Could not find module: $module");
		$self->return_error("Your browser sent a request that this server could not understand.");
	}
}

=head2 cgiapp_prerun

=over 4

	This hook is called immediately before a module is loaded and executed.

	API Authentication and permission checking is performed here.

=back

=cut
sub cgiapp_prerun
{
	my $self = shift;
	my $user = $self->valid->param('user');
	my $api_key = $self->valid->param('api_key');

	my $valid_login = undef;

	$self->run_modes(
		display_error => 'display_error'
	);
	# User and API key is required
	if($user && $api_key)
	{
		# Load API user
		my $u = $self->user($user);

		# Does this user exist?
		if($u)
		{
			# Validate the API key
			if($u->verify_api_key($api_key))
			{
				# We need to validate the source IP address
				if($u->verify_user_ip)
				{
					# Is this user locked out from too many failed login attempts?
					if(!$u->is_locked_out)
					{
						if($u->check_user_permission($self->{_APPLICATION}))
						{
							$valid_login = 1;
						}
						else
						{
							$self->logger("User $user does not have permission to run $self->{_APPLICATION}");
							$self->return_error("You do not have permission to run this module");
							$self->prerun_mode('display_error');
						}
					}
					else
					{
						$self->logger("User $user is locked out");
					}
				}
				else
				{
					$self->logger("User $user does not have access from this IP:" . $ENV{REMOTE_ADDR});
				}
			}
			else
			{
				$self->logger("User $user API key validation failed: $@");
			}				
		}
		else
		{
			$self->logger("User $user does not exist: $@");
		}
	}

	if(!$valid_login)
	{
		$self->return_error("Authentication Failed");
		$self->prerun_mode('display_error');
	}
}

=head2 return_error

=over 4

	This method will return an error message the the client.

	It simply prints the data and exits.

=back

=cut
sub return_error
{
	my $self = shift;
	my $msg = shift;

	$self->status(0);
	$self->error($msg);
}

sub display_error
{
	my $self = shift;
	$self->header_props(-type => 'application/json');
	$self->logger('Returning error message:'. $self->json);
	return $self->json;
}

=head2 json

=over 4

	This method is used to construct the JSON response sent to the client.

	You should first set status and results using their methods before returning this data to the client.

	Args   : none
	Returns: JSON formatted output

	Examples:

		$self->status(1);
		$self->results($results);
		return $self->json;


		# Failure
		$self->status(0);
		$self->error('Unable to find any results');
		return $self->json;		

=back

=cut
sub json
{
	my $self = shift;

	$self->{'JSON'} ||= JSON->new->allow_nonref;

	my $res = {
		'status' => $self->status,
		'error_msg' => $self->error,
		'results' => $self->result,
		'guid' => $self->guid,
	};

	$self->header_props(-type => 'application/json');

	if($self->query->param('callback'))
	{
		return $self->query->param('callback') . '(' . $self->{'JSON'}->pretty->encode($res) . ');';
	}

	return $self->{'JSON'}->pretty->encode($res);
}

sub json_encode
{
	my ($self, $input) = @_;

	$self->{'JSON'} ||= JSON->new->allow_nonref;

	my $json;

	try {
		$json = $self->{'JSON'}->pretty->encode($input);		
	} catch {
		$json = "{}";
	};

	return $json;
}

sub json_decode
{
	my ($self, $input) = @_;

	$self->{'JSON'} ||= JSON->new->allow_nonref;
	my $decoded;

	try {
		$decoded = $self->{'JSON'}->decode($input);
	} catch {
		$decoded = {};
	};

	return $decoded;
}

=head2 status

=over 4

	This method should be used to get or set the status of a request to either 1 or 0 to indicate success or failure.

	This will result in the JSON data returned to contain a status key with this value.

	If this value is not set, it will be assumed false ( 0 ) when returning the JSON data to the client.

	Args   : 0 ( failed ) or 1 ( success )
	Returns: set status
=back

=cut
sub status
{
	my $self = shift;
	my $success = shift;

	if(defined $success)
	{
		return $self->{_STATUS} = $success;
	}

	return $self->{_STATUS};
}

=head2 error

=over 4

	This method is used to get or set an error message in the JSON response to a client.

	Use this method when setting the status to 0.

	Args   : $error_message
	Returns: nothing

=back

=cut
sub error
{
	my $self = shift;
	my $msg = shift;

	if(defined $msg)
	{
		if(defined $self->{_ERROR})
		{
			$self->{_ERROR} = [ $self->{_ERROR} ] if ref($self->{_ERROR}) ne 'ARRAY';
			push(@{$self->{_ERROR}}, $msg);
		}
		else
		{
			return $self->{_ERROR} = $msg;
		}
	}

	return $self->{_ERROR};
}

=head2 result

=over 4

	This method should be used to set the result data that will be processed and returned in the JSON result key returned to the client.

	Adding results to this method assumes that the status should be set to successful ( 1 ) and sets this value in the status key.

	Args   : $results
	Returns: $results

=back

=cut
sub result
{
	my $self = shift;
	my $result = shift;

	if($result)
	{
		$self->{_STATUS} = 1;
	}

	if(defined $result)
	{
		return $self->{_RESULT} = $result;
	}

	return $self->{_RESULT};
}

=head2 guid

=over 4

	Create or return the GUID of the session.

	Args   : none
	Returns: GUID

=back

=cut
sub guid
{
	my $self = shift;

	if($self->{_GUID})
	{
		return $self->{_GUID};
	}
	
	my $guid = Data::UUID->new();

	return $self->{_GUID} = $guid->to_string($guid->create_hex());
}

sub logger
{
	my $self = shift;
	my $msg = shift;
	if(ref($msg))
	{
		$msg = Dumper( $msg );
	}
	open(LOG, '>>', '/tmp/collector.log') || open(LOG, '>>', './collector.log');
	print LOG localtime() . ': ' . $msg . "\n";
	close(LOG);
}

# TEMPORARY
sub sql_execute
{
	my $self = shift;
	my %params = @_;

	unless( $params{'dbh'} )
	{
		$@ = "No database handle provided.";
		return undef;
	}

	my $dbh = $params{'dbh'};
	my $sth;

	if( $params{'sth'} && $self->{'sth_list'}->{$params{'sth'}} )
	{
		$sth = $self->{'sth_list'}->{$params{'sth'}};
	}
	else
	{
		unless( $sth = $dbh->prepare( $params{'sql'} ) )
		{
			$@ = "Unable to prepare query [ " . $dbh->errstr() . " ]";
			return undef;
		}
	
		if( $params{'sth'} )
		{
			$self->{'sth_list'}->{$params{'sth'}} = $sth;
		}
	}

	$params{'args'} = [ $params{'args'} ] if ref($params{'args'}) ne 'ARRAY' && defined $params{'args'};

	unless( $sth->execute( @{$params{'args'}} ) )
	{
		$@ = "Unable to execute query [ " . $sth->errstr() . " ]";
		return undef;
	}

	$params{'get'} ||= 1 if ( $params{'sql'} !~ /(?:(?:REPLACE|INSERT).*INTO|UPDATE.*SET|DELETE.*FROM)/i );

	my $rows;

	if( $params{'get'} )
	{
		my $all = $sth->fetchall_arrayref({});

		$rows = scalar @$all;

		if( $rows == 1 )
		{
			return $$all[0];
		}
		elsif( $rows > 1 )
		{
			my @store;
			
			foreach my $tmp ( @{$all} )
			{
				push( @store, $tmp );
			}

			return \@store;
		}
		else
		{
			$@ = "Query did not return a result." if $sth->errstr();
			return undef;
		}
	}
	else
	{
		if($rows > 0 || $DBI::rows > 0)
		{
			return 1;
		}
		else
		{
			$@ = "Query did not affect any rows";
			return undef;
		}
	}
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

sub db
{
	my $self = shift;

	$self->{_DBIx} ||= Fap::Model::Fcs->new(test_mode=>$self->query->user_agent()=~/fcs-test/); #Pbxtra->new(host=>"web-dev2.fonality.com",user=>"fonality",pass=>"iNOcallU",debug=>0);
	#$self->{_DBIx} ||= F::Db::Pbxtra->new(host=>"web-dev2.fonality.com",user=>"fonality",pass=>"iNOcallU",debug=>0);

	return $self->{_DBIx};
}

sub destroy_log
{
	return 1;
}

1;

