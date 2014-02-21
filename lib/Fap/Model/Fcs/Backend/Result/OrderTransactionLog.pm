package Fap::Model::Fcs::Backend::Result::OrderTransactionLog;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("order_transaction_log");
__PACKAGE__->add_columns(
  "order_transaction_log_id",
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
    is_nullable => 1,
  },
  "billing_schedule_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "level",
  {
    data_type => "enum",
    default_value => "INFO",
    extra => { list => ["INFO", "DEBUG", "ERROR", "WARN"] },
    is_nullable => 0,
  },
  "module",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 128 },
  "function",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 128 },
  "message",
  { data_type => "mediumtext", is_nullable => 0 },
  "updated",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
);
__PACKAGE__->set_primary_key("order_transaction_log_id");
__PACKAGE__->belongs_to(
  "order_transaction",
  "Fap::Model::Fcs::Backend::Result::OrderTransaction",
  { order_transaction_id => "order_transaction_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
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


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-02-14 09:21:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:MOmo0lStq6zECA3fM6QX8w


# You can replace this text with custom content, and it will be preserved on regeneration
1;
