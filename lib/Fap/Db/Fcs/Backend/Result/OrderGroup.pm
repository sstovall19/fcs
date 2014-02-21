package Fap::Db::Fcs::Backend::Result::OrderGroup;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("order_group");
__PACKAGE__->add_columns(
  "order_group_id",
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
  "server_id",
  { data_type => "integer", is_nullable => 0 },
  "address_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "shipping_type_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "product_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "netsuite_opportunity_id",
  { data_type => "bigint", extra => { unsigned => 1 }, is_nullable => 1 },
  "total_price",
  {
    data_type => "decimal",
    default_value => "0.00",
    is_nullable => 0,
    size => [10, 2],
  },
  "total_sales_tax",
  {
    data_type => "decimal",
    default_value => "0.00",
    is_nullable => 0,
    size => [10, 2],
  },
  "sales_tax_rate",
  {
    data_type => "decimal",
    default_value => "0.00000",
    is_nullable => 0,
    size => [10, 5],
  },
);
__PACKAGE__->set_primary_key("order_group_id");
__PACKAGE__->add_unique_constraint("order_id", ["order_id", "server_id", "address_id"]);
__PACKAGE__->has_many(
  "order_bundles",
  "Fap::Db::Fcs::Backend::Result::OrderBundle",
  { "foreign.order_group_id" => "self.order_group_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->belongs_to(
  "order",
  "Fap::Db::Fcs::Backend::Result::Order",
  { order_id => "order_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);
__PACKAGE__->belongs_to(
  "address",
  "Fap::Db::Fcs::Backend::Result::EntityAddress",
  { entity_address_id => "address_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);
__PACKAGE__->belongs_to(
  "shipping_type",
  "Fap::Db::Fcs::Backend::Result::ShippingType",
  { shipping_type_id => "shipping_type_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);
__PACKAGE__->belongs_to(
  "product",
  "Fap::Db::Fcs::Backend::Result::Product",
  { product_id => "product_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-29 09:59:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JfNw3aVZReUrfaac861TWg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
