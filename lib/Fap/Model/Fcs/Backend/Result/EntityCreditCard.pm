package Fap::Model::Fcs::Backend::Result::EntityCreditCard;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("entity_credit_card");
__PACKAGE__->add_columns(
  "entity_credit_card_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "customer_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "billing_address_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "netsuite_card_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "cardholder_name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "first_four",
  { data_type => "char", is_nullable => 1, size => 4 },
  "last_four",
  { data_type => "char", is_nullable => 1, size => 4 },
  "expiration_month",
  { data_type => "tinyint", is_nullable => 1 },
  "expiration_year",
  { data_type => "smallint", is_nullable => 1 },
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
__PACKAGE__->set_primary_key("entity_credit_card_id");
__PACKAGE__->add_unique_constraint("customer_id", ["customer_id", "netsuite_card_id"]);
__PACKAGE__->has_many(
  "billing_schedules",
  "Fap::Model::Fcs::Backend::Result::BillingSchedule",
  { "foreign.credit_card_id" => "self.entity_credit_card_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->belongs_to(
  "billing_address",
  "Fap::Model::Fcs::Backend::Result::EntityAddress",
  { entity_address_id => "billing_address_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);
__PACKAGE__->has_many(
  "order_transactions",
  "Fap::Model::Fcs::Backend::Result::OrderTransaction",
  { "foreign.credit_card_id" => "self.entity_credit_card_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "orders",
  "Fap::Model::Fcs::Backend::Result::Order",
  { "foreign.credit_card_id" => "self.entity_credit_card_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-02-22 10:07:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ePhovs5ZpeZ9+k8y1wtceg

sub column_defaults {
   return {
      created=>\'NULL',
   }
}

# You can replace this text with custom content, and it will be preserved on regeneration
1;
