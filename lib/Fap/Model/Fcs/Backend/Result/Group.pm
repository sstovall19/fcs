package Fap::Model::Fcs::Backend::Result::Group;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("groups");
__PACKAGE__->add_columns(
  "group_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "server_id",
  { data_type => "integer", is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 80 },
  "extension",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "auto_add_user",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "is_department",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
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
__PACKAGE__->set_primary_key("group_id");
__PACKAGE__->add_unique_constraint("server_id", ["server_id", "extension"]);
__PACKAGE__->add_unique_constraint("server_id_2", ["server_id", "name"]);
__PACKAGE__->has_many(
  "group_users",
  "Fap::Model::Fcs::Backend::Result::GroupUser",
  { "foreign.group_id" => "self.group_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "role_perms",
  "Fap::Model::Fcs::Backend::Result::RolePerm",
  { "foreign.group_id" => "self.group_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-01-17 11:54:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:LzoI9Cw+9PSCkSqMdxBdlg


sub column_defaults {
   return {
      created=>\'NULL',
   }
}



# You can replace this text with custom content, and it will be preserved on regeneration
1;
