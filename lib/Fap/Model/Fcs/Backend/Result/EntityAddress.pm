package Fap::Model::Fcs::Backend::Result::EntityAddress;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("entity_address");
__PACKAGE__->add_columns(
  "entity_address_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "label",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 128 },
  "type",
  {
    data_type => "enum",
    default_value => "SHIPPING",
    extra => { list => ["BILLING", "SHIPPING"] },
    is_nullable => 0,
  },
  "addr1",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 128 },
  "addr2",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 128 },
  "city",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 128 },
  "state_prov",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
  "postal",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 20 },
  "country",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 3 },
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
__PACKAGE__->set_primary_key("entity_address_id");
__PACKAGE__->add_unique_constraint("type", ["type", "addr1", "city", "state_prov", "postal"]);
__PACKAGE__->has_many(
  "customer_addresses",
  "Fap::Model::Fcs::Backend::Result::CustomerAddress",
  { "foreign.address_id" => "self.entity_address_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "entity_credit_cards",
  "Fap::Model::Fcs::Backend::Result::EntityCreditCard",
  { "foreign.billing_address_id" => "self.entity_address_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "order_group_billing_addresses",
  "Fap::Model::Fcs::Backend::Result::OrderGroup",
  { "foreign.billing_address_id" => "self.entity_address_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "order_group_shipping_addresses",
  "Fap::Model::Fcs::Backend::Result::OrderGroup",
  { "foreign.shipping_address_id" => "self.entity_address_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-02-14 09:21:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:4kFx9XJ6VnI8Ms018DcOGA

sub column_defaults {
    return {
        created=>\'NULL',
    };
}



# You can replace this text with custom content, and it will be preserved on regeneration
1;
