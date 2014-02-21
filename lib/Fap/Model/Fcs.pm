package Fap::Model::Fcs;
use strict;
use base qw(Fap::Model::DBIx);
use Fap::Model::Fcs::Backend();
use Fap;

#BEGIN REFLIST
use Fap::Model::Fcs::Ref::LicenseType;
use Fap::Model::Fcs::Ref::DiscountCategory;
use Fap::Model::Fcs::Ref::PriceModel;
use Fap::Model::Fcs::Ref::OrderStatus;
use Fap::Model::Fcs::Ref::Feature;
use Fap::Model::Fcs::Ref::PaymentMethod;
use Fap::Model::Fcs::Ref::TaxMapping;
use Fap::Model::Fcs::Ref::Deployment;
use Fap::Model::Fcs::Ref::BundleCategory;
use Fap::Model::Fcs::Ref::DiscountType;
#END REFLIST

sub schema_class { return "Fap::Model::Fcs::Backend"; }

sub dbn { 
    my $self = shift;
    if ( $ENV{FCS_TEST} == 1 || $self->{test_mode} ) {
        return "fcstest";
    } elsif ($self->{use_dbn}) {
	return $self->{use_dbn};
    } else {
        return "fcs";
    }
}

sub new {
	my ($class,@params) = @_;
	my $self = $class->SUPER::new(@params);
	$self->{_foreign_tables} = Fap->load_conf("database/legacy_mapping");
	return $self;
}
sub foreign_table {
	my ($self,$table) = @_;

	return $self->{_foreign_tables}->{$table};
}

sub dsn {
    return "dbi:mysql:fcs:" . $_[0]->host;
}

1;
