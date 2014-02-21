package Fap::Db::Fcs::Backend::Result::EntityContact;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("entity_contact");
__PACKAGE__->add_columns(
  "entity_contact_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "customer_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "role",
  {
    data_type => "enum",
    extra => { list => ["admin", "tech", "billing"] },
    is_nullable => 1,
  },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "email",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "phone",
  { data_type => "varchar", is_nullable => 1, size => 20 },
);
__PACKAGE__->set_primary_key("entity_contact_id");
__PACKAGE__->has_many(
  "order_transactions",
  "Fap::Db::Fcs::Backend::Result::OrderTransaction",
  { "foreign.contact_id" => "self.entity_contact_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "orders",
  "Fap::Db::Fcs::Backend::Result::Order",
  { "foreign.contact_id" => "self.entity_contact_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-16 14:51:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:odbIgDDqFSTrnDs6GALTHw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
