package Fap::Model::MyDNS;
use strict;
use base qw(Fap::Model::DBIx);
use Fap::Model::MyDNS::Backend();

sub schema_class { return "Fap::Model::MyDNS::Backend"; }

sub dbn {
    return "mydns";
}
sub new {
        die "This module is deprecated. Please reference the appropriate table using Fap::Model::Fcs. If the table you wish to reference is not yet available in Fap::Model::Fcs,
 please contact mhollenbeck\@finality.com\n";
}


1;
