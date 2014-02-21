package Fap::Db::Fcs::Backend::Result::Role;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("role");
__PACKAGE__->add_columns(
  "role_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "name",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 50 },
  "license_type_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "auto_add_user",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
  "server_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("role_id");
__PACKAGE__->belongs_to(
  "license_type",
  "Fap::Db::Fcs::Backend::Result::LicenseType",
  { license_type_id => "license_type_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-28 09:38:16
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rQYQVjkawogL8hIEflqrsw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
