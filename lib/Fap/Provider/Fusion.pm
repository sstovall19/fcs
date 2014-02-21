# Copyright 2012, Fonality Inc. ALL RIGHTS RESERVED
package Fap::Provider::Fusion;

use strict;
use Fap;
use Fap::Provider;
use Fap::Provider::DIDAllocator;
use Fap::SIPProxy;
use Fap::Util;
use Fap::Global;

use base "Fap::Provider";

=head2 _init()

=over 4

Initialize the Fusion provider object

Args: %args
Returns: none

=back

=cut
sub _init
{
    my ($self, %args) = @_;

    # load the Fusion config
    $self->{'_config'} = Fap->load_conf("provider/fusion");
    # instantiate SIPProxy
    $self->{'_sipproxy'} = Fap::SIPProxy->new(sip_host => $self->{'_is_test'} ? 'devel' : $self->{'_config'}->{'proxy'});
    # instantiate DIDAllocator
    $self->{'_allocator'} = Fap::Provider::DIDAllocator->new('provider' => $self->{'_provider_module'});
}

=head2 create_account()

=over 4

Create OpenSIPS account for Fusion

Args: $server_id
Returns: $voip_name if successful, undef otherwise
Example: my $ret = $provider->create_account(20694);

=back

=cut
sub create_account
{
    my ($self, $server_id) = @_;

    # check input
    if($server_id !~ /^\d+$/)
    {
        Fap->trace_error("Invalid Server ID: $server_id");
        return undef;
    }

    # generate the password
    my $pass = Fap::Util::return_random_string(17);
    $self->set_password($pass);

    my $chk = $self->{'_sipproxy'}->add_subscriber($server_id, $pass);
    if(!$chk)
    {
        Fap->trace_error("Failed to create OpenSIPS account for $server_id: $@");
        return undef;
    }

    # call parent create_account()
    $self->set_provider_username($server_id);
    return $self->SUPER::create_account($server_id);
}

=head2 delete_account()

=over 4

Delete OpenSIPS account for this server

Args: $server_id
Returns: 1 if successful, undef otherwise
Example: $provider->delete_account(20694);

=back

=cut
sub delete_account
{
    my ($self, $server_id) = @_;

    # check input
    if(!$self->_check_sid($server_id)) { return undef; }

    my $chk = $self->{'_sipproxy'}->delete_subscriber($server_id);
    if(!$chk)
    {
        Fap->trace_error("Failed to remove OpenSIPS account for $server_id: $@");
        return undef;
    }

    # call parent delete_account()
    return $self->SUPER::delete_account($server_id);
}

=head2 get_voip_param()

=over 4

Get specific params to create the VoIP account

Args: $server_id
Returns: $hashref of params
         or undef if there are any errors
Example: $provider->get_voip_params();

=back

=cut
sub get_voip_param
{
    my ($self, $server_id) = @_;

    # check input
    if(!$self->_check_sid($server_id)) { return undef; }

    my $params = $self->{'_config'}->{'conf'};
    $params->{'fromuser'} = $server_id;
    $params->{'secret'}   = $self->get_password();
    $params->{'username'} = $server_id;

    return $params;
}

=head2 purchase_dids()

=over 4

Purchase the given DIDs from Fusion provider.

Args: $server_id, $array_of_dids, $did_type
      $did_type: can be any of "did_number", "did_international", "paperless_fax_did", "did_tollfree".
      $array_of_dids can be either full numbers or area codes

Returns: 1 successful purchased or undef if there are any errors
Example: $chk = $provider->purchase_dids(20694, [0507575893,0508318066], 'did_number');

=back

=cut
sub purchase_dids
{
    my ( $self, $server_id, $desired_dids, $did_type ) = @_;
    my @rdids;
    
    # check input
    if ( !$self->_check_sid($server_id) ) { return undef; }

    # check dids
    if(!$self->_check_dids($desired_dids)) { return undef; }
    
    foreach my $did (@{$desired_dids})
    {
        if( $did !~ /^050\d+$/ )
        {
            Fap->trace_error("ERR: Invalid DID. ($did)");
            return undef;
        }
        $did =~ s/^0/81/g;
        push(@rdids, $did);
    }
    
    my $chk = $self->{'_allocator'}->route_dids( 
        $self->{'_is_test'} ? 'devel' : $self->{'_config'}->{'proxy'},
        $server_id, 
        \@rdids 
    );
    if(!$chk)
    {
        Fap->trace_error("ERR: Failed to route DIDs for Fusion: $@");
        return undef;
    }

    $chk = $self->{'_allocator'}->update_unbound_map($server_id, $self->{'_server_info'}->{'mosted'}, \@rdids );
    if ( !$chk )
    {
        Fap->trace_error("ERR: Failed to map DIDs for Fusion: $@");
        return undef;
    }
    
    # call parent purchase_dids()
    return $self->SUPER::purchase_dids($server_id, $desired_dids, $did_type );
}

=head2 delete_dids()

=over 4

Delete the given DIDs from Fusion provider.

Args: $server_id, $array_of_dids
Returns: 1 successful purchased or undef if there are any errors
Example: $dids = $provider->delete_dids(20694, [12158613321,12158613322]);

=back

=cut
sub delete_dids
{
    my ( $self, $server_id, $dids ) = @_;
    my @rdids;

    # check server id
    if ( !$self->_check_sid($server_id) ) { return undef; }

    # check dids
    if ( !$self->_check_dids($dids) ) { return undef; }

    foreach my $did (@{$dids})
    {
        $did =~ s/^0/81/g;
        push(@rdids, $did);
    }
    
    my $chk = $self->{'_allocator'}->unroute_dids( 
        $self->{'_is_test'} ? 'devel' : $self->{'_config'}->{'proxy'},
        $server_id, 
        \@rdids 
    );
    if( !$chk )
    {
        Fap->trace_error("ERROR: the DIDs were not unrouted correctly: $@");
        return undef;
    }

    $chk = $self->{'_allocator'}->delete_unbound_map( $server_id, $self->{'_server_info'}->{'mosted'}, \@rdids );
    if ( !$chk )
    {
        Fap->trace_error("ERROR: the DIDs were not unmapped correctly: $@");
        return undef;
    }
    
    # call parent delete_dids()
    return $self->SUPER::delete_dids( $server_id, $dids );
}

=head2 process_lnps()

=over 4

Process the LNP in the provider side and update Fonality db.

Args: $server_id, $array_of_dids, $did_type
$did_type: can be any of "did_number", "did_international", "paperless_fax_did", "did_tollfree".
$array_of_dids must be full numbers

Returns: $array_of_lnps ported or undef if there are any errors
Example: $dids = $provider->process_lnps(20694, [13108614300,13108614301],'did_number');

=back

=cut
sub process_lnps 
{
    my ($self, $server_id, $dids, $did_type) = @_;
    
    return $self->purchase_dids($server_id, $dids, $did_type);
}

=head2 cancel_lnps()

=over 4

Cancel the LNP from the provider side and update Fonality db.

Args: $server_id, $array_of_lnps
Returns: $array_of_lnps released or undef if there are any errors
Example: $dids = $provider->cancel_lnps(20694, [13108614300,13108614301]);

=back

=cut
sub cancel_lnps 
{
    my ($self, $server_id, $dids) = @_;

    return $self->delete_dids($server_id, $dids);
}

=head2 get_emergency_addresses()

=over 4

Get the emergency(E911) addresses associated with the given array of DIDs.

Args: $server_id, $arrayref_of_dids
Returns: $hashref_of_address
         or undef if there are any errors
Example: my $addresses = $provider->get_emergency_addresses(20694, ['13108614300']);
             {
               '13108614300' => {
                  'first_name' => 'Felix',
                  'last_name' => 'Nilam',
                  'house_number' => '200',
                  'house_number_suffix' => '',
                  'prefix_directional' => '',
                  'street_name' => 'Corporate',
                  'street_suffix' => 'PT',
                  'post_directional' => '',
                  'city' => 'Culver City',
                  'state' => 'CA',
                  'postal_code' => '90230',
                  'unit_number' => '350',
                  'unit_type' => 'suite',
                  'country' => 'US',
               }
             }

=back

=cut
sub get_emergency_addresses
{
    my ($self, $server_id, $dids) = @_;
    
    # Currently fusion doesn't implement emergency number
    # so we simply just return a list did 
    my $addresses = {};
    foreach my $did (@{$dids})
    {
        $addresses->{$did} = {};
    }
    
    return $addresses;
}

=head2 set_emergency_addresses()

=over 4

Set the emergency(E911) addresses associated with the given array of DIDs.

Args: $server_id, $arrayref
      $arrayref is of the form:
       [
         {
            'did' => '13108614300',
            'address' => 
                { 
                  'first_name' => 'Felix',
                  'last_name' => 'Nilam',
                  'house_number' => '200',
                  'house_number_suffix' => '',
                  'prefix_directional' => '',
                  'street_name' => 'Corporate',
                  'street_suffix' => 'PT',
                  'post_directional' => '',
                  'city' => 'Culver City',
                  'state' => 'CA',
                  'postal_code' => '90230',
                  'unit_number' => '350',
                  'unit_type' => 'suite',
                  'country' => 'US',
               }
         }
       ]

Returns: 1 if successful, undef otherwise
Example: my $chk = $provider->set_emergency_addresses(20694, [
             { 'did' => '13108614300',
               'address' => {
                  'first_name' => 'Felix',
                  'last_name' => 'Nilam',
                  'house_number' => '200',
                  'house_number_suffix' => '',
                  'prefix_directional' => '',
                  'street_name' => 'Corporate',
                  'street_suffix' => 'PT',
                  'post_directional' => '',
                  'city' => 'Culver City',
                  'state' => 'CA',
                  'postal_code' => '90230',
                  'unit_number' => '350',
                  'unit_type' => 'suite',
                  'country' => 'US',
               }
             }
            ] );
=back

=cut
sub set_emergency_addresses
{
    my ($self, $server_id, $info) = @_;
    
    # Currently fusion doesn't implement emergency number
    # so we simply just return 1 for now
    return 1;
}    
1;