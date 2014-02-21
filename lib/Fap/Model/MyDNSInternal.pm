package Fap::Model::MyDNSInternal;
use strict;
use base qw(Fap::Model::DBIx);
use Fap::Model::MyDNSInternal::Backend();

sub schema_class { return "Fap::Model::MyDNSInternal::Backend"; }

sub dbn {
    return "mydns_internal";
}
sub new {
        die "This module is deprecated. Please reference the appropriate table using Fap::Model::Fcs. If the table you wish to reference is not yet available in Fap::Model::Fcs,
 please contact mhollenbeck\@finality.com\n";
}


1;
