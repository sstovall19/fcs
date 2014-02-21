package Fap::Model::Fcs::Backend::Result::Role;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

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
    is_nullable => 0,
  },
  "auto_add_user",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "server_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
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
__PACKAGE__->set_primary_key("role_id");
__PACKAGE__->add_unique_constraint("name", ["name", "server_id"]);
__PACKAGE__->belongs_to(
  "license_type",
  "Fap::Model::Fcs::Backend::Result::LicenseType",
  { license_type_id => "license_type_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);
__PACKAGE__->has_many(
  "role_perms",
  "Fap::Model::Fcs::Backend::Result::RolePerm",
  { "foreign.role_id" => "self.role_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "role_tollrestrictions",
  "Fap::Model::Fcs::Backend::Result::RoleTollrestriction",
  { "foreign.role_id" => "self.role_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "user_roles",
  "Fap::Model::Fcs::Backend::Result::UserRole",
  { "foreign.role_id" => "self.role_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-01-17 11:54:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:A7g6O3b7pr9R6hxYlJKEdQ


sub column_defaults {
   return {
      created=>\'NULL',
   }
}



# You can replace this text with custom content, and it will be preserved on regeneration
1;
