package Fap::Model::Fcs::Backend::Result::IntranetPermission;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("intranet_permission");
__PACKAGE__->add_columns(
  "intranet_permission_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 36 },
  "parent_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "description",
  { data_type => "varchar", is_nullable => 0, size => 128 },
  "access",
  { data_type => "varchar", default_value => "r", is_nullable => 0, size => 3 },
);
__PACKAGE__->set_primary_key("intranet_permission_id");
__PACKAGE__->add_unique_constraint("name", ["name"]);
__PACKAGE__->belongs_to(
  "parent",
  "Fap::Model::Fcs::Backend::Result::IntranetPermission",
  { intranet_permission_id => "parent_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);
__PACKAGE__->has_many(
  "intranet_permissions",
  "Fap::Model::Fcs::Backend::Result::IntranetPermission",
  { "foreign.parent_id" => "self.intranet_permission_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "intranet_role_xrefs",
  "Fap::Model::Fcs::Backend::Result::IntranetRoleXref",
  { "foreign.permission_id" => "self.intranet_permission_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "intranet_user_permission_xrefs",
  "Fap::Model::Fcs::Backend::Result::IntranetUserPermissionXref",
  { "foreign.permission_id" => "self.intranet_permission_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-01-08 15:10:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:S51DRYUO+b6e5hWCnXVzcA

# You can replace this text with custom content, and it will be preserved on regeneration
1;
