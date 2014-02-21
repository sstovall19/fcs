package Fap::Model::Fcs::Backend::Result::PriceModel;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("price_model");
__PACKAGE__->add_columns(
  "price_model_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 50 },
);
__PACKAGE__->set_primary_key("price_model_id");
__PACKAGE__->add_unique_constraint("name", ["name"]);
__PACKAGE__->has_many(
  "bundle_price_models",
  "Fap::Model::Fcs::Backend::Result::BundlePriceModel",
  { "foreign.price_model_id" => "self.price_model_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-01-17 11:54:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hSJQCvu7fx7+JZdPr+swKg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
