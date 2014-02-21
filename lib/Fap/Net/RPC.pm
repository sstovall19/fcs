=head1 NAME

Fap::RPC

=head1 SYNOPSIS

 use Fap::RPC;

=head1 DESCRIPTION

Wrappers for library functions in F::RPC

=head1 FUNCTIONS

API functions available in this library

=cut

package Fap::Net::RPC;

use strict;
use F::RPC;

##############################################################################
# rpc_connect: Connects to a remote RPC server
#
#    Args: server_id[,$dbh]
# Returns: RPC::XML object | undef if non-existant server or can't connect
##############################################################################
sub rpc_connect
{
	return F::RPC::rpc_connect(@_);
}

##############################################################################
# rsend_request: 
#
#    Args: $cli, $cmd, @args
# Returns: $out->content
##############################################################################
sub rsend_request
{
	return F::RPC::rsend_request(@_);
}

##############################################################################
# system_call:
#
#    Args: $cli, $server_id, $cmd, $mosted
# Returns: $out->content
##############################################################################
sub system_call
{
        return F::RPC::system_call(@_);
}

##############################################################################
# sync_server:
#
#    Args: $server_id
# Returns: $out->content
##############################################################################
sub sync_server
{
        return F::RPC::sync_server(@_);
}

##############################################################################
# mkdir:
#
#    Args: [$rpc_handle,] $server_id, $path
# Returns: 1 | undef / 0 if error
##############################################################################
sub mkdir
{
        return F::RPC::mkdir(@_);
}

##############################################################################
# ls_stat: Remote stat() on all files in a directory
#
#    Args: server_id, path
# Returns: hashref of arrayrefs of info | undef if error
##############################################################################
sub ls_stat
{
	return F::RPC::ls_stat(@_);
}

=pod 

copy_file: copy a file to a remote server. Sends an instruction to the
           remote system to use HTTP to download the specified file.

    Args: server id, local file path, remote file path, source url
 Returns: In scalar context: 1=success | undef=error
          In list context: list of files unable to copy OR an error message
=cut

sub copy_file
{
	return F::RPC::copy_file(@_);
}

##############################################################################
# mv: Moves a file or directory
#
#    Args: server_id, from, to
# Returns: 1 | undef / 0 if error
##############################################################################
sub mv
{
	return F::RPC::mv(@_);
}

=comment
	Sync all files to server
	@param $verbose is used by rsync_server to print state out to screen
=cut
sub sync_server
{
	return F::RPC::sync_server(@_);
}

1;
