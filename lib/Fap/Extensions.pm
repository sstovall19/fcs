=head1 NAME

Fap::Extensions

=head1 SYNOPSIS
 
  use Fap::Extensions;

=head1 DESCRIPTION

Wrappers for library functions in F::Extensions (extension management).

=head1 FUNCTIONS

API functions available in this library

=cut
	
package Fap::Extensions;

use strict;
use F::Extensions;
use Fap::Util;
use Fap::Model::Fcs;

=head2 get_next_available_extension

=over 4

This will get the next extension available for use.
For detailed description refer to F::Extensions::get_next_available_extension

   Args: dbh,server_id,test_extensions (optional), test_extension_length (optional), test_used_keypress (optional), debug (optional print flag)
Returns: extension

=back

=cut

#######################################################################
# get_next_available_extension
#######################################################################

sub get_next_available_extension
{
	return F::Extensions::get_next_available_extension(@_);
}

=head2 add_extension

=over 4

Add a new extension to the system.

Args: [dbh,]options_hashref,[user_id]

  Options hashref format:
  { 
	'extension' => int, 
	'device_id' => int,
	'server_id' => int, 
	'username' => string, 
	'password' => string, 
  # The following arguments are optional
	'override_phone' => boolean,        # default = 0
	'first_name' => string,             # default = null
	'last_name' => string,              # default = null
	'caller_id' => (default|main|blocked|number), # default = default
	'vm_enabled' => boolean,            # default = 1
	'mailbox' => string,                # default = extension
	'vm_pass' => string,                # default = 1234
	'vm_attach' => boolean,             # default = 0
	'vm_email' => string,               # default = null
	'vm_pager' => string,               # default = null
	'phone_number' => string,           # default = null
	'is_private' => boolean,            # default = 0
	'insert_into_dir' => boolean,       # default = 1
	'in_blast_group' => boolean,        # default = 0
	'in_hud' => boolean,      			# default = 1
	'press_to_accept' => boolean,		# default = 0 
	'auto_logoff' => boolean,			# default = 0 
	'description' => string,            # default = null
	'incominglines' => int,             # default = 0 (unlimited)
	'ring_seconds' => int,              # default = 20
	'q_ignore_if_busy' => int,          # default = 1
	'q_call_on_qcall' => int,           # default = 0
	'q_dont_req_pass' => int,           # default = 0
	'call_return' => int,           	# default = 1
	'call_out' => int,           		# default = 0
	'in_company_dir' => int,          	# default = 1
	'vm_auto_delete' => int,      		# default = 0
	'address_id'       => int           # default = null
	'employee_email'       => string    # default = null
	'employee_im'       => string       # default = null
	'employee_phonenumber' => string    # default = null
  }

Returns: 1=success, undef=Error

=back

=cut
#############################################################################
# add_extension 
#############################################################################
sub add_extension 
{
	return F::Extensions::add_extension(@_);
}

=head2 remove_extension

=over 4

Remove an existing extension from the system
dry run flag is used to test whether deleting the extension will succeed without actually
deleting it.  This is used for deleting user with multiple extensions

   Args: [dbh,]server_id,extension_number,dry_run_flag
Returns: 1=success, undef=Error

=back

=cut

#############################################################################
# remove_extension
#############################################################################
sub remove_extension 
{
	return F::Extensions::remove_extension(@_);
}

=head2 get

=over 4

Get the extension information from database
Args: dbh, server_id, extension
Returns: hashref of extension info

=back

=cut
sub get
{
	my $dbh = shift;
	my $server_id = shift;
	my $ext = shift;

	# check dbh
	if (ref($dbh) ne 'Fap::Model::Fcs') {
		Fap->trace_error('Invalid dbh');
		return undef;
	}

	# check server id and ext
	if ($server_id !~ /^\d+$/ || $ext !~ /^\d+$/) {
		Fap->trace_error('Invalid Server ID / extension');
		return undef;
	}

	my $rs = $dbh->table("PbxtraExtension")->search(
			{'me.server_id' => $server_id, 'me.extension' => $ext},
			{prefetch => 'user', '+columns' => ['user.first_name', 'user.last_name']}
		 )->single();
	if (!$rs) {
		Fap->trace_error("Cannot find extension $ext");
		return undef;
	} else {
		my %data = $rs->get_columns();
		# utf8 encode
		Fap::Util::utf8ify(\%data);
		return \%data;
	}
}

1;
