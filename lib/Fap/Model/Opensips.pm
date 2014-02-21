package Fap::Model::Opensips;
use strict;
use base qw(Fap::Model::DBIx);
use Fap::Model::Opensips::Backend();

sub schema_class { return "Fap::Model::Opensips::Backend"; }

sub dbn {
    return "opensips";
}

sub dsn {
    return "dbi:mysql:opensips:" . $_[0]->host;
}
sub server_group {
        return "opensips";
}
1;
