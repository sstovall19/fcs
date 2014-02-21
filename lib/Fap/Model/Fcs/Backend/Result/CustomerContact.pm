package Fap::Model::Fcs::Backend::Result::CustomerContact;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("customer_contact");
__PACKAGE__->add_columns(
  "customer_contact_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "customer_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "contact_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
);
__PACKAGE__->set_primary_key("customer_contact_id");
__PACKAGE__->add_unique_constraint("customer_id", ["customer_id", "contact_id"]);
__PACKAGE__->belongs_to(
  "contact",
  "Fap::Model::Fcs::Backend::Result::EntityContact",
  { entity_contact_id => "contact_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-02-28 13:35:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+unbSQhIhRusBA6S4z6uvg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
