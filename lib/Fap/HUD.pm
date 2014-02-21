# Copyright 2012, Fonality Inc. ALL RIGHTS RESERVED

=head1 NAME

Fap::HUD;

=head1 VERSION


=head1 SYNOPSIS

  use Fap::HUD;

=head1 DESCRIPTION

Library functions for working with HUD settings

=head1 FUNCTIONS

	set_server_policy
        set_hud_variable
        set_hud_enabled
        get_server_policy
        get_current_hud_policy

API functions available in this library

=cut

package Fap::HUD;

use Exporter;
@ISA    = qw/Exporter/;
@EXPORT = qw/
set_server_policy
set_hud_variable
set_hud_enabled
get_server_policy
get_current_hud_policy
/;

use strict;
use Fap;
use Fap::Model::Fcs;
use F::Options;
use F::HUDSupport;

=head2 get_server_policy

=over 4

Gets the HUD policy associated to the server.

=back

=cut
sub get_server_policy {
    my %params  = @_;;
    my $fcs_db  = Fap::Model::Fcs->new();

    my $rs = $fcs_db->table('ServerExt')->single( { "me.server_id" => $params{'server_id'} } );

    return undef unless defined $rs;

    return $rs->policy;
}

=head2 set_server_policy

=over 4

Sets the HUD policy appropriate for the server.

=back

=cut
sub set_server_policy {
    my %params   = @_;
    my $fcs_db   = Fap::Model::Fcs->new();

    if ( defined($params{'policy'}) ) {
        my $rs = $fcs_db->table('UpdatePolicy')->find( { "me.id" => $params{'policy'}, 'me.build' => { '!=' => 0 } } );
        my $policy = $rs->get_column('id');
        # error if policy DNE
        if ( not $policy ) {
            Fap->trace_error('Policy ' . $params{'policy'} . ' does not exist.');
            return undef;
        }

        # insert HUS policy for server
        $fcs_db->table('ServerExt')->update_or_create( {
                'server_id' => $params{'server_id'},
                'edition'   => undef,
                'policy'    => $params{'policy'}
            },
            { key => 'primary' } );
    } else {
        my $rs = $fcs_db->table('ServerExt')->search( { "me.server_id" => $params{'server_id'} } )->delete();
    }

    return 1;
}

=head2 get_current_hud_policy

=over 4

Wrapper for F::HUDSupport::get_current_hud_policy.

=back

=cut
sub get_current_hud_policy
{
    my %params = @_;

    return F::HUDSupport::get_current_hud_policy($params{'type'});
}

=head2 set_hud_variable

=over 4

Wrapper for F::HUDSupport::_set_hud_variable.

=back

=cut
sub set_hud_variable
{
    my %params = @_;

    return F::HUDSupport::_set_hud_variable($params{'config_file'}, $params{'server_id'}, $params{'type'}, $params{'hostname'});
}

=head2 set_hud_enabled

=over 4

Wrapper for F::Options::set_hud_enabled.

=back

=cut
sub set_hud_enabled
{
    my %params = @_;

    return F::Options::set_hud_enabled($params{'server_id'}, $params{'enabled'});
}

1;
