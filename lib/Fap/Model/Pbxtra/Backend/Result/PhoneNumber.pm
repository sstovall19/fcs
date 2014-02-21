package Fap::Model::Pbxtra::Backend::Result::PhoneNumber;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("phone_numbers");
__PACKAGE__->add_columns(
  "server_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "extension",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "number",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 50 },
  "is_primary",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "type",
  {
    data_type => "enum",
    default_value => "voip",
    extra => { list => ["voip", "pstn", "t1", "pots"] },
    is_nullable => 0,
  },
  "description",
  { data_type => "varchar", is_nullable => 1, size => 99 },
  "verif_count",
  { data_type => "integer", is_nullable => 1 },
  "last_verif_attempt",
  { data_type => "datetime", is_nullable => 1 },
  "verified",
  {
    data_type => "enum",
    default_value => "no",
    extra => { list => ["yes", "pending", "no"] },
    is_nullable => 1,
  },
  "e911_confirmed",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "unbound_virtual_number",
  { data_type => "varchar", is_nullable => 1, size => 12 },
);
__PACKAGE__->set_primary_key("server_id", "number");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-01-31 11:22:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Z8CFPjoYj+/xcxowkHF+Fw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
