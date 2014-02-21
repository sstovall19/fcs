package Fap::Model::Fcs::Backend::Result::PaymentMethod;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("payment_method");
__PACKAGE__->add_columns(
  "payment_method_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 80 },
);
__PACKAGE__->set_primary_key("payment_method_id");
__PACKAGE__->add_unique_constraint("name", ["name"]);
__PACKAGE__->has_many(
  "billing_schedules",
  "Fap::Model::Fcs::Backend::Result::BillingSchedule",
  { "foreign.payment_method_id" => "self.payment_method_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "order_transactions",
  "Fap::Model::Fcs::Backend::Result::OrderTransaction",
  { "foreign.payment_method_id" => "self.payment_method_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "orders",
  "Fap::Model::Fcs::Backend::Result::Order",
  { "foreign.payment_method_id" => "self.payment_method_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-03-21 08:48:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:toWctu9Gmupwfjf+shXj4Q


# You can replace this text with custom content, and it will be preserved on regeneration
1;
