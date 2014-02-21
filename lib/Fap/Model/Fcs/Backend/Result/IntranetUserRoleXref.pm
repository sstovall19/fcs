package Fap::Model::Fcs::Backend::Result::IntranetUserRoleXref;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("intranet_user_role_xref");
__PACKAGE__->add_columns(
  "intranet_user_role_xref_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "intranet_user_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "role_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "updated",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
);
__PACKAGE__->set_primary_key("intranet_user_role_xref_id");
__PACKAGE__->add_unique_constraint("intranet_user_id", ["intranet_user_id", "role_id"]);
__PACKAGE__->belongs_to(
  "intranet_user",
  "Fap::Model::Fcs::Backend::Result::IntranetUser",
  { intranet_user_id => "intranet_user_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);
__PACKAGE__->belongs_to(
  "role",
  "Fap::Model::Fcs::Backend::Result::IntranetRole",
  { intranet_role_id => "role_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-01-17 11:54:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:GysIuwwLdA1S0txk3iSE5g


# You can replace this text with custom content, and it will be preserved on regeneration
1;
