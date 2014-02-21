package Fap::Db::Fcs::Backend::Result::OrderTransaction;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("order_transaction");
__PACKAGE__->add_columns(
  "order_transaction_id",
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
    is_nullable => 1,
  },
  "contact_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "cc_info_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "billing_address_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "payment_type",
  {
    data_type => "enum",
    default_value => "cc",
    extra => { list => ["cc", "ach", "wire", "check", "paypal", "none"] },
    is_nullable => 0,
  },
  "total_paid",
  {
    data_type => "decimal",
    default_value => "0.00",
    is_nullable => 0,
    size => [10, 2],
  },
  "created",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
);
__PACKAGE__->set_primary_key("order_transaction_id");
__PACKAGE__->belongs_to(
  "order",
  "Fap::Db::Fcs::Backend::Result::Order",
  { order_id => "order_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);
__PACKAGE__->belongs_to(
  "contact",
  "Fap::Db::Fcs::Backend::Result::EntityContact",
  { entity_contact_id => "contact_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);
__PACKAGE__->belongs_to(
  "billing_address",
  "Fap::Db::Fcs::Backend::Result::EntityAddress",
  { entity_address_id => "billing_address_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-12 12:50:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+lTw3RMvolkfcMBpKGm79g


# You can replace this text with custom content, and it will be preserved on regeneration
1;
