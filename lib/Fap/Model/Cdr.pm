package Fap::Model::Cdr;
use strict;
use base qw(Fap::Model::DBIx);
use Fap::Model::Cdr::Backend();

sub schema_class { return "Fap::Model::Cdr::Backend"; }
sub dbn          { return "pbxtra"; }

sub dsn {
    return "dbi:mysql:hus:" . $_[0]->host;
}
sub server_group {
	return "cdr";
}
1;
