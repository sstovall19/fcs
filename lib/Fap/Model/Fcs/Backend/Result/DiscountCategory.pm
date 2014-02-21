package Fap::Model::Fcs::Backend::Result::DiscountCategory;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("discount_category");
__PACKAGE__->add_columns(
  "discount_category_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 50 },
);
__PACKAGE__->set_primary_key("discount_category_id");
__PACKAGE__->add_unique_constraint("name", ["name"]);
__PACKAGE__->has_many(
  "bundle_categories",
  "Fap::Model::Fcs::Backend::Result::BundleCategory",
  { "foreign.discount_category_id" => "self.discount_category_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "discounts",
  "Fap::Model::Fcs::Backend::Result::Discount",
  { "foreign.category_id" => "self.discount_category_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->might_have(
  "discount_limit",
  "Fap::Model::Fcs::Backend::Result::DiscountLimit",
  { "foreign.category_id" => "self.discount_category_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-01-17 11:54:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ySLbBCpSbb2jz9Zsm3Zn5Q


# You can replace this text with custom content, and it will be preserved on regeneration
1;
