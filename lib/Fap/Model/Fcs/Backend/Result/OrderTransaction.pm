package Fap::Model::Fcs::Backend::Result::OrderTransaction;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("order_transaction");
__PACKAGE__->add_columns(
  "order_transaction_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "server_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "customer_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "order_group_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "billing_schedule_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "netsuite_trans_id",
  { data_type => "bigint", extra => { unsigned => 1 }, is_nullable => 1 },
  "payment_method_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "credit_card_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "amount",
  {
    data_type => "decimal",
    default_value => "0.00",
    is_nullable => 0,
    size => [10, 2],
  },
  "type",
  {
    data_type => "enum",
    extra => { list => ["CASH_SALE", "INVOICE", "ORDER"] },
    is_nullable => 1,
  },
  "status",
  {
    data_type => "enum",
    default_value => "NOT_PROCESSED",
    extra => {
      list => ["NOT_PROCESSED", "READY_TO_PROCESS", "PROCESSING", "PROCESSED"],
    },
    is_nullable => 0,
  },
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
__PACKAGE__->set_primary_key("order_transaction_id");
__PACKAGE__->belongs_to(
  "payment_method",
  "Fap::Model::Fcs::Backend::Result::PaymentMethod",
  { payment_method_id => "payment_method_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);
__PACKAGE__->belongs_to(
  "billing_schedule",
  "Fap::Model::Fcs::Backend::Result::BillingSchedule",
  { billing_schedule_id => "billing_schedule_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);
__PACKAGE__->belongs_to(
  "credit_card",
  "Fap::Model::Fcs::Backend::Result::EntityCreditCard",
  { entity_credit_card_id => "credit_card_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);
__PACKAGE__->belongs_to(
  "order_group",
  "Fap::Model::Fcs::Backend::Result::OrderGroup",
  { order_group_id => "order_group_id" },
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
  { "foreign.order_transaction_id" => "self.order_transaction_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "order_transaction_logs",
  "Fap::Model::Fcs::Backend::Result::OrderTransactionLog",
  { "foreign.order_transaction_id" => "self.order_transaction_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-03-14 10:41:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:t9XLpsmOXx7ZL2lkxpvxKQ


sub column_defaults {
   return {
      created=>\'NULL',
   }
}



# You can replace this text with custom content, and it will be preserved on regeneration
1;
