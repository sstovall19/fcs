package Fap::Model::Fcs::Backend::Result::BillingSchedule;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("billing_schedule");
__PACKAGE__->add_columns(
  "billing_schedule_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "customer_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "order_id",
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
  "payment_method_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "type",
  {
    data_type => "enum",
    default_value => "SERVICE",
    extra => { list => ["SERVICE", "SYSTEM", "ALL"] },
    is_nullable => 0,
  },
  "start_date",
  {
    data_type     => "timestamp",
    default_value => "1970-01-01 00:00:00",
    is_nullable   => 0,
  },
  "end_date",
  {
    data_type     => "timestamp",
    default_value => "1970-01-01 00:00:00",
    is_nullable   => 0,
  },
  "status",
  {
    data_type => "enum",
    default_value => "NOT_PROCESSED",
    extra => {
      list => ["NOT_PROCESSED", "PROCESSED_MRC_AND_TAX", "PROCESSED_ALL"],
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
__PACKAGE__->set_primary_key("billing_schedule_id");
__PACKAGE__->belongs_to(
  "payment_method",
  "Fap::Model::Fcs::Backend::Result::PaymentMethod",
  { payment_method_id => "payment_method_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
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
  "order",
  "Fap::Model::Fcs::Backend::Result::Order",
  { order_id => "order_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);
__PACKAGE__->has_many(
  "order_transactions",
  "Fap::Model::Fcs::Backend::Result::OrderTransaction",
  { "foreign.billing_schedule_id" => "self.billing_schedule_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "order_transaction_logs",
  "Fap::Model::Fcs::Backend::Result::OrderTransactionLog",
  { "foreign.billing_schedule_id" => "self.billing_schedule_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-03-21 08:48:12
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:CXQdK72xWFc7SebY0TYNug

sub column_defaults {
   return {
      created=>\'NULL',
   }
}

# You can replace this text with custom content, and it will be preserved on regeneration
1;
