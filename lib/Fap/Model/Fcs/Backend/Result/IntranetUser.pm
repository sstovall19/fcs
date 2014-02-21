package Fap::Model::Fcs::Backend::Result::IntranetUser;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("intranet_user");
__PACKAGE__->add_columns(
  "intranet_user_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "username",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "first_name",
  { data_type => "varchar", is_nullable => 0, size => 80 },
  "last_name",
  { data_type => "varchar", is_nullable => 0, size => 80 },
  "email",
  { data_type => "varchar", is_nullable => 0, size => 128 },
  "password",
  { data_type => "varchar", is_nullable => 0, size => 46 },
  "salt",
  { data_type => "varchar", is_nullable => 0, size => 16 },
  "password_updated",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "lockout",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "disabled",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "disabled_date",
  {
    data_type     => "timestamp",
    default_value => "1970-01-01 00:00:00",
    is_nullable   => 0,
  },
  "last_login_ip",
  { data_type => "varchar", is_nullable => 0, size => 45 },
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
__PACKAGE__->set_primary_key("intranet_user_id");
__PACKAGE__->add_unique_constraint("email", ["email"]);
__PACKAGE__->add_unique_constraint("username_2", ["username"]);
__PACKAGE__->has_many(
  "intranet_audits",
  "Fap::Model::Fcs::Backend::Result::IntranetAudit",
  { "foreign.intranet_user_id" => "self.intranet_user_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "intranet_user_permission_xrefs",
  "Fap::Model::Fcs::Backend::Result::IntranetUserPermissionXref",
  { "foreign.intranet_user_id" => "self.intranet_user_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "intranet_user_role_xrefs",
  "Fap::Model::Fcs::Backend::Result::IntranetUserRoleXref",
  { "foreign.intranet_user_id" => "self.intranet_user_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-01-17 11:54:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:6fC1NQ1cK/wk8LczO9LBug


sub column_defaults {
   return {
      created=>\'NULL',
   }
}




# You can replace this text with custom content, and it will be preserved on regeneration
1;
