package Fap::Model::Fcs::Backend::Result::ResellerDiscount;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("reseller_discount");
__PACKAGE__->add_columns(
  "reseller_discount_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "reseller_type_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "discount_type_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "discount_percent",
  {
    data_type => "decimal",
    default_value => "0.00",
    is_nullable => 0,
    size => [5, 2],
  },
);
__PACKAGE__->set_primary_key("reseller_discount_id");
__PACKAGE__->add_unique_constraint("reseller_type_id", ["reseller_type_id", "discount_type_id"]);
__PACKAGE__->belongs_to(
  "discount_type",
  "Fap::Model::Fcs::Backend::Result::DiscountType",
  { discount_type_id => "discount_type_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);
__PACKAGE__->belongs_to(
  "reseller_type",
  "Fap::Model::Fcs::Backend::Result::ResellerType",
  { reseller_type_id => "reseller_type_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-02-11 10:54:35
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:uLcr4x0xoWJPJzYxdENW9A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
