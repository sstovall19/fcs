=head1 NAME

Fap::Devices

=head1 SYNOPSIS

  use Fap::Devices;

=head1 DESCRIPTION

Wrappers for library functions in F::Devices (accessing and maintaining devices table).

=head1 FUNCTIONS

API functions available in this library

=cut

package Fap::Devices;

use strict;
use F::Devices;
use F::Globals;
use F::SIP;
use Fap::Model::Fcs;
use Fap::Extensions;
use Fap::Server;
use Fap::User;

=head2 get_nophone_for_server

=over 4

Get the device ID for the virtual device on a server

Example: get_nophone_for_server($dbh, $server_id);

Args: dbh, server ID
  returns: hashref of information || undef if nonexistant

=back

=cut
################################################################
# get_nophone_for_server
################################################################
sub get_nophone_for_server
{
	my ($dbh, $sid) = @_;

	# check dbh
	if (ref($dbh) ne 'Fap::Model::Fcs') {
		Fap->trace_error("Invalid dbh");
		return undef;
	}
	if ($sid !~ /^\d+/) {
        	Fap->trace_error("Invalid Server ID");
		return undef;
	}

	my $ret = $dbh->table("PbxtraDevice")->single( { server_id => $sid, name => '/dev/null' } );
	if (!defined($ret)) {
		return {};
	}

	my %data = $ret->get_columns();
	return \%data;
}

=head2 add_device

=over 4

Add a new device. The device time can be one of: 
polycom,snom,swissvoice,analog,cisco,aastra,none

 Example: add_device($dbh, 1002, 
	{ 
		'name' => 'SIP/AABBCCDDEEFF',
		'description' => 'Polycom IP300',
		'extension' => 7010,
		'type' => 'polycom'
	}
 );

   Args: [dbh], server_id, hashref_of_info
Returns: device_id | undef=error

=back

=cut

sub add_device
{
	return F::Devices::add_device(@_);
}

=head2 remove_device

=over 4

Remove a device from the database, the box of the customer and /etc/fonality/SID

    Args: device_id
 Returns: 1 if removed | undef if nonexistant
 Example: remove_device($dbh, 1000, 12);

=back

=cut

##############################################################################
# remove_device
##############################################################################
sub remove_device
{
	my $device_id = shift;
	
    my $db = Fap::Model::Fcs->new();

    my $rs = $db->table('Device')->single( { device_id => $device_id } );
    if ( !defined($rs) ) {
        Fap->trace_error('device_id doesn\'t exist');
        return undef;
    }

	return F::Devices::remove_device($F::Globals::dbh, $rs->server_id, $device_id);
}

=head2 get_device_id_from_extensions 

=over 4

Retrieves the device IDs from given server ID and extensions

    Args: server_id, [extension1, extension2, ...]
 Returns: array of device IDs
 Example: get_device_id_from_extensions($dbh, 7133, [7000,7001]);

=back

=cut

sub get_device_id_from_extensions
{
	return F::Devices::get_device_id_from_extensions($F::Globals::dbh, @_);
}

=head2 get_device_by_mac

=over 4

Get all device info for a device by mac

Set kws (boolean) if looking up Kirk Wireless Server.

Example: get_device_by_mac($dbh, 000EEE111222);

Args: dbh, mac, sid, [kws]
  returns: hashref of information || undef if nonexistant

=back

=cut

################################################################
# get_device_by_mac
################################################################
sub get_device_by_mac
{
	return F::Devices::get_device_by_mac($F::Globals::dbh, @_);
}

=head2 get_devices

=over 4

Get all device information from a given server.
If device_id is specified, it will only return the info for that device

Args: dbh, server_id, [device_id]
Returns: arrayref of hashref of device info

=back

=cut
sub get_devices
{
	my $dbh = shift;
	my $server_id = shift;
	my $device_id = shift;

	# check dbh
	if (ref($dbh) ne 'Fap::Model::Fcs') {
		Fap->trace_error('Invalid dbh');
		return undef;
	}

	# server id or device id has to be set
	if ($server_id !~ /^\d+$/ && $device_id !~ /^\d+$/) {
		Fap->trace_error("Invalid input: need Server ID and/or Device ID");
		return undef;
	}

	my $where = {};

	if ($server_id) {
		$where->{'me.server_id'} = $server_id;
	}
	if ($device_id) {
		$where->{'me.device_id'} = $device_id;
	}

	my $rs = $dbh->table("PbxtraDevice")->search($where, { prefetch => 'extensions', '+columns' => ['extensions.extension'] });
	my $ret = [];
	if (!$rs) {
		return $ret;
	} else {
		while (my $row = $rs->next()) {
			my %data = $row->get_columns();
			push (@{$ret}, \%data);
		}
	}

	return $ret;
}

=head2 assign_device

=over 4

Assign device to a particular extension for a server id.

Args: dbh, server_id, device_id, extension
Returns: 1 if successful, 0 otherwise or undef if error

=back

=cut
sub assign_device
{
	my $dbh = shift;
	my $server_id = shift;
	my $device_id = shift;
	my $extension = shift;

	# check dbh
	if (ref($dbh) ne 'Fap::Model::Fcs') {
		Fap->trace_error("Invalid dbh");
		return undef;
	}

	if ($server_id !~ /^\d+$/ || $device_id !~ /^\d+$/ || $extension !~ /^\d+$/) {
		Fap->trace_error('Invalid server id/device id/extension');
		return undef;
	}

	# get device info
	my $device_info = get_devices($dbh, $server_id, $device_id);
	if ($device_info && ref($device_info) eq 'ARRAY') {
		$device_info = $device_info->[0];
	} else {
		Fap->trace_error("Cannot find device with device_id: $device_id");
		return undef;
	}

	# get extension info
	my $ext_info = Fap::Extensions::get($dbh, $server_id, $extension);
	if (!$ext_info) {
		Fap->trace_error("Cannot find extension $extension");
		return undef;
	}

	# get server info
	my $server_info = Fap::Server->new('fcs_schema' => $dbh, 'server_id' => $server_id);
	if (!$server_info) {
		Fap->trace_error("Cannot find server $server_id");
		return undef;
	}

	# Don't change the password, use existing
	my $sip_password = F::SIP::get_sip_password($server_id, $device_info->{'name'});

	# Note that this call updates when it already exists
	my $ret = F::SIP::add_sip_extension($server_id,
		{
			'name'             => $device_info->{'name'},
			'description'      => $extension,
			'cidname'          => $ext_info->{'first_name'} . ' ' . $ext_info->{'last_name'},
			'extension'        => $extension, # primary extension if this is not the primary for the user
			'device_extension' => $extension, # The real extension for this device
			'type'             => $device_info->{'type'},
			'incominglines'    => $ext_info->{'incominglines'},
			'mailbox'	   => $ext_info->{'mailbox'} . ($server_info->{'details'}->{'mosted'} ? '@default-' . $server_id : ''),
			'password'         => $sip_password
		}
	);
	if (!$ret) {
		Fap->trace_error("Failed to add SIP extension for device $device_id and ext $extension");
		return undef;
	}

	# update extensions table
	$ret = $dbh->table('PbxtraExtension')->search( { server_id => $server_id, extension => $extension} )->update( { 'device_id' => $device_id } );
	if (!$ret) {
		Fap->trace_error("Failed to update extensions table");
		return undef;
	}

	# generate phone config files
	F::PhoneConfigs::generate_tftp_config_files_by_extension($server_id, $extension);

	return 1;
}

=head2 unassign_device

=over 4

Unassign given device_id from its corresponding extension

Args: dbh, device_id
Returns: 1 if successful, 0 otherwise or undef if error

=back

=cut
sub unassign_device
{
	my $dbh = shift;
	my $device_id = shift;

	# check dbh
	if (ref($dbh) ne 'Fap::Model::Fcs') {
		Fap->trace_error("Invalid dbh");
		return undef;
	}

	# check device id
	if ($device_id !~ /^\d+$/) {
		Fap->trace_error("Invalid Device ID");
		return undef;
	}

	# get the device info 
	my $device_info = get_devices($dbh, undef, $device_id);
	if ($device_info && ref($device_info) eq 'ARRAY') {
		$device_info = $device_info->[0];
	} else {
		Fap->trace_error("Cannot find device with device_id: $device_id");
		return undef;
	}
	
	my $server_id = $device_info->{'server_id'};
	my $extension = $device_info->{'extension'};

	# remove from sip
	my $ret = F::SIP::remove_sip_extension($server_id, $extension, is_extension => 1);
	if (!$ret) {
		Fap->trace_error("Cannot remove SIP extension for $extension in server $server_id");
		return undef;
	}

	# get the null device id
	my $nophone = get_nophone_for_server($dbh, $server_id);

	# update extensions table
	my $res = $dbh->table('PbxtraExtension')->search( { server_id => $server_id, extension => $extension} )->update( { 'device_id' => $nophone->{'device_id'} } );
	if (!$res) {
		Fap->trace_error("Failed to update extensions table");
		return undef;
	}

	return 1;
}

1;
