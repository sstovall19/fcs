=head1 NAME

Fap::User

=head1 SYNOPSIS

 use Fap::User;

=head1 DESCRIPTION

Wrappers for library functions in F::User (accessing and maintaining user table).

=head1 FUNCTIONS

API functions available in this library

=cut

package Fap::User;

use strict;
use F::Globals;
use F::User;
use Fap::Devices;
use Fap::Extensions;
use Fap::Util;
use Fap::Model::Fcs;

=head2 create_user

=over 4

Creates a user and a primary extension attached to them.
If exten is defined finds the user to whom it belongs and creates an additional extension for that user.

   Args: server_id, license, [exten]
Returns: { user_id => $user_id, extension => $extension } on success, undef on error

=back

=cut
sub create_user {
	my $server_id = shift;
	my $lic = shift;
	my $exten = shift;
	
	if (!Fap::Util::is_valid_server_id($server_id)) {
		Fap->trace_error('Invalid server id');
		return undef;
	}
	
	if (!defined($lic) || $lic eq '') {
		Fap->trace_error('Invalid license');
		return undef;
	}
	
	my $db = Fap::Model::Fcs->new();

	my $null_dev = Fap::Devices::get_nophone_for_server($db, $server_id);
	if (!defined($null_dev)) {
		Fap->trace_error('Failed to get null device for the server');
		return undef;
	}

	my $new_exten = Fap::Extensions::get_next_available_extension($F::Globals::dbh, $server_id);
	if (!defined($new_exten)) {
		Fap->trace_error('Failed to get next available extension');
		return undef;
	}
	
	my $user_id = undef;
	if (Fap::Util::is_valid_extension($server_id, $exten)) {
		my $u_info = get_user_info_by_ext_and_server($db, $exten, $server_id);
		if (!defined($u_info)) {
			Fap->trace_error('Failed to get user info');
			return undef;
		}
		$user_id = $u_info->{'user_id'};
	}

	my $options_hashref = {
		'extension' => $new_exten,
		'device_id' => $null_dev->{'device_id'},
		'server_id' => $server_id,
		'username' => $server_id . '_' . $new_exten,
		'location' => 'Main office',
		'password' => Fap::Util::return_random_password(),
		'vm_pass' => Fap::Util::return_random_number(4)
	};

	my $ret;
	if (defined($user_id)) {
		$ret = Fap::Extensions::add_extension($F::Globals::dbh, $options_hashref, $user_id);
	} else {
		$ret = Fap::Extensions::add_extension($F::Globals::dbh, $options_hashref);
	}
	
	if (!defined($ret)) {
		Fap->trace_error('Failed to add extension');
		return undef;
	}
	
	if (!defined($user_id)) {
		my $u_info = get_user_info_by_ext_and_server($db, $new_exten, $server_id);
		if (!defined($u_info)) {
			Fap->trace_error('Failed to get user info');
			return undef;
		}
		$user_id = $u_info->{'user_id'};
	}
	
	my $user = F::User->new({'dbh' => $F::Globals::dbh, 'server_id' => $server_id, 'user_id' => $user_id});
	$ret = $user->add_license($lic);
	if (!defined($ret)) {
		Fap->trace_error("Failed to add license: $lic");
		return undef;
	}
	
	return { user_id => $user_id, extension => $new_exten };
}

=head2 delete_user

=over 4

Removes a user and all extensions associated with them.

   Args: user_id
Returns: 1 on success, undef on error

=back

=cut
sub delete_user {
	my $user_id = shift;
	
	if (!defined($user_id)) {
		Fap->trace_error('Invalid user_id param');
		return undef;
	}
	
	my $del_user_info = F::User::get_user_info_by_id($F::Globals::dbh, $user_id);
	my $all_exts = F::User::get_extensions_from_user_id($F::Globals::dbh, $user_id);

	# for error msg
	my $user_fullname = $del_user_info->{'first_name'} . " " . $del_user_info->{'last_name'};
	
	my @err_msg; # array to store error messages encountered
	my @ext_nums; # save ext_nums to be deleted

	unless (defined $del_user_info && defined $all_exts)
	{
		Fap->trace_error("Info for user $user_id is incomplete.");
		return undef;
	}
	
	# do a dry run first to remove all extensions
	foreach my $ext (@{$all_exts})
	{
		undef $@;
		my $ext_num = $ext->{extension};
		
		push (@ext_nums, $ext_num);

		F::Extensions::remove_extension($F::Globals::dbh, $del_user_info->{'default_server_id'}, $ext_num, 1);
		
		# error when trying to remove this extension
		if ($@)
		{
			push(@err_msg, "Cannot remove extension ".$ext_num.":\n".$@);
		}
	}

	if (scalar(@err_msg) != 0)
	{
		# there were errors in dry-run
		Fap->trace_error("Cannot remove user \"$user_fullname\":\n" . join("\n", @err_msg));
		return undef;
	}
	
	# delete extensions
	foreach my $ext_num (@ext_nums)
	{
		undef $@;
		
		F::Extensions::remove_extension($F::Globals::dbh, $del_user_info->{'default_server_id'}, $ext_num);
		if ($@)
		{
			push(@err_msg, "Cannot remove extension ".$ext_num.":\n".$@);

			# moving on...
			next;
		}
	}

	if (scalar(@err_msg) != 0)
	{
		Fap->trace_error("There were errors while deleting extensions for user \"$user_fullname\":\n" . join("\n", @err_msg));
		return undef;
	}
	
	# delete user
	my $ret = F::User::remove_user_by_id($F::Globals::dbh, $user_id, $del_user_info->{'default_server_id'});
	if (!defined($ret)) {
		Fap->trace_error("Cannot remove user \"$user_fullname\"");
		return undef;
	}
	
	return 1;
}

=head2 create_admin

=over 4

Creates an admin for a server.
A server can only have one server admin account. If admin account already exist this function returns 1.

   Args: server_id
Returns: 1 on success, undef on error

=back

=cut
sub create_admin {
    my $server_id = shift;
    my $db = Fap::Model::Fcs->new();
    my $rs = $db->table('Server')->find( { server_id => $server_id, } );
    
    if (!$rs->get_column('server_id')) {
        Fap->trace_error('Err: Invalid server id');
        return undef;
    }
    
    my $customer_id = $rs->get_column('customer_id');
    my $rv = F::User::get_admin_list_for_server($server_id);
    if (ref($rv) eq 'ARRAY' && scalar(@{$rv}) > 0) {
        return 1;
    }
    
    my $username = "admin$server_id";
    my $password = Fap::Util::return_random_password(8);

    $rv = F::User::add_user(
        {
            'extension'         => 0,
            'username'          => $username,
            'password'          => $password,
            'type'              => 'cpa',
            'server_ids'        => [$server_id],
            'default_server_id' => $server_id,
            'customer_id'       => $customer_id
        }
    );
    if (not $rv)
    {
        Fap->trace_error("Err: Unable to create an Admin Account for Server $server_id");
        return undef;
    }
    
    return 1;
}

=head2 get_user_list_for_server

=over 4

Get the normal user information for a given server

Args: dbh, server_id
Returns: hashref of user info or undef on error

=back

=cut
sub get_user_list_for_server
{
	my $dbh = shift;
	my $server_id = shift;

	return get($dbh, {'server_id' => $server_id, 'type' => 'cpu'});
}

=head2 get

=over 4

General get function. Other get related function will use this

Args: dbh, $args
Returns: arrayref of user hashref

$args can be any combination of:
   { 'user_id' => xxxx,
     'server_id' => xxx,
     'extension' => xxx,
     'type' => xxx
   }
at least one of server_id, user_id or extension must be specified.

=back

=cut
sub get
{
	my $dbh = shift;
	my $args = shift;

	# check dbh
	if (ref($dbh) ne 'Fap::Model::Fcs') {
		Fap->trace_error('Invalid dbh');
		return undef;
	}

	if (ref($args) ne 'HASH') {
		Fap->trace_error("Invalid arguments");
		return undef;
	}

	my @input_fields = ('server_id', 'user_id', 'extension', 'type');
	my @required_fields = ('server_id', 'user_id', 'extension');

	# check args
	foreach my $input (@input_fields) {
		if ($args->{$input} && (($input eq 'type' && $args->{$input} !~ /^(cpa|cpu)$/) || ($input ne 'type' && $args->{$input} !~ /^\d+$/))) {
			Fap->trace_error("Invalid $input");
			return undef;
		}
	}

	# at least 1 of server id, user id or extension has to be set
	my $required_set = 0;
	foreach my $r (@required_fields) {
		if ($args->{$r}) {
			$required_set = 1;
			last;
		}
	}

	if (!$required_set) {
		Fap->trace_error('Missing input');
		return undef;
	}

	my $where = {};
	foreach my $input (@input_fields) {
		# only set the ones that are specified
		if (!$args->{$input}) {
			next;
		}
		my $field = $input;
		if ($input eq 'server') {
			$field = 'server.server_id';
		} elsif ($input eq 'user_id') {
			$field = 'me.user_id';
		}
		$where->{$field} = $args->{$input};
	}

	my $rs = $dbh->table("PbxtraUser")->search( $where, {join => 'server'} );
	my $ret = [];
	if (!$rs) {
		return $ret;
	} else {
		while (my $row = $rs->next()) {
			my %data = $row->get_columns();
			Fap::Util::utf8ify(\%data);
			push (@{$ret}, \%data);
		}
	}
	
	return $ret;
}
	

=head2 get_user_info_by_id

=over 4

Get the normal user information for a given user_id

Args: user_id
Returns: hashref of user info

=back

=cut
sub get_user_info_by_id
{
	my $dbh = shift;
	my $user_id = shift;

	my $ret = get($dbh, {'user_id' => $user_id});
	if (!$ret) {
		return undef;
	}

	return $ret->[0];
}

=head2 get_user_info_by_ext_and_server

=over 4

Get the normal user information for a given user_id

Args: extension, server_id
Returns: hashref of user info

=back

=cut
sub get_user_info_by_ext_and_server
{
	my $dbh = shift;
	my $exten = shift;
	my $server_id = shift;

	my $ret = get($dbh, {'server_id' => $server_id, 'extension' => $exten});
	if (!$ret) {
		return undef;
	}

	return $ret->[0];
}

=head2 purge_admin

=over 4

Purges the admin for a server.

   Args: server_id
Returns: 1 on success, undef on error

=back

=cut
sub purge_admin {
    my $server_id = shift;
    my $db = Fap::Model::Fcs->new();
    my $rs = $db->table('Server')->find( { server_id => $server_id, } );
    my $serv_info = ($db->strip($rs));
    
    if (!$serv_info->{'server_id'}) {
        Fap->trace_error('Err: Invalid server id');
        return undef;
    }
    
    my $username = "admin$server_id";

    my $rv = F::User::remove_user($username);
    if (not $rv)
    {
        Fap->trace_error("Err: Unable to create an Admin Account for Server $server_id");
        return undef;
    }
    
    return 1;
}

1;
