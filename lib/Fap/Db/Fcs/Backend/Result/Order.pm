package Fap::Db::Fcs::Backend::Result::Order;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("orders");
__PACKAGE__->add_columns(
  "order_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "created",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
  "total_price",
  {
    data_type => "decimal",
    default_value => "0.00",
    is_nullable => 0,
    size => [10, 2],
  },
  "balance",
  {
    data_type => "decimal",
    default_value => "0.00",
    is_nullable => 1,
    size => [10, 2],
  },
  "updated",
  { data_type => "datetime", is_nullable => 1 },
  "reseller_id",
  { data_type => "integer", is_nullable => 1 },
  "customer_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "contact_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "netsuite_lead_id",
  { data_type => "bigint", extra => { unsigned => 1 }, is_nullable => 0 },
  "netsuite_salesperson_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "status",
  {
    data_type => "enum",
    default_value => "NEW",
    extra => { list => ["NEW", "INPROGRESS", "PROVISIONED"] },
    is_nullable => 0,
  },
  "order_type",
  {
    data_type => "enum",
    default_value => "NEW",
    extra => { list => ["NEW", "ADDON"] },
    is_nullable => 0,
  },
  "record_type",
  {
    data_type => "enum",
    default_value => "QUOTE",
    extra => { list => ["QUOTE", "ORDER"] },
    is_nullable => 0,
  },
);
__PACKAGE__->set_primary_key("order_id");
__PACKAGE__->has_many(
  "order_groups",
  "Fap::Db::Fcs::Backend::Result::OrderGroup",
  { "foreign.order_id" => "self.order_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "order_transactions",
  "Fap::Db::Fcs::Backend::Result::OrderTransaction",
  { "foreign.order_id" => "self.order_id" },
  { cascade_copy => 0, cascade_delete => 0 },
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


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-14 11:00:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ElEpw2h7kP8fre1QafRf0g
__PACKAGE__->has_many(order_transaction=>'Fap::Db::Fcs::Backend::Result::OrderTransaction',{'foreign.order_id'=>'self.order_id'});



# You can replace this text with custom content, and it will be preserved on regeneration
1;
