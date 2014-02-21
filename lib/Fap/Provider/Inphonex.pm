# Copyright 2012, Fonality Inc. ALL RIGHTS RESERVED
package Fap::Provider::Inphonex;

use strict;
use Fap;
use Fap::Provider;
use Fap::Model::Fcs;
use Fap::Server;
use Fap::Customer;
use Fap::Bundle;
use Fap::Util;
use F::VOIP;
use F::Inphonex;
use F::Inphonex::Utils;
use Data::Dumper;

use base "Fap::Provider";

=head2 _init()

=over 4

Initialize the Inphonex provider object

Args: %args
Returns: none 

=back

=cut

sub _init {
    my ( $self, %args ) = @_;

    # load the config
    $self->{'_config'} = Fap->load_conf("provider/inphonex");
}

=head2 create_account()

=over 4

Create Inphonex account

Args: $server_id
Returns: $voip_name if successful, undef otherwise
Example: my $ret = $provider->create_account(20694);

=back

=cut

sub create_account {
    my ( $self, $server_id ) = @_;

    if( !$self->_check_inphonex_obj( $server_id ) ) {
        Fap->trace_error( "ERR: Could not get inphonex object. $@" );
        return undef;
    }

    # generate the password
    my $pass = Fap::Util::return_random_string( 17 );
    $self->set_password( $pass );
    $self->set_provider_pin;

    # create a new shopping cart and buy a new plan
    return undef if !$self->_initialize_transaction;
    $self->_set_virtual_number( $self->_get_new_virtual_number );
    $self->_order_callplan;
    return undef if !$self->_finalize_transaction( $self->_get_virtual_number );

    # fetch the inphonex_id using the new vitual number
    return undef if !$self->_get_provider_customer_id_via_virtual_number( $self->_get_virtual_number );

    # accept the customer E911 terms
    $self->{'_inphonex_obj'}->e911_accept( $self->get_provider_customer_id );

    # add credits for this virtual number
    my $output = '';
    open(TOOUTPUT, '>', \$output);
    select TOOUTPUT;
    eval {
        F::Inphonex::Utils::add_credit(
            $self->{'_inphonex_obj'}, $self->get_provider_customer_id,
            $self->get_password, $self->_get_virtual_number
        );
    };
    select STDOUT;
    if($@) {
        Fap->trace_error("ERR: Unable to load credits to virtual number.");
        close(TOOUTPUT);
        return undef;
    }

    # enable ani_passthrough for this virtual number
    $self->{'_inphonex_obj'}->ani_passthrough_enable_vn( $self->_get_virtual_number );

    # disable white pages and inphonex-side voice mail for this virtual_number
    $self->{'_inphonex_obj'}->virtual_number_update(
        'virtual_number'   => $self->_get_virtual_number,
        'inphonex_id'      => $self->get_provider_customer_id,
        'enable_voicemail' => 'false',
        'white_pages'      => 'false',
        'pin'              => $self->get_provider_pin,
    );

    # get the mother server_id to put into unbound_mapping
    # In the case of new PBXtra Connect there won't be one!
    my $mother = undef;
    if( $self->{'_server_info'}->{'details'}->{'deployment'}->{'is_hosted'} ) {
        $mother = $self->{'_server_info'}->{'details'}->{'mosted'};
    }

    # update the mapping with the first entry, which is the default
    select TOOUTPUT;
    F::Inphonex::Utils::update_mapping(
        $self->{'_pbxtra_dbh'}->dbh(),
        {
            'unbound_virtual_number' => $self->_get_virtual_number
              . $self->get_provider_pin,
            'is_default' => 1,
            'server_id'  => $server_id,
            'host'       => $mother,
        }
    );
    select STDOUT;
    close(TOOUTPUT);

    # insert the inphonex stuffs into the server table so we can look it up later
    $self->{'_fcs_dbh'}->table('Server')
        ->search( { server_id => $self->{'_server_info'}->{'server_id'} } )
        ->update(
        {
            'virtual_number' => $self->_get_virtual_number,
            'inphonex_pin'   => $self->get_provider_pin
        }
    );

    # call parent create_account()
    return $self->SUPER::create_account($server_id);
}

=head2 delete_account()

=over 4

Delete Inphonex account for this server

Args: $server_id
Returns: 1 if successful, undef otherwise
Example: $provider->delete_account(20694);

=back

=cut

sub delete_account {
    my ( $self, $server_id ) = @_;

    # check input
    if ( !$self->_check_inphonex_obj($server_id) ) {
        Fap->trace_error("ERR: Could not get inphonex object. $@");
        return undef;
    }

    my $rv = $self->{'_inphonex_obj'}->delete_customer(
        $self->get_provider_customer_id,
        $self->{'_inphonex_obj'}->get_date_to_run(),
        'Account no longer need'
    );

    unless ($rv) {
        Fap->trace_error("ERR: Unable to delete account. $@");
        return undef;
    }

    # clean up the inphonex stuffs
    my $chk = $self->{'_fcs_dbh'}->table('UnboundMap')->search( { 'server_id' => $server_id } );

    if ( !$chk ) {
        Fap->trace_error("Failed to remove entry from unbound_map table");
        return undef;
    }
    $chk->delete;

    $chk = $self->{'_fcs_dbh'}->table('Server')
        ->search( { 'server_id' => $server_id } )->update(
            {
                'virtual_number' => undef,
                'inphonex_pin'   => undef
            }
        );

    if ( !$chk ) {
        Fap->trace_error("Failed to remove provider_type from server table");
        return undef;
    }

    # call parent delete_account()
    return $self->SUPER::delete_account($server_id);
}

=head2 _check_inphonex_obj()

=over 4

Check if we already hava an inphonex object cached in the call variables. If not, create one.

Args: $server_id
Returns: inphonex object if successful, undef otherwise
Example: $self->_check_inphonex_obj(20694);

=back

=cut

sub _check_inphonex_obj {
    my ( $self, $server_id ) = @_;

    return 1
      if defined $self->{'_inphonex_obj'}
          && $self->{'_inphonex_obj'}->{'StateId'};

    return undef if ( !$self->_check_sid($server_id) );
    
    if(defined($self->{'_server_info'}->{'details'}->{'server_provider'})) {
        $self->set_provider_customer_id($self->{'_server_info'}->{'details'}->{'server_provider'}->{'provider_username'}),
        $self->set_password($self->{'_server_info'}->{'details'}->{'server_provider'}->{'provider_password'}),
        $self->set_provider_pin($self->{'_server_info'}->{'details'}->{'server_provider'}->{'provider_pin'})
    }

    # fetch the customer's details
    my $cust =
      Fap::Customer->new( 'customer_id' =>
          $self->{'_server_info'}->{'details'}->{'customer_id'} );

    $self->{'_customer_info'} = $cust->{'details'};

    my $inphonex_account = $cust->{'details'}->{'inphonex_reseller_id'};

    $inphonex_account ||=
      F::Inphonex::INPHONEX_ACCOUNTS()->{'DEFAULT'}->{'USERNAME'};

    $self->{'_inphonex_acct'} =
      $self->{'_is_test'}
      ? F::Inphonex::INPHONEX_ACCOUNTS()->{'TEST'}->{'USERNAME'}
      : $inphonex_account;

    $self->{'_inphonex_obj'} = F::Inphonex->new(
        'dbh'       => $self->{'_pbxtra_dbh'}->dbh(),
        'test_mode' => 'false',
        'account'   => $self->{'_inphonex_acct'},
    );

    $self->{'_inphonex_obj'}->{'StateId'} ? 1 : undef;
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

sub get_voip_param {
    my ( $self, $server_id ) = @_;

    # check input
    if ( !$self->_check_sid($server_id) ) { return undef; }

    my $params = $self->{'_config'}->{'sip'}->{'conf'};
    if ( $self->{'_server_info'}->{'details'}->{'deployment'}->{'is_hosted'} ) {
        %{$params} =
          ( %{$params}, %{ $self->{'_config'}->{'sip'}->{'hosted'} } );
    }
    else {
        %{$params} =
          ( %{$params}, %{ $self->{'_config'}->{'sip'}->{'premise'} } );
    }

    $params->{'secret'}   = $self->get_password();
    $params->{'username'} = $self->_get_virtual_number();

    return $params;
}

=head2 set_provider_customer_id()

=over 4

Set the provider customer id in this object to be accessed later

Args: $id
Returns: none
Example: $provider->set_provider_customer_id(1);

=back

=cut

sub set_provider_customer_id {
    my ( $self, $id ) = @_;

    $self->SUPER::set_provider_customer_id($id);
    $self->SUPER::set_provider_username($id);
}

=head2 _set_virtual_number()

=over 4

Set the vitual number in this object to be accessed later

Args: $virtual_number
Returns: none
Example: $provider->_set_virtual_number('asdfasdf');

=back

=cut

sub _set_virtual_number {
    my $self = shift;
    my $vn   = shift;

    $self->{'_virtual_number'} = $vn;
}

=head2 _get_virtual_number()

=over 4

Get the virtual number

Args: none
Returns: $virtual_number
Example: my $virt_num = $provider->_get_virtual_number();

=back

=cut

sub _get_virtual_number {
    my $self = shift;

    return $self->{'_virtual_number'};
}

=head2 set_provider_pin()

=over 4

Set the generated pin in this object to be accessed later

Args: $pin
Returns: none
Example: $provider->set_provider_pin('asdfasdf');

=back

=cut

sub set_provider_pin {
    my ( $self, $pin ) = @_;

    if ( $pin && length($pin) == F::Inphonex::kINPHONEX_PIN_LENGTH() ) {
        $self->SUPER::set_provider_pin($pin);
    }
    else {
        $self->SUPER::set_provider_pin(
            Fap::Util::return_random_number(
                F::Inphonex::kINPHONEX_PIN_LENGTH()
            )
        );
    }
}

=head2 _initialize_transaction

=over 4

Initializes a buying process.  This resets a new shopping basket
Returns: 1 or undef

=back

=cut

sub _initialize_transaction {

    #Create a single cart to capture all orders
    my $self     = shift;
    my $inphonex = $self->{'_inphonex_obj'};
    $inphonex->shopping_reset();
    my $cart = $inphonex->shopping_cart_create();

    # error checking
    unless ($cart) {
        my $fault = $inphonex->extract_faultstring();
        $inphonex->audit(
            what   => "creating customer account [[$fault]]",
            whom   => $self->{'_server_info'}->{'details'}->{'server_id'},
            status => 'Failure (creating cart)',
        );
        Fap->trace_error("ERR: Could not create shopping cart: $fault");
        return undef;
    }
    return 1;
}

=head2 finalize_transaction

=over 4

sets the virtual number that will do the purchase and submit to Inphonex

Returns: hash of checkout detail or undef

=back

=cut

sub _finalize_transaction {
    my $self           = shift;
    my $virtual_number = shift;
    my $inphonex       = $self->{'_inphonex_obj'};
    
    $self->_account_set_info($virtual_number);
    my $valid_checkout = $inphonex->shopping_checkout_validate();
    unless ($valid_checkout) {
        my $fault = $inphonex->extract_faultstring();
        Fap->trace_error("ERR: Checkout for DID did not validated - $fault\n");
        return undef;
    }
    my $checkout = $inphonex->shopping_checkout();
    unless ($checkout) {
        my $fault = $inphonex->extract_faultstring();
        Fap->trace_error("ERR: Checkout for DID did not successful - $fault\n");
        return undef;
    }
    return $checkout;
}

=head2 _get_available_virtual_number

=over 4

Return an unmapped virtual number - either main virtual number or purchase a new one from inphonex

Returns: virtual number

=back

=cut

sub _get_available_virtual_number {
    my $self      = shift;
    my $server_id = shift;
    my $main_virtual_number_flag = shift;
    my $virtual_number;

    if ( !$self->_check_inphonex_obj($server_id) ) {
        Fap->trace_error("ERR: Could not get inphonex details");
        return undef;
    }
    #Get a virtual number (either purchase new or reuse main vn)
    if ( $self->{_server_info}->{details}->{deployment}->{is_hosted} ) {
        if ( $self->_is_main_virtual_number_used() || $main_virtual_number_flag) {
            #We need to purchase vn
            $virtual_number = $self->_order_virtual_number();
        }
        else {

            #Use main virtual number
            $virtual_number =
              $self->{_server_info}->{details}->{virtual_number};
        }
    }
    else {

        #Return the main virtual number
        $virtual_number = $self->{_server_info}->{details}->{virtual_number};
    }
    return $virtual_number;
}

=head2 _get_new_virtual_number

=over 4

Gets an available virtual number from inphonex

Returns: available virtual number from Inphonex

=back

=cut

sub _get_new_virtual_number {
    my $self = shift;

    # Use an Inphonex suggested virtual number
    my $virtual_numbers =
      $self->{'_inphonex_obj'}->virtual_number_suggestions();
    for my $virtual_number ( @{$virtual_numbers} ) {

        # make sure the virtual number is actually available
        my $is_avail =
          $self->{'_inphonex_obj'}
          ->virtual_number_available( $virtual_number->{'virtual_number'} );
        if ($is_avail) {
            return $virtual_number->{virtual_number};
        }
    }
}

=head2 _is_main_virtual_number_used

=over 4

Determines if main virtual number is already mapped to a DID

Returns: available virtual number from Inphonex

=back

=cut

sub _is_main_virtual_number_used {
    my $self = shift;
    my $rs   = $self->{_fcs_dbh}->table('UnboundMap')->search(
        { -and => [ phone_number => { '!=', undef }, 'length(phone_number)' => {'>', 0} ],                   
            unbound_virtual_number =>
              { 'like', $self->{'_server_info'}->{'details'}->{'virtual_number'} . '%' },
            server_id => $self->{'_server_info'}->{'details'}->{'server_id'}
        }
    );
    if ( $rs->next() ) {
        return 1;
    }
    else {
        return 0;
    }
}

sub update_order_bundle_details {
    my $self            = shift;
    my $order_bundle_id = shift;
    my $new_did         = shift;
    my $error_hash      = shift;
    my $complete_flag   = 1;

    #Get all bundle_details with did_number <=4
    my $rs = $self->{'_fcs_dbh'}->table('OrderBundleDetail')->search(
        {
            "order_bundle_id" => $order_bundle_id,
            "is_lnp"          => 0
        }
    );
    while ( my $order_bundle_detail = $rs->next ) {

 #Skip order_bundle_detail processing if 1)its already done or 2)it has an error
        my $order_bundle_detail_id =
          $order_bundle_detail->order_bundle_detail_id;
        my $did_number = $order_bundle_detail->did_number;
        if ( length($did_number) > 0
            || $error_hash->{$order_bundle_detail_id} == 1 )
        {
            next;
        }
        my $update_flag = 0;
        foreach my $key ( keys %{$new_did} ) {
            my $search_pattern = "^(1)?$did_number\\d\+\$";
            if ( $key =~ m/$search_pattern/ ) {

                #Update order_bundle_details
                $order_bundle_detail->update( { did_number => $key } );
                $update_flag = 1;
                delete( $new_did->{$key} );
                last;
            }
        }
        if ( !$update_flag ) {
            $complete_flag = 0;
        }
    }
    return $complete_flag;
}

sub _order_callplan {
    my $self     = shift;
    my $inphonex = $self->{'_inphonex_obj'};

    # Store this because we'll need it later to determine plan
    my $inphonex_account = $self->{_inphonex_acct};
    $inphonex_account ||=
      F::Inphonex::INPHONEX_ACCOUNTS()->{'DEFAULT'}->{'USERNAME'};

    my $plan = 'UNLIMITED_PLAN';
    my $fonality_plan =
      F::Inphonex::INPHONEX_ACCOUNTS()->{$inphonex_account}->{$plan};

    $inphonex->shopping_cart_add(
        'item_id'         => 159,
        'item_quantity'   => 1,
        'attribute_name'  => 'ccp',
        'attribute_value' => $fonality_plan
    );
}

sub _order_did {
    my ( $self, $server_id, $virtual_number, $did_type, $did_number ) = @_;
    my $inphonex  = $self->{'_inphonex_obj'};
    my $did_result;

    if ( !$self->_check_inphonex_obj($server_id) ) {
        Fap->trace_error("ERR: Could not get inphonex object");
        return undef;
    }

    #Get the inphonex id that maps to your bundle_id
    my $inphonex_item_id = $self->{'_config'}->{'did_type'}->{$did_type};    

    #We had to be item specific since the parameter reqt is different
    $self->_initialize_transaction();

    #For Toll-Free
    if ( $did_type eq 'did_tollfree' ) {
        my $output = '';
        open(TOOUTPUT, '>', \$output);
        select TOOUTPUT;
        my @npa = F::Inphonex::Utils::get_numbers_for_toll_free_npa();
        select STDOUT;
        close(TOOUTPUT);
        foreach my $candidate (@npa) {
            $did_result = $inphonex->shopping_cart_add(
                'item_id'         => $inphonex_item_id,
                'item_quantity'   => 1,
                'attribute_name'  => 'did_prefix',
                'attribute_value' => "1$candidate",
            );
            if ($did_result) {
                last;
            }
        }
        if ( !$did_result ) {
            Fap::trace_error("ERR: Unable to purchase Toll-Free DID");
            return undef;
        }
    }

    #For Regular/ International DID (item id 121)
    elsif ( $did_type eq 'did_international' || $did_type eq 'did_number' ) {
        my $did = format_did($did_number);
        $did_result = $inphonex->shopping_cart_add(
            'item_id'         => $inphonex_item_id,
            'item_quantity'   => 1,
            'attribute_name'  => 'did_prefix',
            'attribute_value' => $did
        );
        if ( !$did_result ) {
            Fap::trace_error(
                "ERR: Unable to purchase Regular/ International DID");
            return undef;
        }
    }

    else {
        Fap::trace_error("ERR: Invalid DID item number ");
        return undef;
    }
    $did_result = $self->_finalize_transaction($virtual_number);
    if ( !$did_result ) {
        Fap::trace_error("ERR: Failed to checkout DID purchase");
        return undef;

    }
    else {
        return $did_result;
    }
}

sub _order_lnp {
    my $self           = shift;
    my $virtual_number = shift;
    my $item_id        = shift;
    my $did_number     = shift;
    my $inphonex       = $self->{'_inphonex_obj'};

    $self->_initialize_transaction();
    $inphonex->shopping_cart_add(
        'item_id'         => $item_id,
        'item_quantity'   => 1,
        'attribute_name'  => 'lnp_number',
        'attribute_value' => $did_number
    );
   # my $result = $self->_finalize_transaction($virtual_number);
    #return $result;
}

sub _is_virtual_number_available {
    my $self           = shift;
    my $virtual_number = shift() . '%';
    my $vn =
      $self->{'_fcs_dbh'}->table('UnboundMap')
      ->search( { unbound_virtual_number => { -like => $virtual_number }, 
                  -and => [
                             phone_number => { '!=', undef },
                             'length(phone_number)' => {'>', 0}
                          ]
                } )
      ->single();
    if ($vn) {
        return 0;
    }
    else {
        return 1;
    }
}

=head2 _order_virtual_number

=over 4

Does the ff. related to Inphonex VN
1. Gets an available virtual number
2. purchases virtual number slot
3. Associate virtual number

Returns: f

=back

=cut

sub _order_virtual_number {
    my $self      = shift;
    my $server_id = shift;

    if ( !$self->_check_inphonex_obj($server_id) ) {
        Fap->trace_error("ERR: Could not get inphonex object");
        return undef;
    }
    my $inphonex = $self->{'_inphonex_obj'};
    my $virtual_number;

    #We need to purchase vn
    $virtual_number = $self->_get_new_virtual_number();
    $self->_initialize_transaction();
    $inphonex->shopping_cart_add(
        'item_id'         => 42,
        'item_quantity'   => 1,
        'attribute_name'  => '',
        'attribute_value' => '',
    );
    my $result =
      $self->_finalize_transaction(
        $self->{_server_info}->{details}->{virtual_number} );
    if ( !$inphonex->extract_faultstring() ) {
        my $retval = $self->_add_virtual_number(
            'first_name'   => $self->{'_config'}->{'address'}->{first_name},
            'last_name'    => $self->{_server_info}->{details}->{server_id},
            'address1'     => $self->{'_config'}->{'address'}->{'address1'},
            'address2'     => $self->{'_config'}->{'address'}->{address2},
            'zip'          => $self->{'_config'}->{'address'}->{zip},
            'city'         => $self->{'_config'}->{'address'}->{city},
            'state'        => $self->{'_config'}->{'address'}->{state},
            'country'      => $self->{'_config'}->{'address'}->{country},
            'country_code' => 'US',
            'password' => $self->{_server_info}->{details}->{server_provider}
              ->{provider_password},
            'virtual_number' => $virtual_number,
            'email'          => $self->{'_config'}->{'address'}->{email},
            'phone_number'   => $self->{'_config'}->{'address'}->{phone_number},
            'company'        => 'Fonality Unbound',
            'customer_id' => $self->{_server_info}->{details}->{server_provider}
              ->{provider_username},
            'pin' => $self->{_server_info}->{details}->{server_provider}
              ->{provider_pin},
        );
        sleep(5)
          until $self->{'_inphonex_obj'}
              ->virtual_number_getinfo($virtual_number);
        $self->_initialize_transaction();
        $self->_order_callplan();
        $result = $self->_finalize_transaction($virtual_number);
        if ( !$result ) {
            Fap->trace_error(
"ERR: Unable to purchase callplan for virtual number $virtual_number"
            );
            return undef;
        }
    }
    else {
        return undef;
    }
    return $virtual_number;
}

=head2 _add_virtual_number

=over 4

Modified version of F::Inphonex::Utils::add_virtual_number which also sets value of ani passthrough

Returns: boolean

=back

=cut

sub _add_virtual_number {
    my ( $self, %p ) = @_;
    my $inphonex = $self->{'_inphonex_obj'};

    my $result = $inphonex->service('virtual_number')->call(
        'Insert' => F::SOAP::Data->value(
            F::SOAP::Data->name( 'StateId' => $$inphonex{StateId} ),
            F::SOAP::Data->name(
                'VirtualNumber' => \F::SOAP::Data->value(
                    F::SOAP::Data->name(
                        'virtual_number' => $p{virtual_number}
                    ),
                    F::SOAP::Data->name( 'customer_id' => $p{customer_id} ),
                    F::SOAP::Data->name(
                        'user' => \F::SOAP::Data->value(
                            F::SOAP::Data->name(
                                'name' => \F::SOAP::Data->value(
                                    F::SOAP::Data->name(
                                        'first_name' => $p{first_name}
                                    ),
                                    F::SOAP::Data->name(
                                        'last_name' => $p{last_name}
                                    )
                                )
                            ),
                            F::SOAP::Data->name( 'email_address' => $p{email} ),
                            F::SOAP::Data->name( 'phone' => $p{phone_number} ),
                            F::SOAP::Data->name( 'company' => $p{company} ),
                        )
                    ),
                    F::SOAP::Data->name(
                        'address' => \F::SOAP::Data->value(
                            F::SOAP::Data->name( 'address1' => $p{address1} ),
                            F::SOAP::Data->name( 'address2' => $p{address2} ),
                            F::SOAP::Data->name( 'postal_code' => $p{zip} ),
                            F::SOAP::Data->name( 'city'        => $p{city} ),
                            F::SOAP::Data->name( 'state'       => $p{state} ),
                            F::SOAP::Data->name(
                                'country' => \F::SOAP::Data->value(
                                    F::SOAP::Data->name(
                                        'country_name' => $p{country}
                                    ),
                                    F::SOAP::Data->name(
                                        'country_code' => $p{country_code}
                                    ),
                                )
                            ),
                        )
                    ),
                    F::SOAP::Data->name(
                        'preferences' => \F::SOAP::Data->value(
                            F::SOAP::Data->name(
                                'sip_password' => $p{password}
                            ),
                            F::SOAP::Data->name( 'credit'      => '-1' ),
                            F::SOAP::Data->name( 'language'    => 'en-UK' ),
                            F::SOAP::Data->name( 'timezone_id' => '331' ),
                            F::SOAP::Data->name(
                                'voicemail_password' => '1111'
                            ),
                            F::SOAP::Data->name(
                                'call_restrictions' => \F::SOAP::Data->value(
                                    F::SOAP::Data->name( 'plan_code' => 'I' )
                                )
                            ),
                            F::SOAP::Data->name( 'pin' => $p{pin} ),
                            F::SOAP::Data->name(
                                'enable_voicemail' => 'false'
                            ),
                            F::SOAP::Data->name( 'white_pages' => 'false' ),
                            F::SOAP::Data->name(
                                'enable_ani_passthrough' => 'true'
                            ),

                        )
                    )
                )
            )
        )
    );
    return $result->result() =~ /true|1/ ? 1 : 0;
}

sub _account_set_info {
    my $self     = shift;
    my $vn       = shift;
    my $inphonex = $self->{_inphonex_obj};

    my $data = {
        'password'    => $self->get_password,
        'first_name'  => $self->{'_config'}->{'address'}->{'first_name'}
          . ( lc( $self->{'mode'} ) eq 'test' ? 'Test' : '' ),
        'last_name'      => $self->{'_server_info'}->{'server_id'},
        'address1'       => $self->{'_config'}->{'address'}->{'address1'},
        'address2'       => $self->{'_config'}->{'address'}->{'address2'},
        'zip'            => $self->{'_config'}->{'address'}->{'zip'},
        'city'           => $self->{'_config'}->{'address'}->{'city'},
        'state'          => $self->{'_config'}->{'address'}->{'state'},
        'country'        => $self->{'_config'}->{'address'}->{'country'},
        'country_code'   => 'US',
        'virtual_number' => $vn,
        'email'          => $self->{'_config'}->{'address'}->{'email'},
        'phone_number'   => $self->{'_config'}->{'address'}->{'phone_number'},
        'company'        => $self->{'_config'}->{'address'}->{'company'},
    };
    $data->{'customer_id'} = $self->get_provider_customer_id if defined( $self->{'_server_info'}->{'details'}->{'server_provider'} );
    
    # AccountSetInfo() to create a new inphonex customer with this customer
    my $account_set = $inphonex->account_set_info( %$data );

    # error checking
    unless ($account_set) {
        my $fault = $inphonex->extract_faultstring();
        $inphonex->audit(
            what   => "setting account info [[$fault]]",
            whom   => $self->{'_server_info'}->{'server_id'},
            status => 'Failure (setting account info)',
        );
        Fap->trace_error("ERR: Could not set account info: $fault");
        return undef;
    }
}

=head2 lnp_isportable()

=over 4

    Tells if a number is portable or not.

    Arguments: LNP (string)
    Returns: 1 successful purchased or undef if there are any errors
    
=back
    
=cut

sub lnp_isportable {
    my ( $self, $lnp ) = @_;
    
    if(!$self->SUPER::lnp_isportable($lnp)) { return undef; }
    
    my $inphonex = $self->{'_inphonex_obj'};

    my $result =
      $self->{'_inphonex_obj'}->service('lnp')
      ->IsPortable( $$inphonex{StateId}, $lnp );

    if ( $result eq 'true' ) {
        return 1;
    }

    return undef;
}

=head2 update_did_map

=over 4

    Goes through Inphonex records and updates fonality database

    Arguments: server_id (string)
    Returns: Boolean

=cut

sub _update_did_map {
    my $self        = shift;
    my $server_id       = shift;
    my $quantity = shift;
    if ( !$self->_check_inphonex_obj($server_id) ) {
        Fap->trace_error("ERR: Could not get inphonex object");
        return undef;
    }
    my $inphonex    = $self->{'_inphonex_obj'};
    my $is_complete = 0;
    my $new_quantity = 0;
    my $num_tries = 0;
    my $max_tries = 100;
    my $new_did = {};
    my $result;    
    #construct the unbound_virt_number using main vn
    my $main_unbound_vn = $self->{'_server_info'}->{'details'}->{'virtual_number'} . $self->{_server_info}->{details}->{server_provider}->{provider_pin};
    while (!$is_complete) {    
        my $result =
          $inphonex->did_list(
            $self->{_server_info}->{details}->{server_provider}->{provider_username} );
        #Sort according to decreasing virtual number
        my @dids = @{$result->{dids}};
        foreach (@dids) {
            # Formatted did
            my $formatted_did = format_did( $_->{did} );
            # Construct unbound_virtual_number
            my $unbound_virtual_number =
                $_->{virtual_number}
              . $self->{_server_info}->{details}->{server_provider}->{provider_pin};
            # Check if you're trying to use main virtual number
            if ($main_unbound_vn == $unbound_virtual_number) {
               my $row = $self->{_fcs_dbh}->table('UnboundMap')
                   ->search( { unbound_virtual_number => $unbound_virtual_number,
                           -or => [
                               phone_number => {'=', undef},
                               'length(phone_number)' => {'<',1}
                           ]
                       } )->single();
               if ($row) {  
                   $row->update( { phone_number => $formatted_did } );
                   $new_did->{$formatted_did} = 2;
               }
            }
            else {          
                # Check if record is existing
                my $unbound_map_retval = 
                  $self->{_fcs_dbh}->table('UnboundMap')->find_or_new(
                    {
                        unbound_virtual_number => $unbound_virtual_number,
                        server_id              => $self->{_server_info}->{details}->{server_id},
                        host                   => $self->{_server_info}->{details}->{mosted},
                        phone_number           => $formatted_did,
                        is_default             => 0
                    }
                );
                if ( !$unbound_map_retval->in_storage ) {
                    $unbound_map_retval->insert;
                    $new_did->{$formatted_did} = 1;
                }
            }
        }
        $new_quantity = keys %$new_did;        
        if ($quantity == $new_quantity) {
            $is_complete = 1;
        }
        elsif ($max_tries == $num_tries) {
            Fap->trace_error("ERR : Error retrieving new DIDs purchased.  Maximum tries reached");
            return undef;
        }
        else {
            $num_tries++;
            sleep 5;
        }
    }
    my @new_dids = keys %$new_did;
    return \@new_dids;
}

=head2 format_did

=over 4

    Formats inphonex did numbers

    Arguments: did
    Returns: formatted did

=cut

sub format_did {
    my $did = shift;
    $did =~ s/^1//;
    my $did_number = $did =~ /^011/ ? $did : "1$did";
    return $did_number;
}

=head2 unformat_did

=over 4

    Unformats inphonex did numbers

    Arguments: formatted did
    Returns: unformatted did

=cut

sub unformat_did {
    my $did = shift;
    $did =~ s/^1|011//;
    return $did;
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

sub delete_dids {
    my ($self, $server_id, $dids) = @_;
    if ( !$self->_check_inphonex_obj($server_id) ) {
        Fap->trace_error("ERR: Could not get inphonex details");
        return undef;
    }
    foreach my $did (@{$dids}) {
        $self->_delete_did($did);            
    }
    return $self->SUPER::delete_dids($server_id ,$dids);
}




=head2 _delete_did

=over 4

    Delete a DID in inphonex and in database

    Arguments: did
    Returns: formatted did

=cut

sub _delete_did {
    my $self            = shift;
    my $did             = shift;
    my $unformatted_did = Fap::Provider::Inphonex::unformat_did($did);
    my $inphonex        = $self->{_inphonex_obj};
    my $rs = $self->{_fcs_dbh}->table('UnboundMap')->search(
        {
            server_id => $self->{_server_info}->{details}->{server_id},
            phone_number    => $did
        }
    );
    if ( my $row = $rs->next() ) {
        #Remove in inphonex
        my $retval = $inphonex->did_delete(
            DID      => $unformatted_did,
            Comments => 'Deleting DID via Inphonex webservice'
        );
        if ($retval) {
            $row->delete();
            return 1;
        }
        else {
            Fap->trace_error("Deleting DID in Inphonex failed");
            return undef;
        }
    }
}

=head2 purchase_dids

=over 4

        Purchases DIDs by calling Inphonex web service

        Arguments: did
        Returns: formatted did

=cut

sub purchase_dids {
    my ( $self, $server_id, $desired_dids, $did_type ) = @_;
    my $virtual_number;
    my $retval;
    
    #Check if desired_did is correct
    foreach my $desired_did (@$desired_dids) {
        if ($desired_did > 999) {
            Fap->trace_error("ERR: DID request contains invalid prefix");
            return undef;
        }
    }
    if ( !$self->_check_inphonex_obj($server_id) ) {
        Fap->trace_error("ERR: Could not get inphonex object");
        return undef;
    }
    my $inphonex = $self->{_inphonex_obj};
    my $main_virtual_number_flag = 0;
    foreach my $desired_did (@$desired_dids) {
        # Get virtual number
        $virtual_number = $self->_get_available_virtual_number($server_id, $main_virtual_number_flag);
        $retval = $self->_order_did( $server_id, $virtual_number, $did_type, $desired_did );
        if ($@) {
            Fap->trace_error("ERR: Encountered error ordering Inphonex DID: " . $inphonex->extract_faultstring()); 
            return undef;
        }
        if ($virtual_number == $self->{_server_info}->{details}->{virtual_number}) {
            $main_virtual_number_flag = 1;
        }
    }
    my $quantity = scalar @$desired_dids;
    my @dids = $self->_update_did_map($server_id, $quantity);
     # call parent 
    return $self->SUPER::purchase_dids($server_id ,@dids ,$did_type);
}

=head2 process_lnps

=over 4

        Processes LNP requests

        Arguments: server_id, array ref of dids, did type
        Returns: 

=cut

sub process_lnps {
    my ( $self, $server_id, $desired_dids, $did_type ) = @_;
    my $virtual_number;
    my $retval;
    my $dbh = $self->{'_pbxtra_dbh'}->dbh();

    #Check if desired_did is correct
    foreach my $desired_did (@$desired_dids) {
        if ($desired_did < 999999999) {
            Fap->trace_error("ERR: LNP request contains invalid DID");
            return undef;
        }
    }

    if ( !$self->_check_inphonex_obj($server_id) ) {
        Fap->trace_error("ERR: Could not get inphonex object");
        return undef;
    }

    foreach my $desired_did (@$desired_dids) {
        # Get virtual number
        $virtual_number = $self->_get_available_virtual_number($server_id);
        $retval = $self->_order_lnp( $server_id, $virtual_number, $did_type, $desired_did );
        if ($@) {
            Fap->trace_error("ERR: Encountered error when requesting for lnp\n$@");
            return undef;
        }
    }
    my $quantity = scalar @$desired_dids;
    my @dids = $self->_update_did_map($server_id, $quantity);

    #Create RT by firing F::Inphonex->start_lnp
    #Skip RT creation if on test mode
    if (!$self->{'_is_test'}) {
       #Get Customer Details
       my $customer = Fap::Customer->new(customer_id=>$self->{'_server_info'}->{'details'}->{'customer_id'});
       start_lnp(
               $dbh,
               company_name => $customer->{'details'}->{'name'},
               email        => $self->{'_server_info'}->{'details'}->{'customer'}->{'contact'}->{'email1'},
               numbers      => \@dids,
               server_id    => $server_id,
           );        
    }
    # call parent of purchase_dids - update phone_numbers
    return $self->SUPER::purchase_dids($server_id ,@dids ,$did_type);

}


=head2 _get_provider_customer_id_via_virtual_number

=over 4

        Retrieves the Inphonex ID using Virtual Numbers by calling Inphonex web service

        Arguments: virtual_number
        Returns: 1 for success, undef for error/failed

=cut

sub _get_provider_customer_id_via_virtual_number {
    my $self     = shift;
    my $vn       = shift;
    my $inphonex = $self->{_inphonex_obj};
    my $first = time;
    my $inphonex_id;
    
    eval {
        local $SIG{ALRM} = sub { die "Timeout\n" };
        alarm $self->{'_config'}->{'timeout'}->{'account'}->{'active'};

        # keep trying to get a virtual_number every second
        while (
            !(
                $inphonex_id =
                $inphonex->get_customer_id( $self->_get_virtual_number )
            )
            && (
                time - $first <=
                $self->{'_config'}->{'timeout'}->{'account'}->{'active'} 
            )
        )
        {
            # Waiting for the account to be created so we can fetch a customer_id
            sleep 1;
        }

        die "Timeout\n" if time - $first >
            $self->{'_config'}->{'timeout'}->{'account'}->{'active'};
        alarm 0;
    };
    if ( $@ =~ /Timeout/ ) {
        Fap->trace_error(
"ERR: Inphonex get_customer_id(virtual_number) timed out. Could not retrieve Inphonex id"
        );
        return undef;
    }
    
    $self->set_provider_customer_id( $inphonex_id );

    return 1;
}
1;
