package Fap::Model::Fcs::Backend::Result::IntranetRoleXref;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("intranet_role_xref");
__PACKAGE__->add_columns(
  "intranet_role_xref_id",
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
  "permission_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "access",
  { data_type => "varchar", default_value => "r", is_nullable => 0, size => 3 },
);
__PACKAGE__->set_primary_key("intranet_role_xref_id");
__PACKAGE__->add_unique_constraint("role_id", ["role_id", "permission_id"]);
__PACKAGE__->belongs_to(
  "permission",
  "Fap::Model::Fcs::Backend::Result::IntranetPermission",
  { intranet_permission_id => "permission_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);
__PACKAGE__->belongs_to(
  "role",
  "Fap::Model::Fcs::Backend::Result::IntranetRole",
  { intranet_role_id => "role_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-01-08 15:10:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:VFNGWUj3k39YVBGyByj5GQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
