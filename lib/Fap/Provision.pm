=head1 NAME

Fap::Provision;

=head1 SYNOPSIS

  use Fap::Provision;

=head1 DESCRIPTION

Library functions for use by FCS Business Units having to do with provisioning.

=head1 FUNCTIONS

API functions available in this library

=cut

package Fap::Provision;

use Fap;
use Fap::Net::Email;
use Fap::Global;
use Fap::Bundle;


=head2 get_phone_details

=over 4

Returns details about the phones that have been requested with the order.

    Args: db - database handle
          order_id - order id
 Returns: a structure of the following format, a reference to an empty hash if no information found or undef on error.
 	 {
 	'order_group.server_id' => { 'bundle.manufacturer’ . _  . ‘bundle.model' => 3 (qty),
 					   'bundle.manufacturer’ . _  . ‘bundle.model' => 2
 					  }
 	 }

=back

=cut
sub get_phone_details {
    my $db = shift;
    my $order_id = shift;
	
    if ( !defined($db) || ref($db) ne 'Fap::Model::Fcs' ) {
        Fap->trace_error('Invalid db parameter');
        return undef;
    }

    if (!defined($order_id) || $order_id !~ /^\d+$/) {
        Fap->trace_error('Invalid order_id parameter');
        return undef;
    }
	
    my $rs = $db->table('order_group')->search(
        {
            order_id => $order_id
        },
        {
            prefetch => 'order_bundles'
        }
    );
	
    my %ret;
    while (my $row = $rs->next) {
        my $rec = ($db->strip($row));
        foreach my $order_bundle (@{$rec->{'order_bundles'}}) {
            my $bundle = Fap::Bundle->new(
                bundle_id => $order_bundle->{'bundle_id'},
                fcs_schema => $db,
            );

            if (!defined($bundle) || !$bundle->is_phone_bundle()) {
                next;
            }

            my $phone_info = $bundle->get_phone_info();
            $ret{ $rec->{'server_id'} }{ $phone_info->{'manufacturer'} . '_' . $phone_info->{'model'} } = $order_bundle->{'quantity'};
        }
    }
	
    return \%ret;
}

=head2 get_scanned_phones

=over 4

Returns details about the phones that have been scanned for the order.

    Args: db - database handle
          order_id - order id
 Returns: a structure of the following format, a reference to an empty hash if no information found or undef on error.
 	{
 	'order_group.server_id' => { 'bundle.manufacturer’ . _ . ‘bundle.model' => ['0004F123B33','0004F123BE9','0004F1267C3'],
 					 'bundle.manufacturer’ . _ . ‘bundle.model'  => ['0004F4412CC']
 				   }
 	}

=back

=cut
sub get_scanned_phones {
    my $db = shift;
    my $order_id = shift;
	
    if ( !defined($db) || ref($db) ne 'Fap::Model::Fcs' ) {
        Fap->trace_error('Invalid db parameter');
        return undef;
    }

    if (!defined($order_id) || $order_id !~ /^\d+$/) {
        Fap->trace_error('Invalid order_id parameter');
        return undef;
    }
	
    my $order_group_rs = $db->table('order_group')->search(
        {
            order_id => $order_id
        },
        {
            prefetch => {'order_bundles' => 'order_bundle_details'}
        }
    );
    
    my %ret;
    while (my $order_group_row = $order_group_rs->next) {
        my $order_group_data = ($db->strip($order_group_row));
        foreach my $order_bundle (@{$order_group_data->{'order_bundles'}}) {
            if (scalar(@{$order_bundle->{'order_bundle_details'}}) == 0 ) {
                next;
            }
            
            my $bundle = Fap::Bundle->new(
                bundle_id => $order_bundle->{'bundle_id'},
                fcs_schema => $db,
            );
                        
            if (!defined($bundle) || !$bundle->is_phone_bundle()) {
                next;
            }
        
            my $phone_info = $bundle->get_phone_info();
            foreach my $detail (@{$order_bundle->{'order_bundle_details'}}) {
                next unless $detail->{'mac_address'};
                push @{ $ret{ $order_group_data->{'server_id'} }{ $phone_info->{'manufacturer'} . '_' . $phone_info->{'model'} } }, $detail->{'mac_address'};
            }
        }
    }

    return \%ret;
}

=head2 get_phones_to_scan

=over 4

Returns details about the phones that are yet to be scanned.

    Args: ordered_phones - a hashref of info as returned by get_phone_details() 
          scanned_phones - a hashref of info as returned by get_scanned_phones() 
 Returns: a structure of the format as in the example below or undef on error.
	{
	  '12354' => {
				   'Polycom_SPIP331' => 3
				 }
	};

=back

=cut
sub get_phones_to_scan {
	my $ordered_phones = shift;
	my $scanned_phones = shift;

	if (!defined($ordered_phones) || ref($ordered_phones) ne 'HASH') {
        Fap->trace_error('Invalid ordered_phones parameter');
        return undef;
	}
	
	if (!defined($scanned_phones) || ref($scanned_phones) ne 'HASH') {
        Fap->trace_error('Invalid scanned_phones parameter');
        return undef;
	}
	
	my $leftover_phones = $ordered_phones;
			
	foreach my $server_id (keys %$leftover_phones) {
		if (!exists $scanned_phones->{$server_id}) {
			next;
		}
		
		foreach my $phone_model (keys %{$leftover_phones->{$server_id}}) {
			if (!exists $scanned_phones->{$server_id}->{$phone_model}) {
				next;
			}
			
			my $ordered_qty = $leftover_phones->{$server_id}->{$phone_model};
			my $scanned_qty = @{$scanned_phones->{$server_id}->{$phone_model}};
			if ($ordered_qty - $scanned_qty > 0) {
				$leftover_phones->{$server_id}->{$phone_model} = $ordered_qty - $scanned_qty;
			} else {
				delete $leftover_phones->{$server_id}->{$phone_model};
			}
		}
		
		if (!%{$leftover_phones->{$server_id}}) {
			delete $leftover_phones->{$server_id};
		}
	}
	
	return $leftover_phones;
}

=head2 get_phones_total

=over 4

Returns the total number of either requested or scanned phones.

    Args: details - a hashref of info as returned by either get_phone_details() or get_scanned_phones()
 Returns: count as scalar or undef on error.

=back

=cut
sub get_phones_total {
	my $details = shift;
	
	if (!defined($details) || ref($details) ne 'HASH') {
        Fap->trace_error('Invalid details parameter');
        return undef;
	}
	
	my $count = 0;
	foreach my $server_id (keys %$details) {
		foreach my $phone_model (keys %{$details->{$server_id}}) {
			if (ref($details->{$server_id}->{$phone_model}) eq 'ARRAY') {
				$count += @{$details->{$server_id}->{$phone_model}};
			} else {
				$count += $details->{$server_id}->{$phone_model};
			}
		}
	}
	
	return $count;
}

=head2 cp_location

=over 4

get the correct cp location based on the entries in Fap::Global::kCP_LOCATION_FILE

   Args: [cp_version]
Returns: cp_location

=back

=cut
sub cp_location
{
    my $cp_version = shift(@_) || Fap::Global::kCP_VERSION();

    my ($FH,$loc);
    open $FH, '<'. Fap::Global::kCP_LOCATION_FILE();
    while (<$FH>)
    {
        chomp($_);
        my @tmp = split(/:/,$_);
        if ($tmp[0] eq $cp_version)
        {
            $loc = $tmp[1];
            last;
        }        	
    }
    close $FH;

    return $loc;
}

=head2 generate_tun_ip

=over 4

Return primary tunnel address for a server ID.

    Args: server_id, is_software 
 Returns: ip | undef if error

 Example: generate_tun_ip($server_id, 1);

=back

=cut
sub generate_tun_ip
{
    my ($server_id, $is_software) = @_;

    my $sid_offset;
    if ($is_software)
    {
        # since we didn't start our IP range at server 1, we need an offset to work
        # by. we started 1.0.0.0 range at server 100146, so that is our offset.
        $sid_offset = 100146;
    }
    else
    {
        $sid_offset = -8285422;
    }

    # generate the decimal equivalent of the IP address (network byte order)
    # add 2 ** 24 (1.0.0.0)
    # subtract 100146 (server ID 100146 is the first server we used in the 1.0.0.0 block)
    # add the current server ID to get the correct offset
    my $decimal = 2 ** 24 - $sid_offset + $server_id;

    # how many IPs we need to reserve (in this case, we need to reserve .0, .1 and .255)
    my $reserve = 3;

    # by default, the reservations will begin at .255 and move backwards, so
    # reserving 3 IPs reserves .253 - .255. by setting this reservation offset
    # to -2, we reserve .255, .0 and .1.
    my $reserve_offset = -2;

    # we can't use .0, .1 and .255 in any range, so we need to find out the number of
    # blocks of 253 IPs (256 minus the 3 IPs), and add 3 * [that number] to
    # the IP (so 255 ends up 258, which is really .2)
    #
    # this is where we use the # of IPs to reserve and the offset of where to begin
    # the reservations from
    $decimal += $reserve * int(($server_id - $sid_offset + $reserve_offset) / (256 - $reserve));

    # convert the decimal to ascii, then unpack the ascii into 4 individual bytes
    my @quad = unpack("C4", pack("N", $decimal));

    # join the four bytes to create our dotted quad ip address!
    my $ip = join(".", @quad);

    return $ip;
}


sub area_code
{
    my $sinfo = shift;

    if (ref($sinfo) ne 'HASH')
    {
	Fap->trace_error("Err: Invalid Parameter");
    }

    if($sinfo->{'localtime_file'} ne '' && $sinfo->{'localtime_file'} =~ /\/usr\/share\/zoneinfo\/Australia/)
    {
        $sinfo->{'localtime_file'} =~ /\/usr\/share\/zoneinfo\/Australia\/(.*)/;
        my $state = lc($1);

        if($state eq 'nsw' || $state eq 'act' || $state eq 'sydney' || $state eq 'canberra' || $state eq 'lord_howe')
        {
            return '02';
        }
        elsif($state eq 'victoria' || $state eq 'melbourne' || $state eq 'tasmania' || $state eq 'hobart')
        {
            return '03';
        }
        elsif($state eq 'south' || $state eq 'west' || $state eq 'north' || $state eq 'adelaide' || $state eq 'perth' || $state eq 'darwin' || $state eq 'broken_hill')
        {
            return '08';
        }
        elsif($state eq 'queensland' || $state eq 'brisbane')
        {
            return '07';
        }
    }

    # not setting area code for non Australian time
    return 0;
}

=head2 add_scanned_phones

=over 4

Inserts details about the phones that have been scanned into the database.

    Args: db - database handle
          order_id - order id
          phone_details - a hashref of info in the format as returned by get_scanned_phones() 
 Returns: 1 on success, undef on error

=back

=cut
sub add_scanned_phones {
	my $db = shift;
	my $order_id = shift;
	my $phone_details = shift;
	
    if ( !defined($db) || ref($db) ne 'Fap::Model::Fcs' ) {
        Fap->trace_error('Invalid db parameter');
        return undef;
    }

	if (!defined($order_id) || $order_id !~ /^\d+$/) {
        Fap->trace_error('Invalid order_id parameter');
        return undef;
	}
	
	if (!defined($phone_details) || ref($phone_details) ne 'HASH') {
        Fap->trace_error('Invalid phone_details parameter');
        return undef;
	}
	
	foreach my $server_id (keys %$phone_details) {
		foreach my $phone_model (keys %{$phone_details->{$server_id}}) {
			foreach my $mac (@{$phone_details->{$server_id}->{$phone_model}}) {
				my $order_group_rs = $db->table('order_group')->search(
					{
						order_id => $order_id
					},
					{
						select => [ qw/me.order_group_id order_id server_id order_bundle_id bundle_id quantity/ ],
						prefetch => 'order_bundles'
					}
				);
				
				while (my $order_group_row = $order_group_rs->next) {
					my %order_group_data = $order_group_row->get_columns;
					
					my $bundle = Fap::Bundle->new(
						bundle_id => $order_group_data{'bundle_id'},
						fcs_schema => $db,
					);
					if (!defined($bundle) || !$bundle->is_phone_bundle()) {
						next;
					}
					
					my $phone_info = $bundle->get_phone_info();
					
					if ($server_id == $order_group_data{'server_id'} &&
							$phone_model eq $phone_info->{'manufacturer'} . '_' . $phone_info->{'model'}) {
						eval {
							$db->table('order_bundle_detail')->create(
								{
									order_bundle_id => $order_group_data{'order_bundle_id'},
									mac_address => $mac
								}
							);
						};
						if ($@) {
							Fap->trace_error("Failed to insert a record into order_bundle_detail table: order_bundle_id = $order_bundle_id mac_address = $mac");
							return undef;
						}
					}
				}
			}
		}
	}
	
	return 1;
}

1;
