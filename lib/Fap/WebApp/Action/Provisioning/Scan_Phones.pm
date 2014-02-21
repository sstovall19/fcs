#!/usr/bin/perl

use strict;
use Fap;
use Fap::Order;
use Fap::Provision;

=head2 process_Scan_Phones

=over 4

	Entry point.

=back

=cut
sub process_Scan_Phones
{
	my $self = shift;

	$self->title('Scan Phones for Provisioning');

	my $action = $self->valid->param('action');

	if($action eq 'get_order_id')
	{
		my $order_id = $self->valid->param('order_id', 'numbers');

		if($order_id)
		{
			my $order_details = $self->Provisioning_Scan_Phones_order_details($order_id);
			my $phone_list = $self->Provisioning_Scan_Phones_phone_list($order_id);

			if($order_details)
			{
				$self->tt_append(var => 'order_details', val => $order_details->{'order'});
				$self->tt_append(var => 'phone_list', val => $phone_list);

			}
			else
			{
				$self->write_log(level => 'WARN', log => "Could not load order details [ $@ ]");
				$self->alert('Could not load order ID: ' . $order_id);
			}
		}
		else
		{
			$self->alert('Order ID not provided');
		}
	}
	elsif($action eq 'submit_scanned_phones')
	{
		my $order_id = $self->valid->param('order_id');
		my $scanned_phones = $self->query->param('scanned_phones');
		my $guid = $self->valid->param('guid');

		if($order_id)
		{
			if($scanned_phones)
			{
				if(my $decoded_phone_list = $self->json_decode($scanned_phones))
				{
					my $errors = 0;

					$decoded_phone_list = $decoded_phone_list->{'scanned_phones'};
					# Giant MAC address validation loop 
					# Format of data is
					#
					# Server -> manufacturer -> model -> array of macs
					#
					foreach my $server_id ( keys %{$decoded_phone_list} )
					{
						foreach my $manufacturer ( keys %{$decoded_phone_list->{$server_id}} )
						{
							foreach my $model ( keys %{$decoded_phone_list->{$server_id}->{$manufacturer}} )
							{
								foreach my $phone ( @{$decoded_phone_list->{$server_id}->{$manufacturer}->{$model}} )
								{
									if(!$self->Scan_Phones_validate_mac_address($phone))
									{
										my $error_msg = $@; #"Invalid MAC Address ( $manufacturer $model - Server $server_id ): $phone";
										#my $error_msg = "Invalid MAC Address ( $manufacturer $model - Server $server_id ): $phone";
										$self->write_log(level => 'ERROR', log => $error_msg);
										$self->alert($error_msg);
										$errors++;
									}
								}
							}
						}
					}

					# Were there validation errors?
					if($errors == 0)
					{
						# submit to collector
						my $post_data = {
							phone_list => $self->json_encode($decoded_phone_list)
						};

						my $res = $self->Provisioning_Scan_Phones_insert_phones($decoded_phone_list);
						
						if($res)
						{
							return $self->json_process({ status => 1, redirect => '/?m=Provisioning.Scan_Phones'});
						}
						else
						{
							return $self->json_process({ status => undef, error => "Could not add scanned phones to the order" });
						}
					}
					else
					{
						return $self->json_process({ status => undef, error => $self->alert });
					}

				}
				else
				{
					$self->write_log(level => 'WARN', log => "Invalid JSON string for scanned phone list");
					return $self->json_process({ status => undef, error => "Invalid scanned phone list format" });
				}
			}
			else
			{
				$self->write_log(level => 'ERROR', log => "No scanned phone list provided");
				return $self->json_process({ status => undef, error => "No phone list provided" });
			}
		}
		else
		{
			$self->write_log(level => 'ERROR', log => "No order ID provided");
			return $self->json_process({ status => undef, error => "No order ID provided" });
		}
	}

	# These are the form parameters for the template
	my $form_fields = {
		order_entry => {
			uri	=> 'index.cgi',
			mode	=> 'Provisioning.Scan_Phones',
			action	=> 'get_order_id',
		},
		order_details => {
			uri	=> 'index.cgi',
			mode	=> 'Provisioning.Scan_Phones',
			action	=> 'submit_scanned_phones',
		},
	};

	$self->tt_append(var => 'form_fields', val => $form_fields);

	return $self->tt_process('Provisioning/Scan_Phones.tt');

}

=head2 Scan_Phones_validate_mac_address

=over 4

	Validate a MAC address format.and ensure that the MAC address does not already exist.

	Will convert MAC address to upper case.

	Args   : $mac_address
	Returns: $mac_address or undef on failure

=back

=cut
sub Scan_Phones_validate_mac_address
{
	my($self, $mac_address) = @_;

	if($mac_address)
	{
		$mac_address = uc($mac_address);

		if($mac_address =~ /^[0-9A-F]{12}$/)
		{
			if($self->Provisioning_Scan_Phones_Already_Scanned($mac_address))
			{
				return $self->trace_error("MAC address $mac_address has already been scanned.");
			}

			if($self->Provisioning_Scan_Phones_Already_Exists($mac_address))
			{
				return $self->trace_error("MAC address $mac_address has already been provisioned.");
			}

			return 1;
		}
		else
		{
			return $self->trace_error("Invalid MAC address format: '$mac_address'");
		}
	}
	
	return $self->trace_error("No MAC Address provided");
}

=head2 Scan_Phones_Already_Exists

=over 4

	Checks to see whether a phone is already provisioned on another server ( in the devices table )

	Args   : $mac_address
	Returns: true if exists or undef if not

=back

=cut
sub Provisioning_Scan_Phones_Already_Exists
{
	my($self, $mac_address) = @_;

	if($mac_address)
	{
		$mac_address = uc($mac_address);

		# Try to find it
		my $dev = $self->db->table('devices')->find({ name => 'SIP/'.$mac_address }, { rows => 1 });

		# Found one?
		if($dev)
		{
			return 1;
		}
		else
		{
			
			return undef;
		}

	}

	return undef;	
}

=head2 Provisioning_Scan_Phones_Already_Scanned

=over 4

	Checks to see if a phone is already in the order_bundle_detail table ( already scanned by prov )

	Args   : $mac_address
	Returns: true if exists or undef if not

=back

=cut
sub Provisioning_Scan_Phones_Already_Scanned
{
	my($self, $mac_address) = @_;

	if($mac_address)
	{
		$mac_address = uc($mac_address);

		# Try to find it
		my $dev = $self->db->table('order_bundle_detail')->find({ mac_address => $mac_address }, { rows => 1 });

		# Found one?
		if($dev)
		{
			return 1;
		}
		else
		{
			return undef;	
		}
	}

	return undef;
}

sub Provisioning_Scan_Phones_order_details
{
	my ($self, $order_id) = @_;

	my $order = Fap::Order->new(order_id => $order_id);

	if($order)
	{
		# Get order details
		my $order_details = $order->get_details;

		# Get the company name or first / last name from contact if there is no company name
		my $company_name = $order_details->{'order'}->{'company_name'} ||
		$order_details->{'order'}->{'contact'}->{'first_name'} . ' ' . $order_details->{'order'}->{'contact'}->{'last_name'};

		return $order_details;
	}
	else
	{
		$self->write_log(level => 'ERROR', log => "Invalid order ID $order_id");
		return $self->trace_error("Invalid order ID");
	}

}

sub Provisioning_Scan_Phones_phone_list
{
	my ($self, $order_id) = @_;

	if($order_id)
	{
		if (Fap::Order::validate_prov_order($self->db, $order_id))
		{
			# Retrieve list of phones that have been scanned or need to be scanned	
			my $phone_details = Fap::Provision::get_phone_details($self->db, $order_id);
			my $scanned_phones = Fap::Provision::get_scanned_phones($self->db, $order_id);
			my $phones_to_scan = Fap::Provision::get_phones_to_scan($phone_details, $scanned_phones);

			my $combined_list = {};

			# Combined list
			foreach ( $phones_to_scan, $scanned_phones )
			{
				my $list = $_;

				map {
					my $server_id = $_;

					map {
						my($man, $model) = split('_', $_);

						my $phone_list = $list->{$server_id}->{$_};

						if(ref($phone_list) ne 'ARRAY')
						{
							my $number_of_phones = $phone_list;

							$phone_list = [];

							push(@{$phone_list}, '') for (1..$number_of_phones);
						}

						$combined_list->{$server_id}->{$man}->{$model} ||= [];

						push(@{$combined_list->{$server_id}->{$man}->{$model}}, @{$phone_list});
					} keys %{$list->{$server_id}}; 
				} keys %{$list};
			}

			return $combined_list;
		}
		else
		{
                	return $self->trace_error('Invalid order ID');
		}
	}
	else
	{
		return $self->trace_error('Order ID was not provided');
	}
}

sub Provisioning_Scan_Phones_insert_phones
{
	my ($self, $order_id, $phone_list) = @_;

	if($order_id)
	{
		if($phone_list)
		{
			if (Fap::Order::validate_prov_order($self->db, $order_id))
			{
				# Sloppily convert a normal data structure into an underscore separated manufacturer / model keyed hash ( this is what Fap::Provision wants right now )
				map {
					my $server = $phone_list->{$_};

					map {
						my $manufacturer = $_;
						my $manufacturers = $server->{$_};
						$server->{$manufacturer . '_' . $_} = $manufacturers->{$_} for keys %{$manufacturers};
						delete $server->{$manufacturer};
					} keys %{$server};

				} keys %{$phone_list};

				if(Fap::Provision::add_scanned_phones($self->db, $order_id, $phone_list))
				{
					$self->write_log(level => 'VERBOSE', log => "Insterted phones for order_id $order_id");
					# Restart SM!
					return 1;
				}
				else
				{
					$self->write_log(level => 'ERROR', log => "Could not insert scanned phones: $@");
					return $self->trace_error("Could not insert scanned phones");
				}
			}
			else
			{
				return $self->trace_error('Invalid order ID');
			}
		}
		else
		{
			return $self->trace_error('Phone list not provided');
		}
	}
	else
	{
		return $self->trace_error('Order ID was not provided');
	}
}


sub Provisioning_Scan_Phones_init_permissions
{
	my $self = shift;

	my $perm = {
		DESC => 'Scan IP Phones for provisioning orders',
		LEVELS => 'w',
		VERSION => 1,
	};

	return $perm;
}


1;

