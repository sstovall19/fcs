#!/usr/bin/perl

# Start of documentation header 
 
=head1 NAME 
 
CGI::Application::Plugin::FONLog
 
=head1 VERSION 
 
$Id: Log.pm 2373 2013-03-21 21:41:04Z jweitz $ 
 
=head1 SYNOPSIS 
 
use CGI::Application::Plugin::FONLog

=head1 DESCRIPTION 

=over 4

	Loggin methods for the framework.

	Exports only one useful method: write_log

	Automatically logs userid, module and function that write_log was called from.


	Use of this plugin requires that CGI::Application::Plugin::FONConfig was loaded.


	If the log level log.DEBUG is enabled, memory usage will also be logged each time that a write_log with level DEBUG is called.


	This plugin can log messages to:

		* database:

			Here is the table schema

			CREATE TABLE `intranet_logs` (
			  `id` bigint(10) NOT NULL auto_increment,
			  `ts` timestamp NOT NULL default CURRENT_TIMESTAMP,
			  `userid` varchar(36) NOT NULL default '',
			  `module` varchar(36) NOT NULL default '',
			  `level` varchar(16) NOT NULL default '',
			  `function` varchar(128) NOT NULL default '',
			  `message` varchar(255) NOT NULL default '',
			  `ip` varchar(39) NOT NULL default '0.0.0.0',
			  PRIMARY KEY  (`id`),
			  KEY `ts` (`ts`),
			  KEY `userid` (`userid`),
			  KEY `module` (`module`),
			  KEY `level` (`level`),
			  KEY `ip` (`ip`)
			) 

		* file:

			/tmp/intranet.log


		* F::Log:

			context: intranet	

=back
 
=head1 EXAMPLES 
 
=over 4 
 
	See examples in class methods.

=back 

=head1 CLASS METHODS

=over 4

Method usage.

=back

=cut
package Fap::WebApp::Intranet::Log;

use strict;
use vars qw($VERSION @EXPORT);
use base 'Fap::WebApp::Intranet';

use Data::Dumper;
use Memory::Usage;

$VERSION = '1.00';

require Exporter;

@EXPORT = qw(
	write_log
	read_log
	destroy_log
	audit
	read_audit
);

sub import { goto &Exporter::import }

=head2 write_log

=over 4

	This method is used to write log messages to the database and F::Log ( if enabled ).

	Use this method anywhere that information should be logged for debugging and tracking purposes.

	Available log levels are:

		DEBUG
		VERBOSE
		WARN
		ERROR
		INFO

	The user, function name, module, date / time and PID will all be automatically populated.


	Args   : level => LOG_LEVEL, log => 'MESSAGE'
	Returns: nothing

	Examples:

		$self->write_log(level => 'ERROR', log => 'An error has occurred.');

=back

=cut	
sub write_log
{
	my $self = shift;
	my %params = @_;

	# Grab calling function
	my $parent = $self->_caller();

	unless($params{'log'})
	{
		return undef;
	}

	$params{'level'} ||= 'INFO';

	my $logfile = '/tmp/intranet.log';

	unless($logfile)
	{
		$logfile = $0;
		$logfile =~ s/^.*\/(.*)$/$1/;
		$logfile = '/tmp/' . $logfile;
	}

	open(LOG, '>>', $logfile) || return undef;

	return unless $self->config('log.'.$params{'level'}) > 0;

	$params{'log'} = [$params{'log'}] unless ref($params{'log'}) eq 'ARRAY';

	my $mode = $self->get_current_runmode() || 'main';

	my $user = $self->check_auth() || 'Not logged in';

	foreach my $log ( @{$params{'log'}} )
	{
		$log = Dumper( $log ) if ( ref( $log ) eq 'HASH' || ref( $log ) eq 'ARRAY' );

		print LOG '[' . scalar localtime() . '] ' . $params{'level'} . '[ ' . $$ . ' ] ' . $parent . ': ' . $log . "\n";

		my $log_data = { 
			'intranet_user'		=> $user,
			'module'		=> $mode,
			'level'			=> $params{'level'},
			'function'		=> $parent,
			'message'		=> '[ ' . $$ . ' ] ' . $parent . ': ' . $log
		};

		$self->db->table('intranet_log')->create($log_data);
	}

	# If we have debug log level enabled, log memory usage
	if($params{'level'} eq 'DEBUG')
	{
		if(exists $self->{_memory_usage})
		{
			$self->{_memory_usage}->record('after');
    			my $r = $self->{_memory_usage}->state;
			$r = [ pop @{$r}, pop @{$r} ];
			print LOG '[' . scalar localtime() . '] MEMORY[ ' . $$ . ' ] ' . $parent . ': ' . "Virt: " . ( $$r[0][2] - $$r[1][2] ) . " Res: " . ( $$r[0][3] - $$r[1][3] ) . " Shared: " . ( $$r[0][4] - $$r[1][4] ) . " Stack: " . ( $$r[0][6] - $$r[1][6] ) . "\n";

			$self->{_memory_usage}->record('before');
		}
		else
		{
			$self->{_memory_usage} = Memory::Usage->new();
			$self->{_memory_usage}->record('before');
		}
		
	}

	close(LOG);

	return;
}

=head2 read_log

=over4
	
	Used to read the log database.

	You can search by:

		* user - user => username
		* date range - range => [ startdate, enddate ]
		* log level - levels => [ DEBUG, INFO, VERBOSE, WARN, ERROR ]
		* module - module => module_name
		* function - function => function_name
		* ip - ip => ip_address


	Arguments should be key => value pairs.

	If no date range is provided, the current day will be used.

	If a start date is provided, but no end date, the end of the start date will be used.


	Args   : %key_value_pairs_above
	Returns: Array of hashes containing all log fields

=back

=cut	
sub read_log
{
	my $self = shift;
	my %params = @_;

	# Remove any undefined parameters which will break the SQL query
	map { 
		delete $params{$_} if !defined($params{$_});
	} keys %params;

	my @values; # mysql placeholder values

	# Default log levels
	if(!$params{'levels'} || !@{$params{'levels'}})
	{
		$params{'levels'} = [ 'DEBUG', 'INFO', 'VERBOSE', 'ERROR' ];
	}
	elsif(ref($params{'levels'} ne 'ARRAY')) # just in case we received a single level as a scalar
	{
		$params{'levels'} = [ $params{'levels'} ];
	}

	# If no timestamp range was provided or only a start date was given, fix it up
	if(!$params{'range'})
	{
		my $now = $self->mysql_timestamp;
		$params{'range'} = [ substr($now, 0, 10) . ' 00:00:00', substr($now, 0, 10) . ' 23:59:59' ];	
	}
	elsif(ref($params{'range'}) ne 'ARRAY')
	{
		$params{'range'} = [ substr($params{'range'}, 0, 10). ' 00:00:00', substr($params{'range'}, 0, 10) . ' 23:59:59' ];
	}

	# Default start and limit
	$params{'start'} ||= 0;
	$params{'limit'} ||= 250;

	# Allowed search options
	my @ok = qw/intranet_user user module function ip/;

	# Backwards compat
	$params{'intranet_user'} = $params{'user'} if defined $params{'user'};
	$params{'intranet_user'} ||= 'Not logged in';

	# DBIx search parameters
	my $search_params = {};
	map { $search_params->{$_} = $params{$_} if defined $params{$_} } @ok;

	$search_params->{'level'} = $params{'levels'};
	$search_params->{'updated'} = { '-between' => $params{'range'} };
	
	my @res = $self->db->table('intranet_log')->search(
		$search_params,
		{
			'rows'		=> $params{'limit'},
			'offset'	=> $params{'start'},
			'distinct'	=> $params{'distinct'},
		}
	)->all;

	@res = $self->db->strip(@res) if @res;

	return \@res;
}

sub audit
{
	my $self = shift;

	my %params = @_;

	# Grab calling function
	my $parent = $self->_caller();

	unless($params{'log'})
	{
		return undef;
	}

	my $mode = $self->get_current_runmode() || 'main';

	my $user = $self->check_auth() || 'Not logged in';

	my $audit_data = {
		userid => $user,
		customer_id => $params{'customer_id'},
		server_id => $params{'server_id'},
		module => $mode,
		function => $parent,
		audit => $params{'log'}
	};


	$self->db->table('intranet_audit')->create($audit_data);

	return;
}

sub read_audit
{
	my $self = shift;
	my %params = @_;

	# Delete non-defined params
	map {
		delete $params{$_} if !defined($params{$_});
	} keys %params;

	# If no timestamp range was provided or only a start date was given, fix it up
	if(!$params{'range'})
	{
		my $now = $self->mysql_timestamp;
		$params{'range'} = [ substr($now, 0, 10) . ' 00:00:00', substr($now, 0, 10) . ' 23:59:59' ];	
	}
	elsif(ref($params{'range'}) ne 'ARRAY')
	{
		$params{'range'} = [ substr($params{'range'}, 0, 10). ' 00:00:00', substr($params{'range'}, 0, 10) . ' 23:59:59' ];
	}

	# Default start and limit
	$params{'start'} ||= 0;
	$params{'limit'} ||= 250;

	# Placeholder values
	my @values;

	# Allowed search options
	my @ok = qw/userid customer_id server_id module function/;

	# DBIx search parameters
	my $search_params = {};
	map { $search_params->{$_} = $params{$_} if defined $params{$_} } @ok;

	$search_params->{'updated'} = { '-between' => $params{'range'} };
	
	my @res = $self->db->table('intranet_audit')->search(
		$search_params,
		{
			'rows'		=> $params{'limit'},
			'offset'	=> $params{'start'},
			'distinct'	=> $params{'distinct'},
		}
	)->all;

	@res = $self->db->strip(@res) if @res;

	return \@res;
}

1;
