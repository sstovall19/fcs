package Fap::Model::Fcs::Backend::Result::Perm;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("perm");
__PACKAGE__->add_columns(
  "perm_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "name",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "code",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 50 },
  "cp_version",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 20 },
  "feature_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
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
__PACKAGE__->set_primary_key("perm_id");
__PACKAGE__->add_unique_constraint("name", ["name"]);
__PACKAGE__->add_unique_constraint("code", ["code"]);
__PACKAGE__->has_many(
  "license_perms",
  "Fap::Model::Fcs::Backend::Result::LicensePerm",
  { "foreign.perm_id" => "self.perm_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->belongs_to(
  "feature",
  "Fap::Model::Fcs::Backend::Result::Feature",
  { feature_id => "feature_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);
__PACKAGE__->has_many(
  "role_perms",
  "Fap::Model::Fcs::Backend::Result::RolePerm",
  { "foreign.perm_id" => "self.perm_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-01-17 11:54:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:LjiFQVlhPBTYfaXC9vd3qA


sub column_defaults {
   return {
      created=>\'NULL',
   }
}



# You can replace this text with custom content, and it will be preserved on regeneration
1;
