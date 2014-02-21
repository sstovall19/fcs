package Fap::Server;
use Fap::Model::Fcs;
use Fap::Locale;
use Locale::Country;
use Locale::SubCountry;
use F::RPC;
use F::Server;
use strict;

=head2 new

=over 4

Create a new instance of Server object

Args: server_id
Returns: $self

=back

=cut

sub new {
    my $subname = 'Fap::Server::new';
    my ( $class, %args ) = @_;
    my $fcs_schema = $args{fcs_schema} || Fap::Model::Fcs->new();
    my $self = bless {
        server_id  => $args{server_id},
        fcs_schema => $fcs_schema,
    }, $class;
    $self->{'details'} = $self->get();
    return $self;
}

=head2 get

=over 4

Derives a hashmap of server details.  This is being called in the object instantiation

Returns: hash of server details

=back

=cut

sub get {
    my $self = shift;
    my $rec  = $self->{'fcs_schema'}->table('Server')->find(
        { "me.server_id" => $self->{'server_id'} },
        {
            prefetch =>
              [ 'deployment', 'server_provider', { customer => 'contact' } ]
        }
    );
    return $rec->strip || undef;
}

=head2 add_bundle

=over 4

Associates a bundle to the server

Args: bundle_id
Returns: undef if server-bundle relation already exists else return the created server_bundle_id

=back

=cut

sub add_bundle {
    my $self      = shift;
    my $bundle_id = shift;
    my $row =
      $self->{'fcs_schema'}->table('server_bundle')
      ->find_or_new(
        { bundle_id => $bundle_id, server_id => $self->{'server_id'} } );
    if ( !$row->in_storage ) {
        $row->insert;
        return $row->get_column("server_bundle_id");
    }
    else {
        return undef;
    }
}

=head2 remove_bundle

=over 4

Disassociate a bundle from a server

Args: bundle_id
Returns: 1 if server_bundle_id is found and removed else 1 

=back

=cut

sub remove_bundle {
    my $self             = shift;
    my $server_bundle_id = shift;
    if (
        $self->{'fcs_schema'}->table('server_bundle')->search(
            {
                server_bundle_id => $server_bundle_id,
                server_id        => $self->{'server_id'}
            }
        )->delete() > 0
      )
    {
        return 1;
    }
    else {
        return 0;
    }
}

=head2 is_hosted

=over 4

Determine if server is hosted or not

Returns: boolean or undef if no records are found

=back

=cut

sub is_hosted {
    my $self = shift;
    return $self->{details}->{deployment}->{is_hosted};
}

=head2 set_product_id

=over 4

Sets the product_id of server

Args: product_id
Returns: 1 if update succeeds else 0

=back

=cut

sub set_product_id {
    my $self       = shift;
    my $product_id = shift;
    if ( $self->{'fcs_schema'}->table('Server')
        ->search( { server_id => $self->{'server_id'} } )
        ->update( { 'product_id' => $product_id } ) > 0 )
    {
        return 1;
    }
    else {
        return 0;
    }
}

=head2 set_can_link_server

=over 4

Modifies the value of server.can_link_server.  Serves as an indication that a server can participate in a linked server environment

Args: 0/1 value for can_link_server
Returns: 1 if value of can_link_server was changed else 0

=back

=cut

sub set_can_link_server {
    my $self            = shift;
    my $can_link_server = shift;
    if ( !$self->is_hosted ) {
        if ( $self->{'fcs_schema'}->table('Server')
            ->search( { server_id => $self->{'server_id'} } )
            ->update( { 'can_link_server' => $can_link_server } ) > 0 )
        {
            return 1;
        }
        else {
            return 0;
        }
    }
}

=head2 set_locale

=over 4

Sets country and localtime_file of the server

Args: country_code, state_code
Returns: 1 if successful else 0

=back

=cut

sub set_locale {
    my $self         = shift;
    my $country_code = shift;
    my $state_code   = shift;
    my $server_id    = $self->{'server_id'};

    #If $country_code is 3 char, convert to 2 char before proceeding
    if ( length($country_code) == 3 ) {
        $country_code = country_code2code( $country_code, LOCALE_CODE_ALPHA_3,
            LOCALE_CODE_ALPHA_2 );
    }

    my $timezone      = Fap::Locale::get_timezone( $country_code, $state_code );
    my $language_code = Fap::Locale::get_language($country_code);
    my $obj_country   = Locale::SubCountry->new($country_code);
    my $country       = $obj_country->country;
    if ($timezone) {
        $timezone = "/usr/share/zoneinfo/" . $timezone;
        if ( F::RPC::set_localtime( $server_id, $timezone ) ) {
            if (
                $self->{'fcs_schema'}->table('Server')
                ->search( { server_id => $self->{'server_id'} } )->update(
                    {
                        'localtime_file' => $timezone,
                        'country'        => $country,
                        'language'       => $language_code
                    }
                ) > 0
              )
            {
                return 1;
            }
            else {
                Fap::trace_error("ERR: Unable to set timezone");
                return 0;
            }
        }
        else {
            Fap::trace_error("ERR: Unable to set timezone");
            return 0;
        }
    }
    else {
        Fap::trace_error("ERR: No timezone obtained for $country");
        return 0;
    }
}

=head2 reset_locale

=over 4

reset locale related information in database

Args: None 
Returns: 1 on success else 0

=back

=cut

sub reset_locale {
    my $self = shift;
    if (
        F::RPC::set_localtime(
            $self->{'server_id'}, Fap::Global::kDEFAULT_TIMEZONE
        )
      )
    {
        if (
            $self->{'fcs_schema'}->table('Server')
            ->search( { server_id => $self->{'server_id'} } )->update(
                {
                    'localtime_file' => undef,
                    'country'        => undef,
                    'language'       => undef
                }
            ) > 0
          )
        {
            return 1;
        }
        else {
            Fap->trace_error("ERR: Unable to reset timezone");
            return 0;
        }
    }
    else {
        Fap->trace_error("ERR: Unable to reset timezone");
        return 0;
    }
}

=head2 get_attribute

=over 4

Accesses database through dbix and returns the values of the fields requested

Args: array reference of fieldnames in server table
Returns: hashref of field values

=back

=cut

sub get_attribute {
    my $self      = shift;
    my $attribute = shift;
    my $row       = $self->{'fcs_schema'}->table('Server')->find(
        { server_id => $self->{'server_id'} },
        { select    => [ $attribute, 'server_id' ] }
    );
    return $row->get_column($attribute);
}

=head2 set_hud_pw

=over 4

Sets the has_hud of server

Args: 6 char string
Returns: 1 if update succeeds else 0

=back

=cut

sub set_hud_pw {
    my $self   = shift;
    my $hud_pw = shift;
    if ( $self->{'fcs_schema'}->table('Server')
        ->search( { server_id => $self->{'server_id'} } )
        ->update( { 'has_hud' => $hud_pw } ) > 0 )
    {
        return 1;
    }
    else {
        return 0;
    }
}

=head2 add_basic_roles

=over 4

 Create the basic roles for new servers.

 Arguments: none.

 Returns: 1 if successful, 0 otherwise (undef on error)

 Example: $server->add_basic_roles();

 Notes:  Exported from F::Server::add_basic_roles.  You should use F 13.1 or greater.

=back

=cut

sub add_basic_roles {
    my $self = shift;

    return ( F::Server::add_basic_roles( $self->{'server_id'} ) );
}

1;
