package Fap::Model::Fcs::Backend::Result::OrderGroup;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

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
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "is_primary",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "shipping_address_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "billing_address_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "chosen_shipping_id",
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
    is_nullable => 0,
  },
  "netsuite_sales_order_id",
  { data_type => "bigint", extra => { unsigned => 1 }, is_nullable => 1 },
  "netsuite_echosign_id",
  { data_type => "bigint", extra => { unsigned => 1 }, is_nullable => 1 },
  "one_time_total",
  {
    data_type => "decimal",
    default_value => "0.00",
    is_nullable => 0,
    size => [10, 2],
  },
  "mrc_total",
  {
    data_type => "decimal",
    default_value => "0.00",
    is_nullable => 0,
    size => [10, 2],
  },
  "one_time_tax_total",
  {
    data_type => "decimal",
    default_value => "0.00",
    is_nullable => 0,
    size => [10, 2],
  },
  "mrc_tax_total",
  {
    data_type => "decimal",
    default_value => "0.00",
    is_nullable => 0,
    size => [10, 2],
  },
);
__PACKAGE__->set_primary_key("order_group_id");
__PACKAGE__->add_unique_constraint("order_id", ["order_id", "netsuite_sales_order_id"]);
__PACKAGE__->add_unique_constraint(
  "order_id_2",
  ["order_id", "server_id", "shipping_address_id"],
);
__PACKAGE__->has_many(
  "order_bundles",
  "Fap::Model::Fcs::Backend::Result::OrderBundle",
  { "foreign.order_group_id" => "self.order_group_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->belongs_to(
  "billing_address",
  "Fap::Model::Fcs::Backend::Result::EntityAddress",
  { entity_address_id => "billing_address_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);
__PACKAGE__->belongs_to(
  "chosen_shipping",
  "Fap::Model::Fcs::Backend::Result::OrderShipping",
  { order_shipping_id => "chosen_shipping_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);
__PACKAGE__->belongs_to(
  "product",
  "Fap::Model::Fcs::Backend::Result::Product",
  { product_id => "product_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);
__PACKAGE__->belongs_to(
  "order",
  "Fap::Model::Fcs::Backend::Result::Order",
  { order_id => "order_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);
__PACKAGE__->belongs_to(
  "shipping_address",
  "Fap::Model::Fcs::Backend::Result::EntityAddress",
  { entity_address_id => "shipping_address_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);
__PACKAGE__->has_many(
  "order_shippings",
  "Fap::Model::Fcs::Backend::Result::OrderShipping",
  { "foreign.order_group_id" => "self.order_group_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "order_transactions",
  "Fap::Model::Fcs::Backend::Result::OrderTransaction",
  { "foreign.order_group_id" => "self.order_group_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "order_transaction_items",
  "Fap::Model::Fcs::Backend::Result::OrderTransactionItem",
  { "foreign.order_group_id" => "self.order_group_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-03-21 08:48:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:wmm73nyjEGqH5ApZ6MMUAg

__PACKAGE__->has_one(
    "server" => "Fap::Model::Fcs::Backend::Result::PbxtraServer",
    { "foreign.server_id" => "self.server_id" }, { cascade_copy => 0, cascade_delete => 0 } );

# You can replace this text with custom content, and it will be preserved on regeneration
1;
