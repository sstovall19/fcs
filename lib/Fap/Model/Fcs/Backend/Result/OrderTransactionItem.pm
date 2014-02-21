package Fap::Model::Fcs::Backend::Result::OrderTransactionItem;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("order_transaction_item");
__PACKAGE__->add_columns(
  "order_transaction_item_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "order_transaction_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "order_group_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "parent_trans_item_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "bundle_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "netsuite_item_id",
  { data_type => "bigint", extra => { unsigned => 1 }, is_nullable => 0 },
  "quantity",
  {
    data_type => "integer",
    default_value => 1,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "list_price",
  {
    data_type => "decimal",
    default_value => "0.00",
    is_nullable => 0,
    size => [10, 2],
  },
  "description",
  { data_type => "mediumtext", is_nullable => 0 },
  "monthly_usage",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "amount",
  {
    data_type => "decimal",
    default_value => "0.00",
    is_nullable => 0,
    size => [10, 2],
  },
);
__PACKAGE__->set_primary_key("order_transaction_item_id");
__PACKAGE__->belongs_to(
  "order_group",
  "Fap::Model::Fcs::Backend::Result::OrderGroup",
  { order_group_id => "order_group_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);
__PACKAGE__->belongs_to(
  "order_transaction",
  "Fap::Model::Fcs::Backend::Result::OrderTransaction",
  { order_transaction_id => "order_transaction_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);
__PACKAGE__->belongs_to(
  "bundle",
  "Fap::Model::Fcs::Backend::Result::Bundle",
  { bundle_id => "bundle_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);
__PACKAGE__->belongs_to(
  "parent_trans_item",
  "Fap::Model::Fcs::Backend::Result::OrderTransactionItem",
  { order_transaction_item_id => "parent_trans_item_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);
__PACKAGE__->has_many(
  "order_transaction_items",
  "Fap::Model::Fcs::Backend::Result::OrderTransactionItem",
  {
    "foreign.parent_trans_item_id" => "self.order_transaction_item_id",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-03-07 11:07:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:aAnHTYupF2ewu0B4g3lz9g


# You can replace this text with custom content, and it will be preserved on regeneration
1;
