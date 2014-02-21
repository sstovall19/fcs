package Fap::Model::Fcs::Backend::Result::RolePerm;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("role_perm");
__PACKAGE__->add_columns(
  "role_perm_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "role_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "perm_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "type",
  {
    data_type => "enum",
    default_value => "USER",
    extra => { list => ["USER", "GROUP", "HUD_CONF"] },
    is_nullable => 0,
  },
  "group_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "conference_no",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "conference_server_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "updated",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
);
__PACKAGE__->set_primary_key("role_perm_id");
__PACKAGE__->belongs_to(
  "role",
  "Fap::Model::Fcs::Backend::Result::Role",
  { role_id => "role_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);
__PACKAGE__->belongs_to(
  "group",
  "Fap::Model::Fcs::Backend::Result::Group",
  { group_id => "group_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);
__PACKAGE__->belongs_to(
  "perm",
  "Fap::Model::Fcs::Backend::Result::Perm",
  { perm_id => "perm_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-02-14 09:21:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Uk8uKGIVl6W4DH23LJCBew

# You can replace this text with custom content, and it will be preserved on regeneration
1;
