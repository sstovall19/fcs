package Fap::Model::Fcs::Backend::Result::OrderDiscount;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("order_discount");
__PACKAGE__->add_columns(
  "order_discount_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "order_id",
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
  "promo_code_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "one_time_discount",
  {
    data_type => "decimal",
    default_value => "0.00",
    is_nullable => 0,
    size => [10, 2],
  },
  "mrc_discount",
  {
    data_type => "decimal",
    default_value => "0.00",
    is_nullable => 0,
    size => [10, 2],
  },
);
__PACKAGE__->set_primary_key("order_discount_id");
__PACKAGE__->add_unique_constraint("order_id", ["order_id", "promo_code_id"]);
__PACKAGE__->belongs_to(
  "order",
  "Fap::Model::Fcs::Backend::Result::Order",
  { order_id => "order_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);
__PACKAGE__->belongs_to(
  "promo_code",
  "Fap::Model::Fcs::Backend::Result::PromoCode",
  { promo_code_id => "promo_code_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);
__PACKAGE__->belongs_to(
  "discount_type",
  "Fap::Model::Fcs::Backend::Result::DiscountType",
  { discount_type_id => "discount_type_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-02-14 09:21:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:qJgVSlBqdCr6ttOCICcBcQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
