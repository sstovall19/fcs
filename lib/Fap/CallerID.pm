=head1 NAME

Fap::CallerID

=head1 SYNOPSIS

  use Fap::CallerID;

=head1 DESCRIPTION

Wrappers for library functions for outbound Caller-ID management

=head1 FUNCTIONS

API functions available in this library

=cut

package Fap::CallerID;

use F::CallerID;
use F::Globals;

=over 4

Set the CallerID for a server or specific extension

 Example: set_caller_id($dbh, 1000, 3105551212, "Joe")
 Example: set_caller_id($dbh, 1000, 3105551212, "Joe", 1111)

If the extension is not specified, CallerID is set as the default
for the entire server. Last argument "no sync", if 1, does not sync the 
pbxtra fast db down to the server (only use this if you do it yourself)

    Args: server_id, phone number, name[, extension, no sync]
 Returns: 1 if updated | undef if error

=back

=cut

##############################################################################
# set_caller_id
##############################################################################
sub set_caller_id
{
	return F::CallerID::set_caller_id($F::Globals::dbh, @_);
}

=head2 get_caller_id

=over 4

Get the CallerID for a server or specific extension

 Example: get_caller_id($dbh, 1000)
 Example: get_caller_id($dbh, 1000, 1111)

    Args: server_id[, extension]
 Returns: phone number, name, status | undef if error

 status will be main, blocked, default, or the actual number

=back

=cut

##############################################################################
# get_caller_id
##############################################################################
sub get_caller_id
{
	return F::CallerID::get_caller_id($F::Globals::dbh, @_);	
}

=head2 remove_caller_id

=over 4

Remove the CallerID setting from the database for the given extension. If no 
extension is provided, then the default caller-id entry for the given 
server_id will be removed.

 Example: remove_caller_id($dbh, 1000, 1111) # Remove ext 1111's caller-id
 Example: remove_caller_id($dbh, 1000) # Remove default for server_id 1000

    Args: server_id[, extension]
 Returns: 1 if updated | undef if error

=back

=cut

##############################################################################
# remove_caller_id
##############################################################################
sub remove_caller_id
{
	return F::CallerID::remove_caller_id($F::Globals::dbh, @_);
}

1;
