package Fap::Model::Hus;
use strict;
use base qw(Fap::Model::DBIx);
use Fap::Model::Hus::Backend();

sub schema_class { return "Fap::Model::Hus::Backend"; }
sub dbn          { return "hus"; }

sub dsn {
    return "dbi:mysql:hus:" . $_[0]->host;
}

sub new {
	die "This module is deprecated. Please reference the appropriate table using Fap::Model::Fcs. If the table you wish to reference is not yet available in Fap::Model::Fcs, please contact mhollenbeck\@finality.com\n";
}

1;
