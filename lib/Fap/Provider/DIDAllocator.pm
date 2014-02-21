# Copyright 2012, Fonality Inc. ALL RIGHTS RESERVED
package Fap::Provider::DIDAllocator;

use strict;
use Fap;
use Fap::Model::Fcs;
use Fap::Model::Opensips;
use Fap::Util;
use Fap::Global;
use namespace::autoclean;
use List::Util qw/ first /;
use DateTime;

=head1 Synopsis

    use Fap::Provider::DIDAllocator;
    my $allocator = Fap::Provider::DIDAllocator->new('provider' => 'symbio');
    
    my $prefix = 310;
    my @available_dids = $allocator->get_dids_for_area_code($prefix);

    my $customer_id = 1;
    my $did1 = 3108614600;
    my $did2 = 3108614601;
    my $dids_not_reserved = $allocator->reserve_dids($customer_id, [ $did1, $did2, ]);
    if ( scalar @{$dids_not_reserved} ) {
        # Inform the user we could not reserve these dids.
        # All dids must be chosen again because the whole transaction is rolled back.
    }
    
    my $server_id = 7001;
    $allocator->purchase_dids($customer_id, $server_id, $dids);
    my $sip_proxy = 'syd';
    $allocator->route_dids($sip_proxy, $server_id, $dids);

=cut

=head1 Methods

=head2 new

=over 4

Create a new instance of DIDAllocator object

Args: provider => <inphonex|symbio|fusion>
Returns: $self or undef if failed

Example: my $allocator = Fap::Provider::DIDAllocator->new('provider' => 'symbio');

=back
             
=cut

sub new
{
    my ( $class, %args ) = @_;

    if ( !defined( $args{'provider'} ) )
    {
        Fap->trace_error("Missing provider");
        return undef;
    }

    my $pbxtra_dbh = Fap::Model::Fcs->new();
    $pbxtra_dbh->switch_db('pbxtra');

    my $self = bless {
        '_provider'   => $args{'provider'},
        '_pbxtra_dbh' => $pbxtra_dbh,
    }, $class;
    $self->expiry_hours(1);

    return $self;
}

=head2 get_dids_for_area_code

=over 4

Retrieve a list of phone numbers that match an area code.  This notion may be
generalized into a prefix which actually may be longer (or shorter) string.

       Args: ( $prefix ), beginning digits of a phone number, often an area code.
    Returns: an ArrayRef of available DIDs with matching prefix.
             A DID is considered available if it's in stock and not already reserved by 
             a customer, or if it's in stock & the reservation has expired.  
             
    Raw SQL:
    
        SELECT did
          FROM provider_dids
         WHERE provider = ?
           AND did like ?
           AND 
           ( (status = 'available')
             OR
             ((status = 'reserved') AND (expiration < now())))
      ORDER BY did

=back
    
=cut

sub get_dids_for_area_code
{
    my $self      = shift;
    my $area_code = shift;

    my $search_criterion = $area_code . '%';
    my $provider_dids_rs = $self->{'_pbxtra_dbh'}->table('ProviderDid')->search(
        {
            provider => $self->{'_provider'},
            did      => { '-like' => $search_criterion },
            '-or'    => [
                { status => 'available' },
                {
                    status     => 'reserved',
                    expiration => { '<' => \'now()' }
                }
            ]
        },
    );
    my @dids = map { $_->did } $provider_dids_rs->all;

    return \@dids;
}

=head2 get_dids_for_provider

=over 4

Get all the dids a provider has got.

       Args: none or a provider or a hashref

				current hashref potential options:
					fields (arrayref of fields to include in output) defaults to 'did'
    
    Returns: ArrayRef of DIDs

=back

=cut

sub get_dids_for_provider
{
    my $self = shift;
    my %opt;
    if ( ref( $_[0] ) eq 'HASH' )
    {
        %opt = %{ +shift };
    } else
    {
        $opt{'provider'} = shift;
    }
    $opt{'provider'} ||= $self->{'_provider'};

    my $provider_dids_rs = $self->{'_pbxtra_dbh'}->table('ProviderDid')->search( { provider => $opt{'provider'} } );
    my @provider_dids = $provider_dids_rs->all;

    # Don't do further processing if we didn't get anything.
    return ( wantarray ? @provider_dids : \@provider_dids ) unless @provider_dids;

    # Do we want more fields than just did?
    if ( exists( $opt{'fields'} ) && ref( $opt{'fields'} ) eq 'ARRAY' )
    {

        # If they want everything, find out what that means
        # This is hacky and should be done better
        if ( $opt{'fields'}->[0] =~ /all|\*/i )
        {
            $opt{'fields'} = [ keys %{ $provider_dids[0]->{_column_data} } ];
        }

        my @tmp;
        foreach my $did (@provider_dids)
        {
            push @tmp, { map { $_ => $did->$_ } @{ $opt{'fields'} } };
        }
        @provider_dids = @tmp;
    } else
    {

        # by default only return the did
        @provider_dids = map { $_->did } @provider_dids;
    }

    return wantarray ? @provider_dids : \@provider_dids;
}

=head2 reserve_dids

=over 4

Mark a set of DIDs as reserved for this customer in a transation.
The reservation (automatically) expires after $expiry_hours.

       Args: ( $customer_id [$did1, $did2, .. $did3] )
    Returns: An ArrayRef of the DIDs that could NOT be Reserved.
             This may happen if the number is not in our database, 
             has already been purchased or if the number has been 
             reserved by another customer 
             (and the reservation has not expired). 
            
            An empty return list means a successful transaction
            Otherwise the transaction was rolledback and the list
            contains the troublesome dids

Implementation note:  This operation must be atomic & handle multiple customers 
attempting to reserve DIDs simultaneously.

The first hashref passed to search() is the where conditions.  They are 
'and'd together unless '-or' is explicitly stated.

=back
    
=cut    

sub reserve_dids
{
    my $self         = shift;
    my $customer_id  = shift;
    my $dids         = shift;
    my $expiry_hours = shift;

    # Set expiry hours if given.  Will be used to compute the reservation_expiration.
    $self->expiry_hours($expiry_hours) if $expiry_hours;

    # Attempt to reserve each did. tracking unsuccessful dids
    my @dids_not_reserved = ();

    $self->{'_pbxtra_dbh'}->transaction();
    my $all_good = 1;

    foreach my $did ( @{$dids} )
    {
        my $provider_did_rs = $self->{'_pbxtra_dbh'}->table('ProviderDid')->search(
            {
                provider => $self->{'_provider'},
                did      => $did,
                '-or'    => [
                    { status => 'available' },
                    {
                        status     => 'reserved',
                        expiration => { '<' => \"now()" }
                    },
                    {
                        status      => { '<>' => 'purchased' },
                        customer_id => $customer_id,
                    },
                ],
            },
            { for => 'update' }
        );

        # If we can't find the did in the proper state
        # then we store it for later and move on to the next did.
        if ( !$provider_did_rs->count )
        {
            push @dids_not_reserved, $did;
            next;
        }

        # We found the did in a reservable state. Let's now reserve it.
        my $chk = $provider_did_rs->update(
            {
                status      => 'reserved',
                customer_id => $customer_id,
                expiration  => $self->_build_reservation_expiration(),
            }
        );
        if ( !$chk )
        {
            Fap->trace_error("Failed to set $did as reserverd");
            $all_good = 0;
            last;
        }
    }

    if ( !$all_good || @dids_not_reserved )
    {
        $self->{'_pbxtra_dbh'}->rollback();
        Fap->trace_error("Failed to reserver dids");
    }

    $self->{'_pbxtra_dbh'}->commit();

    # An empty return list means a successful transaction
    # Otherwise the transaction was rolledback and the list
    # contains the troublesome dids.
    return \@dids_not_reserved;
}

=head2 purchase_dids

=over 4

Allocate DIDs to the customer within a transaction.

The DIDs must have been previously reserved with a call to reserve_dids.  
This method also updates any provider specific systems that route calls 
to the customer system.  The DIDs will be live when this call is completed.

       Args: ( $customer_id, $server_id, [ did1, did2, did3, ... ] )
    Returns: true if all dids were purchased, false otherwise.

=back

=cut

sub purchase_dids
{
    my $self        = shift;
    my $customer_id = shift;
    my $server_id   = shift;
    my $dids        = shift;

    my $number_of_dids_to_purchase = scalar @{$dids};
    my $result;

    $self->{'_pbxtra_dbh'}->transaction();

    my $dids_rs = $self->{'_pbxtra_dbh'}->table('ProviderDid')->search(
        {
            did         => { -in => $dids },
            customer_id => $customer_id,
            status      => 'reserved'
        }
    );
    $result = $dids_rs->update(
        {
            status    => 'purchased',
            server_id => $server_id,
        }
    );

    if ( !$result )
    {
        $self->{'_pbxtra_dbh'}->rollback();
        Fap->trace_error("Purchase of DIDs Failed");
        return 0;
    }

    my $number_of_dids_purchased = $self->{'_pbxtra_dbh'}->table('ProviderDid')->search(
        {
            did         => { -in => $dids },
            customer_id => $customer_id,
            status      => 'purchased',
            server_id   => $server_id,
        }
    )->count;

    if ( $number_of_dids_to_purchase != $number_of_dids_purchased )
    {
        $self->{'_pbxtra_dbh'}->rollback();
        Fap->trace_error("Failed to purchase all DIDs");
        return 0;
    }

    $self->{'_pbxtra_dbh'}->commit();

    return 1;
}

=head2 cancel_reservation

=over 4

Move dids that were 'reserved' back to 'available' status.

       Args: $customer_id, DIDs to cancel
    Returns: success or failure
    
    my $query = <<'END_SQL';
    UPDATE provider_dids
    SET status = 'available'
     WHERE provider = ?
       AND did = ?
       AND status = 'reserved'
       AND customer_id = ?  
END_SQL

=back

=cut

sub cancel_reservation
{
    my $self        = shift;
    my $customer_id = shift;
    my $dids        = shift;

    my $number_of_dids_to_cancel = scalar @{$dids};

    # Update the status of the dids to 'available'
    my $number_of_dids_cancelled = 0;

    $self->{'_pbxtra_dbh'}->transaction();

    foreach my $did ( @{$dids} )
    {
        my $provider_dids_rs = $self->{'_pbxtra_dbh'}->table('ProviderDid')->search(
            {
                did         => $did,
                provider    => $self->{'_provider'},
                customer_id => $customer_id,
                status      => 'reserved',
            }
        );
        my $result = $provider_dids_rs->update( { status => 'available', } );
        $number_of_dids_cancelled++ if $result;
    }

    if ( $number_of_dids_to_cancel != $number_of_dids_cancelled )
    {
        $self->{'_pbxtra_dbh'}->rollback();
        Fap->trace_error("Cancelling of DIDs Failed");
        return 0;
    }

    $self->{'_pbxtra_dbh'}->commit();

    return 1;
}

=head2 free_dids

=over 4

Move dids from a 'purchased' or 'reserved' state to an 'available' state.

       Args: ( $customer_id, $server_id, [ did1, did2, did3, ... ] )
    Returns: Success for Failure
     
    my $query = <<'END_SQL';
    UPDATE provider_dids
       SET status      = 'available',
        customer_id    = NULL,
        server_id      = NULL,
        expiration     = NULL
     WHERE provider    = ?
       AND did         = ?
       AND customer_id = ?
       AND server_id   = ?
       AND (
             status      = 'purchased'
             OR
             status      = 'reserved'
           )
END_SQL

=back

=cut

sub free_dids
{
    my $self      = shift;
    my $server_id = shift;
    my $dids      = shift;

    my $number_of_dids_to_free = scalar @{$dids};
    my $number_of_dids_freed   = 0;
    my $provider_dids_rs       = $self->{'_pbxtra_dbh'}->table('ProviderDid')->search(
        {
            provider  => $self->{'_provider'},
            server_id => $server_id,
            did       => { '-in' => $dids },
        }
    );

    $self->{'_pbxtra_dbh'}->transaction();

    $provider_dids_rs->update(
        {
            status      => 'available',
            customer_id => undef,
            server_id   => undef,
            expiration  => undef,
        }
    );

    $number_of_dids_freed = $self->{'_pbxtra_dbh'}->table('ProviderDid')->search(
        {
            provider    => $self->{'_provider'},
            status      => 'available',
            customer_id => undef,
            server_id   => undef,
            expiration  => undef,
            did         => { '-in' => $dids },
        }
    )->count;

    if ( $number_of_dids_to_free != $number_of_dids_freed )
    {
        $self->{'_pbxtra_dbh'}->rollback();
        Fap->trace_error("Failed to free DIDs");
        return 0;
    }

    $self->{'_pbxtra_dbh'}->commit();

    return 1;
}

=head2 insert_dids

=over 4

Insert of list of provider DIDs into our database.
Will handle prexisting rows by just 'finding' them.

       Args: ( $provider, [$did1, $did2, ... $didn] )
    Returns: true if all rows inserted

=back

=cut

sub insert_dids
{
    my $self = shift;
    my $dids = shift;

    my $number_of_dids_to_insert = scalar @{$dids};

    #    my @data = map { [ $_, $self->provider ] } @{$dids};
    #    unshift @data, [qw/ did provider /];

    $self->{'_pbxtra_dbh'}->transaction();

    #$self->schema->populate( 'ProviderDid', \@data );
    foreach my $did ( @{$dids} )
    {
        $self->{'_pbxtra_dbh'}->table('ProviderDid')->find_or_create(
            {
                provider => $self->{'_provider'},
                did      => $did,
            }
        );
    }
    my $rows_inserted = $self->{'_pbxtra_dbh'}->table('ProviderDid')->search(
        {
            provider => $self->{'_provider'},
            did      => { -in => $dids },
        }
    )->count;

    if ( $rows_inserted != $number_of_dids_to_insert )
    {
        $self->{'_pbxtra_dbh'}->rollback();
        Fap->trace_error("Failed to insert DIDs");
        return 0;
    }

    $self->{'_pbxtra_dbh'}->commit();

    return 1;
}

=head2 delete_dids

=over 4

Delete of list of provider DIDs from our database.

       Args: ( $provider, [$did1, $did2, ... $didn] )
    Returns: true if all rows deleted
    
=back

=cut

sub delete_dids
{
    my $self     = shift;
    my $provider = shift;
    my $dids     = shift;

    $self->{'_pbxtra_dbh'}->transaction();

    $self->{'_pbxtra_dbh'}->table('ProviderDid')->search(
        {
            provider => $provider,
            did      => { -in => $dids },
        }
    )->delete;

    my $rows_left = $self->{'_pbxtra_dbh'}->table('ProviderDid')->search(
        {
            provider => $provider,
            did      => { -in => $dids },
        }
    )->count;

    if ($rows_left)
    {
        $self->{'_pbxtra_dbh'}->rollback();
        Fap->trace_error("Failed to delete DIDs");
        return 0;
    }

    $self->{'_pbxtra_dbh'}->commit();

    return 1;
}

=head2 route_dids

=over 4

Insert did related info into the dbaliases table on a SIP Proxy server.

       Args: ( $sip_proxy, $server_id, [$did1, $did2, ... $did3] )
    Returns: 1 for Success or undef for failure

=back

=cut

sub route_dids
{
    my $self      = shift;
    my $sip_proxy = shift;
    my $server_id = shift;
    my $dids      = shift;

    my $number_of_dids_to_route = scalar @{$dids};
    my $domain                  = 's' . $server_id . 'x.pbxtra.fonality.com';
    my $schema                  = Fap::Model::Opensips->new( server => "opensips", switch => $sip_proxy );
    my $dids_routed             = 0;

    $schema->transaction();

    foreach my $did ( @{$dids} )
    {
        my $dbalias_row_object = $schema->table('Dbalias')->update_or_create(
            {
                alias_username => $did,
                username       => $server_id,
                domain         => $domain,
            },
            { key => 'alias_username_UNIQ', }
        );
        $dids_routed++ if $dbalias_row_object;
    }

    if ( $number_of_dids_to_route != $dids_routed )
    {
        $schema->rollback();
        Fap->trace_error("Failed to route DIDs");
        return undef;
    }

    $schema->commit();

    return 1;
}

=head2 unroute_dids

=over 4

    Delete did related info from the dbaliases table on a SIP Proxy server.
    
       Args: ( $sip_proxy, $server_id, [$did1, $did2, ... $did3] )
    Returns: 1 for Success or undef for failure

=back    

=cut

sub unroute_dids
{
    my $self      = shift;
    my $sip_proxy = shift;
    my $server_id = shift;
    my $dids      = shift;

    my $number_of_dids_to_unroute = scalar @{$dids};
    my $domain                    = 's' . $server_id . 'x.pbxtra.fonality.com';
    my $schema                    = Fap::Model::Opensips->new( server => "opensips", switch => $sip_proxy );
    my $dids_unrouted             = 0;

    $schema->transaction();

    my $dids_unrouted = $schema->table('Dbalias')->search(
        {
            alias_username => { 'in' => $dids },
            username       => $server_id,
            domain         => $domain,
        },
        { key => 'alias_username_UNIQ', }
    )->delete;

    if ( $number_of_dids_to_unroute != $dids_unrouted )
    {
        $schema->rollback();
        Fap->trace_error("Failed to unroute DIDs");
        return undef;
    }

    $schema->commit();

    return 1;
}

=head2 update_unbound_map

=over 4

Update the pbxtra.unbound_map table with did numbers.

       Args: ( $server_id, $host_id, [$did1, $did2, ... $did3] )
    Returns: 1 for Success or undef for failure

=back

=cut

sub update_unbound_map
{
    my $self      = shift;
    my $server_id = shift;
    my $host_id   = shift;
    my $dids      = shift;

    my $number_of_dids_to_map = scalar @{$dids};
    my $dids_mapped           = 0;

    $self->{'_pbxtra_dbh'}->transaction();

    foreach my $did ( @{$dids} )
    {
        my $rs = $self->{'_pbxtra_dbh'}->table('UnboundMap')->find_or_create(
            {
                unbound_virtual_number => $did,
                server_id              => $server_id,
                host                   => $host_id,
                phone_number           => $did
            }
        );
        $dids_mapped++ if $rs;
    }

    if ( $number_of_dids_to_map != $dids_mapped )
    {
        $self->{'_pbxtra_dbh'}->rollback();
        Fap->trace_error("Failed to route DIDs");
        return undef;
    }

    $self->{'_pbxtra_dbh'}->commit();

    return 1;
}

=head2 delete_unbound_map

=over 4

Delete the dids from pbxtra.unbound_map table.

       Args: ( $server_id, $host_id, [$did1, $did2, ... $did3] )
    Returns: 1 for Success or undef for failure

=back

=cut

sub delete_unbound_map
{
    my $self      = shift;
    my $server_id = shift;
    my $host_id   = shift;
    my $dids      = shift;

    my $number_of_dids_to_unmap = scalar @{$dids};
    my $dids_unmapped           = 0;

    $self->{'_pbxtra_dbh'}->transaction();

    my $dids_unmapped = $self->{'_pbxtra_dbh'}->table('UnboundMap')->search(
        {
            unbound_virtual_number => { 'in' => $dids },
            server_id              => $server_id,
            host                   => $host_id,
            phone_number           => { 'in' => $dids }
        }
    )->delete;

    if ( $number_of_dids_to_unmap != $dids_unmapped )
    {
        $self->{'_pbxtra_dbh'}->rollback();
        Fap->trace_error("Failed to unroute DIDs");
        return undef;
    }

    $self->{'_pbxtra_dbh'}->commit();

    return 1;
}

=head2 reduce_available_dids

=over 4

During provisioning we picks DIDs, but we don't mark them as reserved right away, because 
reservation is deferred until we have all the DIDs picked that we want to reserve.  
This is so we can run the reservation as a transacation where we get all or nothing.  
In order to support this we want to be able to reduce the list of available dids for a prefix
by the list we already chose (we'll call this list the @excludes).

       Args: (\@available_dids, \@dids_to_exclude)
    
    Returns: an ArrayRef of the dids in @available_dids that are not in @dids_to_exclude

=back

=cut

sub reduce_available_dids
{
    my $self            = shift;
    my $available_dids  = shift;
    my $dids_to_exclude = shift;

    my @available_dids_reduced;
    foreach my $did ( @{$available_dids} )
    {
        my $exclude_it = first { $did eq $_ } @{$dids_to_exclude};
        if ( !$exclude_it )
        {
            push @available_dids_reduced, $did;
        }

    }

    return \@available_dids_reduced;
}

=head2 get_dids_by_local_code

=over 4

The first two digits represent the area_code while the third and fourth digits
(often) represent the locality (city or cities).  The method returns a data structure
of available dids keyed by area and locality code.

       Arg: 
    Return: HashRef[HashRef[ArrayRef]]

=back    

=cut

sub get_dids_by_local_code
{
    my $self = shift;

    my $rs = $self->{'_pbxtra_dbh'}->table('ProviderDid')->search(
        {
            provider => $self->{'_provider'},
            status   => 'available'
        },
        {
            select => [ { substr => 'did,1,2' }, { substr => 'did,3,2' }, 'did' ],
            as     => [qw/area_code local_code did/]
        }
    );

    if ( !$rs )
    {
        Fap->trace_error("Query to e911_address failed");
        return undef;
    }

    my $dids_by_local_code;
    while ( my $row = $rs->next() )
    {
        push @{ $dids_by_local_code->{ $row->{'area_code'} }->{ $row->{'local_code'} } }, $row->{'did'};
    }

    return $dids_by_local_code;
}

=head2 _build_reservation_expiration

=over 4

Build the expiration datetime for the reservation
The default expiration datetime is 1 hour from now.

Arg: none
Return: datetime 

=back    

=cut

sub _build_reservation_expiration
{
    my $self = shift;

    my $hours = $self->expiry_hours;
    my $dt    = DateTime->now;
    $dt->add( hours => $hours );
    return $dt;
}

=head2 expiry_hours

=over 4

Sets/Gets the objects expiry hours

Arg: [numeric]
Return: numeric

=back    

=cut

sub expiry_hours
{
    my $self = shift;
    my $expiry = shift || undef;

    if ( defined($expiry) )
    {
        if ( $expiry =~ /^\d+$/ )
        {
            $self->{'_expiry_hours'} = $expiry;
        }
    }

    return $self->{'_expiry_hours'};
}

1;
