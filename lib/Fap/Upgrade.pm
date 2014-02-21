# Copyright 2012, Fonality Inc. ALL RIGHTS RESERVED
package Fap::Upgrade;

use strict;
use Fap;
use Fap::Global;
use F::Upgrade::pbxtracore;
use F::Upgrade;
use F::Database;

=head2 insert_upgrade_batch

=over 4

Wrapper for F::insert_upgrade_batch

   Args: {server id, cp version}
Returns: none

=back

=cut
##############################################################################
# insert_upgrade_batch
##############################################################################
sub insert_upgrade_batch
{
    my %params = @_;

    return F::Upgrade::insert_upgrade_batch($params{'server_id'}, $params{'version'});
}


=head2 get_all_upgrades_for_server

=over 4

Wrapper for F::get_all_upgrades_for_server

   Args: {dbh, server id, target cp version}
Returns: list of upgrade

=back

=cut
##############################################################################
# get_all_upgrades_for_server
##############################################################################
sub get_all_upgrades_for_server
{
    my %params = @_;

    if (not exists $params{'dbh'} || !F::Database::valid_dbh($params{'dbh'}))
    {
        my $dbh_types = F::Database::connection_type();
        my $connect = $dbh_types->{'default'};
        $params{'dbh'} = $connect->();
    }

    return F::Upgrade::get_all_upgrades_for_server($params{'dbh'}, $params{'server_id'}, $params{'requested_version'});
}


=head2 upgrade_guest_batch

=over 4

Queries and executes all connect guest upgrades

   Args: dbh, server id
Returns: none

=back

=cut
##############################################################################
# upgrade_guest_batch
##############################################################################
sub upgrade_guest_batch
{
    my %params = @_;

    if (not exists $params{'dbh'} || !F::Database::valid_dbh($params{'dbh'}))
    {
        my $dbh_types = F::Database::connection_type();
        my $connect = $dbh_types->{'default'};
        $params{'dbh'} = $connect->();
    }

    my $ref = Fap::Upgrade::get_all_upgrades_for_server($params{'dbh'}, $params{'server_id'}, Fap::Global::kCP_VERSION());
    foreach my $row (@{$ref})
     {        
        (my $uscript = $row->{'project_name'}) =~ tr/./_/;    
        my $func = "F::Upgrade::pbxtracore::config_${uscript}";
        if (defined &{$func})
        {
            \&{$func}($params{'dbh'}, $params{'server_id'});
            if ($@)
            {
                Fap->trace_error("ERR: Unable to continue with the $uscript upgrades.");
                return undef;
            }    
        }
        else 
        {
            Fap->trace_error("Upgrade function not existing.");
            return undef;
        }
    }
}

1;
