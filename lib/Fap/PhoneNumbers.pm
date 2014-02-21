=head1 NAME

Fap::PhoneNumbers

=head1 SYNOPSIS

  use Fap::PhoneNumbers;

=head1 DESCRIPTION

Library functions for management of phone numbers for DID purposes.

=head1 FUNCTIONS

API functions available in this library

=cut

package Fap::PhoneNumbers;

use F::PhoneNumbers;
use F::Globals;
=head2 update_phone_number

=over 4

Updates a phone number

 Example: update_phone_number($dbh, 1000, "13105551212")	# removes extension
 Example: update_phone_number($dbh, 1000, "13105551212", "")    # removes extension
 Example: update_phone_number($dbh, 1000, "13105551212", undef) # removes extension
 Example: update_phone_number($dbh, 1000, "13105551212", 7002)  # sets direct dial to extension 7002

    Args: server_id, phone number[, extension]
 Returns: 1 if removed | undef if nonexistant

=back

=cut

##############################################################################
# update_phone_number
##############################################################################
sub update_phone_number
{
	return F::PhoneNumbers::update_phone_number($F::Globals::dbh, @_);
}

=head2 remove_phone_number

=over 4

Remove a phone number

 Example: remove_phone_number($dbh, 1000, "13105551212")

    Args: server_id, phone number
 Returns: 1 if removed | undef if nonexistant

=back

=cut

##############################################################################
# remove_phone_number
##############################################################################
sub remove_phone_number
{
	return F::PhoneNumbers::remove_phone_number($F::Globals::dbh, @_);
}

=head2 get_phone_numbers

=over 4

Get phone number list

    Args: server_id [, extension]
 Returns: array | undef

=back

=cut

##############################################################################
# get_phone_numbers
##############################################################################
sub get_phone_numbers
{
	my ($dbh, $server_id, $extension) = @_;

	if (!defined($dbh)) {
		Fap->trace_error("Must pass an fcs dbh");
		return undef;
	}
	if (!defined($server_id)) {
		Fap->trace_error("Must pass a server_id");
		return undef;
	}

	my $where = { 'server_id' => $server_id };
	if (defined($extension)) {
		$where->{'extension'} = $extension;
	}

	my $rs = $dbh->table('PhoneNumber')->search($where);

	my @phonenumbers;
	if ($rs) {
		while (my $row = $rs->next()) {
			if (my %data = $row->get_columns()) {
				push(@phonenumbers, \%data);
			}
		}
	}

	return @phonenumbers;
}

1;
