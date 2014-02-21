package Fap::Model::Fcs::Backend::Result::EntityContact;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("entity_contact");
__PACKAGE__->add_columns(
  "entity_contact_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "netsuite_id",
  { data_type => "bigint", extra => { unsigned => 1 }, is_nullable => 1 },
  "role",
  {
    data_type => "enum",
    default_value => "ADMIN",
    extra => { list => ["ADMIN", "TECH", "BILLING"] },
    is_nullable => 0,
  },
  "first_name",
  { data_type => "varchar", is_nullable => 0, size => 80 },
  "last_name",
  { data_type => "varchar", is_nullable => 0, size => 80 },
  "email",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 128 },
  "phone",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 20 },
  "extension",
  { data_type => "integer", is_nullable => 1 },
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
__PACKAGE__->set_primary_key("entity_contact_id");
__PACKAGE__->add_unique_constraint("first_name", ["first_name", "last_name", "email"]);
__PACKAGE__->has_many(
  "customer_contacts",
  "Fap::Model::Fcs::Backend::Result::CustomerContact",
  { "foreign.contact_id" => "self.entity_contact_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "orders",
  "Fap::Model::Fcs::Backend::Result::Order",
  { "foreign.contact_id" => "self.entity_contact_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-02-28 13:35:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:uowVdS9AuUto/4OAFRLJeQ

sub column_defaults {
	return {
        created=>\'NULL',
    };
}

# You can replace this text with custom content, and it will be preserved on regeneration
1;
