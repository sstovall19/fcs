# Copyright 2012, Fonality Inc. ALL RIGHTS RESERVED
package Fap::Provider::Symbio;

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

Initialize the Symbio provider object

Args: %args
Returns: none

=back

=cut

sub _init
{
    my ( $self, %args ) = @_;

    # load the Symbio config
    $self->{'_config'} = Fap->load_conf("provider/symbio");

    # instantiate SIPProxy
    $self->{'_sipproxy'} = Fap::SIPProxy->new(
        sip_host => $self->{'_is_test'}
        ? 'devel'
        : $self->{'_config'}->{'proxy'}
    );
    $self->{'_allocator'} = Fap::Provider::DIDAllocator->new( provider => $self->{'_provider_module'} );
}

=head2 create_account()

=over 4

Create OpenSIPS account for Symbio

Args: $server_id
Returns: $voip_name if successful, undef otherwise
Example: my $ret = $provider->create_account(20694);

=back

=cut

sub create_account
{
    my ( $self, $server_id ) = @_;

    # check input
    if ( $server_id !~ /^\d+$/ )
    {
        Fap->trace_error("Invalid Server ID: $server_id");
        return undef;
    }

    # generate the password
    my $pass = Fap::Util::return_random_string(17);
    $self->set_password($pass);

    my $chk = $self->{'_sipproxy'}->add_subscriber( $server_id, $pass );
    if ( !$chk )
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
    my ( $self, $server_id ) = @_;

    # check input
    if ( !$self->_check_sid($server_id) ) { return undef; }

    my $chk = $self->{'_sipproxy'}->delete_subscriber($server_id);
    if ( !$chk )
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
    my ( $self, $server_id ) = @_;

    # check input
    if ( !$self->_check_sid($server_id) ) { return undef; }

    my $params = $self->{'_config'}->{'conf'};
    $params->{'fromuser'} = $server_id;
    $params->{'secret'}   = $self->get_password();
    $params->{'username'} = $server_id;

    return $params;
}

=head2 purchase_dids()

=over 4

Purchase the given DIDs from Symbio provider.

Args: $server_id, $array_of_dids, $did_type
      $did_type: can be any of "did_number", "did_international", "paperless_fax_did", "did_tollfree".
      $array_of_dids can be either full numbers or area codes

Returns: $array_of_dids purchased or undef if there are any errors
Example: $dids = $provider->purchase_dids(20694, [215,215]);
         This will purchase 2 DIDs with area code 215 from provider

=back

=cut

sub purchase_dids
{
    my ( $self, $server_id, $dids, $did_type ) = @_;

    # check input
    if ( !$self->_check_sid($server_id) ) { return undef; }

    # check dids
    if ( ref($dids) ne 'ARRAY' || scalar( @{$dids} ) == 0 )
    {
        Fap->trace_error("Empty DIDs");
        return undef;
    }

    if ( !$self->_check_allocator() ) { return undef; }
    my $allocator = $self->{'_allocator'};

    my @picked_dids;

    for my $prefix ( @{$dids} )
    {
        my $available_dids = $allocator->get_dids_for_area_code($prefix);

        # Reduce available list by those already picked.
        $available_dids = $allocator->reduce_available_dids( $available_dids, \@picked_dids );
        my $number_of_dids_available = scalar @{$available_dids};

        if ( !$number_of_dids_available )
        {
            Fap->trace_error("Requested area code: ${prefix} (not available)");
            return undef;
        }

        push @picked_dids, $available_dids->[0];
    }

    my $dids_not_reserved = $allocator->reserve_dids( $self->{'_server_info'}->{'details'}->{'customer_id'}, \@picked_dids );
    if ( scalar @{$dids_not_reserved} )
    {
        my $shit_list = join ', ', @{$dids_not_reserved};
        my $message = "ERROR: We could not reserve the dids: $shit_list.  You must try again for all DIDs.
        i.e. None were reserved because we could not reserve them all\n";
        Fap->trace_error($message);
        return undef;
    }

    my $purchase_result = $allocator->purchase_dids( $self->{'_server_info'}->{'details'}->{'customer_id'}, $server_id, \@picked_dids );
    if ( !$purchase_result )
    {
        Fap->trace_error("ERROR: Purchase of all DIDs was not successful");
        return undef;
    }

    my $routing_result = $allocator->route_dids( $self->{'_is_test'} ? 'devel' : $self->{'_config'}->{'proxy'}, $server_id, \@picked_dids );
    if ( !$routing_result )
    {
        Fap->trace_error("ERROR: Routing of DIDs was not successful");
        return undef;
    }

    my $mapping_result = $allocator->update_unbound_map( $server_id, $self->{'_server_info'}->{'mosted'}, \@picked_dids );
    if ( !$mapping_result )
    {
        Fap->trace_error("ERROR: Updateing unbound map of DIDs was not successful");
        return undef;
    }

    # call parent purchase_dids()
    return $self->SUPER::purchase_dids( $server_id, \@picked_dids, $did_type );
}

=head2 delete_dids()

=over 4

Delete the given DIDs from Symbio provider.

Args: $server_id, $array_of_dids
Returns: $array_of_dids cancelled or undef if there are any errors
Example: $dids = $provider->delete_dids(20694, [12158613321,12158613322]);

=back

=cut

sub delete_dids
{
    my ( $self, $server_id, $dids ) = @_;

    # check server id
    if ( !$self->_check_sid($server_id) ) { return undef; }

    # check dids
    if ( !$self->_check_dids($dids) ) { return undef; }

    if ( !$self->_check_allocator() ) { return undef; }
    my $allocator = $self->{'_allocator'};

    my $free_result = $allocator->free_dids( $server_id, $dids );
    if ( !$free_result )
    {
        Fap->trace_error("ERROR: the dids were not free up correctly.\n");
        return undef;
    }

    my $unroute_result = $allocator->unroute_dids( $self->{'_is_test'} ? 'devel' : $self->{'_config'}->{'proxy'}, $server_id, $dids );
    if ( !$unroute_result )
    {
        Fap->trace_error("ERROR: the dids were not unrouted correctly\n");
        return undef;
    }

    my $unmap_result = $allocator->delete_unbound_map( $server_id, $self->{'_server_info'}->{'mosted'}, $dids );
    if ( !$unmap_result )
    {
        Fap->trace_error("ERROR: the dids were not unmapped correctly\n");
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
    my ( $self, $server_id, $dids, $did_type ) = @_;

    # check server id
    if ( !$self->_check_sid($server_id) ) { return undef; }

    # check dids
    if ( !$self->_check_dids($dids) ) { return undef; }

    if ( !$self->_check_allocator() ) { return undef; }
    my $allocator = $self->{'_allocator'};

    my $res = $allocator->route_dids( $self->{'_is_test'} ? 'devel' : $self->{'_config'}->{'proxy'}, $server_id, $dids );
    if ( !$res )
    {
        Fap->trace_error("ERROR: Routing of ported DIDs was not successful");
        return undef;
    }

    my $res = $allocator->update_unbound_map( $server_id, $self->{'_server_info'}->{'mosted'}, $dids );
    if ( !$res )
    {
        Fap->trace_error("ERROR: Updateing unbound map of DIDs was not successful");
        return undef;
    }

    return $self->SUPER::purchase_dids( $server_id, $dids, $did_type );
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
    my ( $self, $server_id, $dids ) = @_;

    # check server id
    if ( !$self->_check_sid($server_id) ) { return undef; }

    # check dids
    if ( !$self->_check_dids($dids) ) { return undef; }

    if ( !$self->_check_allocator() ) { return undef; }
    my $allocator = $self->{'_allocator'};

    my $chk = $allocator->unroute_dids( $self->{'_is_test'} ? 'devel' : $self->{'_config'}->{'proxy'}, $server_id, $dids );
    if ( !$chk )
    {
        Fap->trace_error("ERROR: Unrouting of ported DIDs failed");
        return undef;
    }

    my $chk = $allocator->delete_unbound_map( $server_id, $self->{'_server_info'}->{'mosted'}, $dids );
    if ( !$chk )
    {
        Fap->trace_error("ERROR: the dids were not unmapped correctly\n");
        return undef;
    }

    return $self->SUPER::delete_dids( $server_id, $dids );
}

=head2 get_available_dids()

=over 4

Get the available DIDs from Symbio given an array of regions/states and/or area_codes.

Args: $arrayref_of_regions, [$arrayref_of_areacodes (optional)]
Returns: $arrayref_of_avialable_dids in the form of:
         [
           {
             'number' => '0284842601',
             'region' => 'New South Wales',
             'stock' => '1'
           },
           {
             'number' => '0387290121',
             'region' => 'Victoria',
             'stock' => '1'
           },
           {
             'number' => '0245123511',
             'region' => 'New South Wales',
             'stock' => '1'
           }
         ]
         or undef if there are any errors

Example: $dids = $provider->get_available_dids();

=back

=cut

sub get_available_dids
{
    my ( $self, $regions, $area_codes ) = @_;

    if ( defined($area_codes)
        && ( ref($area_codes) ne 'ARRAY' || scalar( @{$area_codes} ) == 0 ) )
    {
        Fap->trace_error("Invalid area codes");
        return undef;
    }

    if ( !$self->_check_allocator() ) { return undef; }
    my $allocator = $self->{'_allocator'};

    my @avail_dids;

    for my $prefix ( @{$area_codes} )
    {
        my $dids = $allocator->get_dids_for_area_code($prefix);

        for my $did ( @{$dids} )
        {
            push( @avail_dids, { 'number' => $did, 'area_code' => $prefix, 'stock' => 1 } );
        }
    }

    return \@avail_dids;
}

=head2 _check_allocator()

=over 4

Check if we already hava an allocator object cached in the call variables. If not, create one.

Args: none
Returns: 1 if successful, undef otherwise
Example: $self->_check_allocator();

=back

=cut

sub _check_allocator
{
    my $self = shift;

    return 1 if defined $self->{'_allocator'};

    $self->{'_allocator'} = Fap::Provider::DIDAllocator->new( provider => $self->{'_provider_module'} );
    if ( !$self->{'_allocator'} )
    {
        Fap->trace_error("Failed to get an instance of DID allocator");
        return undef;
    }
    return 1;
}

1;
