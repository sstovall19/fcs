package Fap::Model::Pbxtra;
use strict;
use base qw(Fap::Model::DBIx);
use Fap::Model::Pbxtra::Backend();

sub schema_class { return "Fap::Model::Pbxtra::Backend"; }

sub dbn {
    return "pbxtra";
}

sub new {
	die "FCS";
}


1;
