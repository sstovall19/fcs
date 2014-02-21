package Fap::Model::Fcs::Backend::Result::TaxMapping;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("tax_mapping");
__PACKAGE__->add_columns(
  "tax_mapping_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "ns_tax_schedule",
  { data_type => "varchar", is_nullable => 0, size => 10 },
  "ns_description",
  { data_type => "mediumtext", is_nullable => 0 },
  "bs_trans_type",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "bs_service_type",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "bs_description",
  { data_type => "mediumtext", is_nullable => 0 },
  "created",
  {
    data_type     => "timestamp",
    default_value => "1970-01-01 00:00:00",
    is_nullable   => 0,
  },
  "updated",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
);
__PACKAGE__->set_primary_key("tax_mapping_id");
__PACKAGE__->add_unique_constraint(
  "ns_tax_schedule",
  ["ns_tax_schedule", "bs_trans_type", "bs_service_type"],
);
__PACKAGE__->has_many(
  "bundle_price_models",
  "Fap::Model::Fcs::Backend::Result::BundlePriceModel",
  { "foreign.tax_mapping_id" => "self.tax_mapping_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-03-21 08:48:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:XdXazX6A9Mj+IQCTx4g0Ww


sub column_defaults {
   return {
      created=>\'NULL',
   }
}



# You can replace this text with custom content, and it will be preserved on regeneration
1;
