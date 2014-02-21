package Fap::Model::Config;
use strict;
use base qw(Fap::Model::DBIx);
use Fap::Model::Config::Backend();

sub schema_class { return "Fap::Model::Config::Backend"; }

sub dbn {
        return "config";
}

sub dsn {
    return "dbi:mysql:fcs:" . $_[0]->host;
}
sub new {
        die "This module is deprecated. Please reference the appropriate table using Fap::Model::Fcs. If the table you wish to reference is not yet available in Fap::Model::Fcs,
 please contact mhollenbeck\@finality.com\n";
}


1;
