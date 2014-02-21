# Copyright 2012, Fonality Inc. ALL RIGHTS RESERVED

=head1 NAME

Fap::Provider;

=head1 SYNOPSIS

use Fap::Provider;

=head1 DESCRIPTION

API library functions to interact with VoIP providers such as Inphonex, Symbio and Fusion

=head1 FUNCTIONS

Each provider specific PM must implement the following functions:
- _init()
- get_password()
- get_voip_param()
- get_provider_customer_id()
- get_provider_pin()
- create_account()
- delete_account()
- purchase_dids()
- delete_dids()
- process_lnps()
- cancel_lnps()
- get_available_dids()
- get_emergency_addresses()
- set_emergency_addresses()

the details of each function will be described below

=cut

package Fap::Provider;

use strict;
use Fap;
use Fap::Model::Fcs;
use Fap::Server;
use Fap::PhoneNumbers;
use F::VOIP;
use F::DialPlan;

=pod
 
 List of available providers.
 This will be of the form:
   {
     '<provider_type>' =>
     {
           'module'  => <name of module in Fap/Provider/>
           'is_test' => 1 or 0 to specify if this is a test provider account
     }
   }

=cut
my $_providers = Fap->load_conf("provider");

=head2 new()

=over 4

This is the constructor which will require provider_type to be passed in order to
instantiate the right provider object

Args: %hash of the form:
       (
          'dbh'           => optional database handler.  If not specified, new dbh will be created
          'provider_type' => the provider type from list of avialable providers above (e.g. inphonex, symbio)
          'is_test'       => 1 to specify if this is a test provider account
       )
Returns: $provider_object of specific provider (e.g. Fap::Provider::Inphonex)
          or undef if there are any errors
Example: my $provider = Fap::Provider->new('server_id' => 20694, 'provider_type' => 'inphonex');

=back

=cut
sub new
{
    my ($class, %args) = @_;
    my $is_test = 0;
    
    # check whether to instantiate as test
    if(defined($args{'is_test'}))
    {
        $is_test = $args{'is_test'} ? 1 : 0;
    }

    # check provider_type
    my $provider_type;

    if(!defined($args{'provider_type'}))
    {
        Fap->trace_error("Missing provider_type");
        return undef;
    }

    # make sure provider_type is in the providers list
    $args{'provider_type'} = lc($args{'provider_type'});
    if($_providers->{'provider'}->{$args{'provider_type'}})
    {
        $provider_type = $_providers->{'provider'}->{$args{'provider_type'}};
    }
    else
    {
        Fap->trace_error("Unknown provider type: " . $args{'provider_type'});
        return undef;
    }

    # check fcs dbh
    my $fcs_dbh;
    if(!defined($args{'fcs_dbh'}))
    {
        $fcs_dbh = Fap::Model::Fcs->new();
    }
    elsif(defined($args{'fcs_dbh'}) && ref($args{'fcs_dbh'}) ne 'Fap::Model::Fcs')
    {
        Fap->trace_error("Invalid database handler");
        return undef;
    }
    else
    {
        $fcs_dbh = $args{'fcs_dbh'};
    }

    # check pbxtra dbh
    my $pbxtra_dbh;
    if(!defined($args{'pbxtra_dbh'}))
    {
        $pbxtra_dbh = Fap::Model::Fcs->new();
        $pbxtra_dbh->switch_db('pbxtra');
    }
    elsif(defined($args{'pbxtra_dbh'}) && ref($args{'pbxtra_dbh'}) ne 'Fap::Model::Fcs')
    {
        Fap->trace_error("Invalid database handler");
        return undef;
    }
    else
    {
        $pbxtra_dbh = $args{'pbxtra_dbh'};
    }


    # initialize the specific provider object
    my $self = {};
    my $provider_module = "Fap::Provider::" . $provider_type->{'module'};
    eval("use $provider_module");
    if($@)
    {
        Fap->trace_error("Cannot instantiate $provider_module");
        return undef;
    }
    bless($self, $provider_module);

    # inherit vars
    $self->{'_fcs_dbh'}    = $fcs_dbh;
    $self->{'_pbxtra_dbh'} = $pbxtra_dbh;
    $self->{'_is_test'}    = $is_test || $provider_type->{'is_test'};
    $self->{'_provider_type'}   = $args{'provider_type'};
    $self->{'_provider_module'} = $provider_type->{'module'};

    # fetch the provider's details
    my $rec = $self->{'_fcs_dbh'}->table('Provider')->find( { "name" => $self->{'_provider_module'} } );
    $self->{'_provider_info'} = ( $self->{'_fcs_dbh'}->strip($rec) );

    # call provider specific initialization
    $self->_init(%args);

    return $self;
}

=head2 create_account()

=over 4

This create the provider account which involves:
1. creating account in the provider side (if applicable)
2. create OpenSIPS account (this is implemented in the specific provider module if applicable)
3. update voip entry for the server to have this new account
4. update the server_provider db info

(1) and (2) will be handled in provider specific module

Args: $server_id
Returns: $voip_name if successful, undef otherwise
Example: my $ret = $provider->create_account(20694);

=back

=cut
sub create_account
{
    my ($self, $server_id) = @_;
    
    # check server id
    if(!$self->_check_sid($server_id)) 
    {
        Fap->trace_error("Unable to find the provider server_id: $@");
        return undef; 
    }

    # create the VoIP account 
    my $voip = F::VOIP->new($self->{'_pbxtra_dbh'}->dbh(), $server_id);
    my $voip_name = "FonalityVoIP-$server_id";
    my $ret = $voip->add_voip_account($voip_name, 'SIP', 'unbound');
    if(!$ret)
    {
        Fap->trace_error("Failed to add VOIP account: $@");
        return undef;
    }

    # get the necessary paramaters needed by the Provider
    my $data = $self->get_voip_param($server_id);
    if(!$data)
    {
        Fap->trace_error("Unable to retrieve the necessary Provider paramaters: $@");
        return undef;
    }
    
    foreach my $key (keys %$data)
    {
        if (ref($data->{$key}) eq 'ARRAY')
        {
            $voip->add($voip_name,$key, $_) for @{$data->{$key}};
        } 
        else
        {
            $voip->add($voip_name,$key, $data->{$key});
        }    
    }

    my $chk = $voip->commit();

    if(!$chk)
    {
        Fap->trace_error("Failed to commit changes to new VOIP account: $@");
        return undef;
    }

    # now update the the server table to have this provider
    $chk = $self->{'_fcs_dbh'}->table('Server')->search( {'server_id' => $server_id} )->update( {
        'provider_type' => $self->{'_provider_type'}
    } );

    if(!$chk)
    {
        Fap->trace_error("Failed to update server");
        return undef;
    }
    $self->{'_server_info'} = undef;

    $chk = $self->{'_fcs_dbh'}->table('ServerProvider')->find_or_create( {
        'server_id'            => $server_id,
        'provider_id'          => $self->get_provider_id(),
        'provider_customer_id' => $self->get_provider_customer_id(),
        'provider_username'    => $self->get_provider_username(),
        'provider_password'    => $self->get_password(),
        'provider_pin'         => $self->get_provider_pin()
    } );

    if(!$chk)
    {
        Fap->trace_error("Failed to update server_provider");
        return undef;
    }
    
    # reset the server_info obj
    $self->{'_server_info'} = Fap::Server->new('server_id' => $server_id);

    return $voip_name;
}

=head2 delete_account()

=over 4

delete the provider account from provider side and Fonality db.
Deletion of the provider account will be handled in provider specific module

Args: $server_id
Returns: 1 if successful, undef otherwise
Example: $provider->delete_account(20694);

=back

=cut
sub delete_account
{
    my ($self, $server_id) = @_;

    # check server id 
    if(!$self->_check_sid($server_id)) 
    {
        Fap->trace_error("Err: Unable to find the provider server_id: $@");
        return undef;
    }

    # remove the Voip account form server
    my $voip = F::VOIP->new($self->{'_pbxtra_dbh'}->dbh(), $server_id);
    my $voip_name = "FonalityVoIP-$server_id";
    my $chk = $voip->delete_voip_account($voip_name);
    if(!$chk)
    {
        Fap->trace_error("Failed to delete voip account $voip_name: $@");
        return undef;
    }

    $chk = $voip->commit();

    if(!$chk)
    {
        Fap->trace_error("Failed to commit deletion: $@");
        return undef;
    }

    # update database
    $chk = $self->{'_fcs_dbh'}->table('Server')->search( {'server_id' => $server_id} )->update( {'provider_type' => undef} );

    if(!$chk)
    {
        Fap->trace_error("Failed to remove provider_type from server table");
        return undef;
    }
    
    # clear the server_info obj
    $self->{'_server_info'} = undef;

    my $rs = $self->{'_fcs_dbh'}->table('ServerProvider')->search( {
        'server_id'   => $server_id,
        'provider_id' => $self->get_provider_id()
    } );

    if(!$rs)
    {
        Fap->trace_error("Failed to delete server_provider");
        return undef;
    }
    $rs->delete();

    return 1;
}

=head2 get_provider_id() 

=over 4

Get the Provider ID from db based on the provider_type

Args: none
Returns: $provider_id or undef if there are any errors
Example: my $pid = $provider->get_provider_id();
 
=back

=cut
sub get_provider_id
{
    my $self = shift;

    my $row = $self->{'_fcs_dbh'}->table('Provider')->find( {'name' => $self->{'_provider_module'}} );
    if(!$row)
    {
        Fap->trace_error("Cannot find provider id for " . $self->{'_provider_module'});
        return undef;
    }

    my $provider_id = $row->get_column('provider_id');

    return $provider_id;
}

=head2 purchase_dids()

=over 4

Purchase the given DIDs from specific provider and update Fonality db accordingly.
Actual DID purchasing will be done by provider specific modules.

Args: $server_id, $array_of_dids, $did_type
      $array_of_dids can be either full numbers or area codes
      $did_type: any of the types defined in Fap::Global::kDID_TYPE
 
Returns: $array_of_dids purchased or undef if there are any errors
Example: $dids = $provider->purchase_dids(20694, did_number, [215,215]);
         This will purchase 2 DIDs with area code 215 from provider

=back

=cut
sub purchase_dids
{
    my ($self, $server_id, $dids, $did_type) = @_;

    # check server id
    if(!$self->_check_sid($server_id)) { return undef; }

    # check dids
    if(!$self->_check_dids($dids)) { return undef; }
    
    # update the phone numbers table
    # start db transaction
    $self->{'_fcs_dbh'}->transaction();
    my $all_good = 1;
    
    foreach my $did (@{$dids})
    {
        my $rs = $self->{'_fcs_dbh'}->table('PhoneNumber')->find_or_new( {
                     'server_id' => $server_id,
                     'number'    => $did,
                     'type'      => 'voip',
                 } );
        if(!$rs)
        {
            Fap->trace_error("Failed to query phone numbers table");
            $all_good = 0;
            last;
        }

        # create entry if not found
        if(!$rs->in_storage())
        {
            my $chk = $rs->insert();
            if(!$chk)
            {
                Fap->trace_error("Failed to insert $did to phone numbers table");
                $all_good = 0;
                last;
            }
        }
    }

    if(!$all_good)
    {
        $self->{'_fcs_dbh'}->rollback();
        Fap->trace_error("Failed to update all DIDs");
        return undef;
    }
    $self->{'_fcs_dbh'}->commit();
    
    # add the number in incoming.conf
    my $rv = F::DialPlan::set_dp_incoming_number( $server_id );
    if(!defined($rv))
    {
        Fap->trace_error("Failed to update incoming.conf: $@");
        return undef;
    }
    
    return $dids;
}

=head2 delete_dids()

=over 4

Delete the given DIDs from specific provider and update Fonality db accordingly.
Actual DID canceling will be done by provider specific modules.

Args: $server_id, $array_of_dids
Returns: $array_of_dids cancelled or undef if there are any errors
Example: $dids = $provider->delete_dids(20694, [12158613321,12158613322]);

=back

=cut
sub delete_dids
{
    my ($self, $server_id, $dids) = @_;

    # check server id
    if(!$self->_check_sid($server_id)) { return undef; }

    # check dids
    if(!$self->_check_dids($dids)) { return undef; }

    # update the phone numbers table
    # start db transaction
    $self->{'_fcs_dbh'}->transaction();
    my $all_good = 1;
    foreach my $did (@{$dids})
    {
        my $chk = $self->{'_fcs_dbh'}->table('PhoneNumber')->find( {
                     'server_id' => $server_id,
                     'number'    => $did,
                     'type'      => 'voip',
                 } );
        if(!defined($chk))
        {
            Fap->trace_error("Failed to delete $did from phone numbers table");
            $all_good = 0;
            last;
        }
        $chk->delete;
    }

    if(!$all_good)
    {
        $self->{'_fcs_dbh'}->rollback();
        Fap->trace_error("Failed to delete all phone numbers");
        return undef;
    }
    $self->{'_fcs_dbh'}->commit();

    # update the number in incoming.conf
    my $rv = F::DialPlan::set_dp_incoming_number( $server_id );
    if(!defined($rv))
    {
        Fap->trace_error("Failed to update incoming.conf: $@");
        return undef;
    }
    
    return $dids;
}

=head2 process_lnps()

=over 4

Process the LNP in the provider side and update Fonality db.

Args: $server_id, $array_of_lnps
Returns: $array_of_lnps ported or undef if there are any errors
Example: $dids = $provider->process_lnps(20694, [13108614300,13108614301]);

=back

=cut
sub process_lnps 
{
    my ($self, $server_id, $dids) = @_;

    # main update to Fonality db is exactly the same as purchasing dids
    return $self->Provider::purchase_dids($server_id, $dids);
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

    # main update to Fonality db is exactly the same as delete_dids
    return $self->Provider::delete_dids($server_id, $dids);
}

=head2 _check_sid()

=over 4

Check the string input to see if they are valid Server ID.

Args: $server_id
Returns: $server_info if valid, undef otherwise
Example: my $serv_info = $provider->_check_sid($server_id);

=back

=cut
sub _check_sid
{
    my ($self, $server_id) = @_;

    if($server_id !~ /^\d+$/)
    {
        Fap->trace_error("Invalid Server ID: $server_id");
        return undef;
    }

    # check the cache to see if we already tried to get the $server info
    if($self->{'_server_info'} && $self->{'_server_info'}->{'server_id'} == $server_id)
    {
        return $self->{'_server_info'};
    }

    # check if the server exist in database
    my $server_info = Fap::Server->new('server_id' => $server_id);
    if(!$server_info->{'server_id'})
    {
        Fap->trace_error("Cannot find server info for $server_id");
        return undef;
    }
    $self->{'_server_info'} = $server_info;

    return $server_info;
}

=head2 _check_dids()

=over 4

Check the given array of dids to make sure they are full numbers

Args: $arrayref_of_dids
Returns: 1 if valid, undef otherwise
Example: my $chk = $provider->_check_dids(['13108614300','132']);

=back

=cut
sub _check_dids
{
    my ($self, $dids) = @_;

    if(ref($dids) ne 'ARRAY' || scalar(@{$dids}) == 0)
    {
        Fap->trace_error("Empty DIDs");
        return undef;
    }

    # all DIDs must be full numbers
    foreach my $did (@{$dids})
    {
        if(length($did) < 10)
        {
            Fap->trace_error("Found incomplete DID: $did");
            return undef;
        }
    }

    return 1;
}

=head2 get_available_dids()

=over 4

Get the available DIDs from provider given an array of regions/states and/or area_codes.
This must be implemented in the provider specific module.

Args: $arrayref_of_regions, [$arrayref_of_areacodes (optional)]
Returns: $arrayref_of_avialable_dids in the form of:
         [
           {
             'number' => '1302221',
             'region' => 'Delaware',
             'stock' => '100'
           },
           {
             'number' => '13159281',
             'region' => 'New York',
             'stock' => '25'
           },
           {
             'number' => '13108614300',
             'region' => 'California',
             'stock' => '1'
         ]
         or undef if there are any errors

Example: $dids = $provider->get_available_dids();

=back

=cut
sub get_available_dids
{
    my ($self, $regions, $area_codes) = @_;

    Fap->trace_error("get_available_dids not implemented for " . $self->{'_provider_module'});
    return undef;
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

    # check input
    if(!$self->_check_sid($server_id)) { return undef; }
    if(!$self->_check_dids($dids)) { return undef; }

    # check that all the dids belong to the server_id
    my @phonenumbers = Fap::PhoneNumbers::get_phone_numbers($self->{'_fcs_dbh'}, $server_id);
    foreach my $did (@{$dids})
    {
        if( !grep { $did eq $_->{'number'} } @phonenumbers )
        {
            Fap->trace_error("DID $did does not belong to $server_id");
            return undef;
        }
    }

    # get the addresses from db
    my $rs = $self->{'_fcs_dbh'}->table('PbxtraE911Address')->search( {did => { -in => $dids }} );
    my $addresses = {};
    if(!$rs)
    {
        Fap->trace_error("Query to e911_address failed");
        return undef;
    }
    while(my $row = $rs->next())
    {
        if(my %data = $row->get_columns())
        {
            $addresses->{ $data{'did'} } = \%data;
        }
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

    # check input
    if(!$self->_check_sid($server_id)) { return undef; }

    # check that all the dids belong to the server_id
    my @phonenumbers = Fap::PhoneNumbers::get_phone_numbers($self->{'_fcs_dbh'}, $server_id);
    foreach my $add (@{$info})
    {
        if( !grep { $add->{'did'} eq $_->{'number'} } @phonenumbers )
        {
            Fap->trace_error("DID " . $add->{'did'} . " does not belong to $server_id");
            return undef;
        }
    }

    # TODO
    # set the addresses to db
    # start the db transaction
    $self->{'_fcs_dbh'}->transaction();

    my $all_good = 1;
    foreach my $did (@{$info})
    {
        my $rs = $self->{'_fcs_dbh'}->table('PbxtraE911Address')->find_or_new( {did => $did->{'did'} } );

    }

    if(!$all_good)
    {
        $self->{'_fcs_dbh'}->rollback();
        Fap->trace_error("Cannot update all emergency addresses");
        return undef;
    }

    $self->{'_fcs_dbh'}->commit();
    return 1;
}


=head2 set_password()

=over 4

Set the generated password in this object to be accessed later

Args: $pass
Returns: none
Example: $provider->set_password('asdfasdf');

=back

=cut
sub set_password
{
    my ($self, $pass) = @_;

    $self->{'_password'} = $pass;
}

=head2 get_password()

=over 4

Get the provider password set

Args: none
Returns: $pass
Example: my $pass = $provider->get_password();

=back

=cut
sub get_password
{
    my $self = shift;

    return $self->{'_password'};
}


=head2 set_provider_customer_id()

=over 4

Set the provider customer id in this object to be accessed later

Args: $id
Returns: none
Example: $provider->set_provider_customer_id(1);

=back

=cut
sub set_provider_customer_id 
{
    my ($self, $id) = @_;
    
    $self->{'_provider_customer_id'} = $id;
}


=head2 get_provider_customer_id()

=over 4

Get the provider customer id

Args: none
Returns: $id
Example: my $id = $provider->get_provider_customer_id();

=back

=cut
sub get_provider_customer_id 
{
    my $self = shift;
    
    return $self->{'_provider_customer_id'} || undef;
}


=head2 set_provider_username()

=over 4

Set the provider username in this object to be accessed later

Args: $username
Returns: none
Example: $provider->set_provider_username('asdfasdf');

=back

=cut
sub set_provider_username 
{
    my ($self, $user) = @_;
    
    $self->{'_provider_username'} = $user;
}


=head2 get_provider_username()

=over 4

Get the provider username

Args: none
Returns: $username
Example: my $pass = $provider->get_provider_username();

=back

=cut
sub get_provider_username 
{
    my $self = shift;
    
    return $self->{'_provider_username'};
}

=head2 set_provider_pin()

=over 4

Set the generated pin in this object to be accessed later

Args: $pin
Returns: none
Example: $provider->set_provider_pin('asdfasdf');

=back

=cut
sub set_provider_pin 
{
    my ($self, $pin) = @_;
    
    $self->{'_provider_pin'} = $pin;
}


=head2 get_provider_pin()

=over 4

Get the provider pin

Args: none
Returns: $pin
Example: my $pass = $provider->get_provider_pin();

=back

=cut
sub get_provider_pin 
{
    my $self = shift;
    
    return $self->{'_provider_pin'} || undef;
}

=head2 lnp_isportable()

=over 4

Tells if a number is portable or not.

Arguments: LNP (numeric string)
Returns: 1 successful purchased or undef if there are any errors
Example: my $pass = $provider->lnp_isportable('0242317574');

=back

=cut

sub lnp_isportable {
    my ( $self, $lnp ) = @_;
    
    if(!$self->SUPER::_check_dids( [$lnp] )) 
    {
        Fap->trace_error("Not portable due this reason: $@");
        return undef; 
    }

    return 1;
}

1;
