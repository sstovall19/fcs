package Fap::Model::Fcs::Backend::Result::CollectorUser;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("collector_user");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "username",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "first_name",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 36 },
  "last_name",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 36 },
  "email",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 64 },
  "api_key",
  { data_type => "varchar", is_nullable => 0, size => 46 },
  "salt",
  { data_type => "varchar", is_nullable => 0, size => 16 },
  "api_key_updated",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "lockout",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "last_login_ip",
  { data_type => "varchar", is_nullable => 0, size => 39 },
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
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("email", ["email"]);
__PACKAGE__->add_unique_constraint("username_2", ["username"]);
__PACKAGE__->has_many(
  "collector_permissions",
  "Fap::Model::Fcs::Backend::Result::CollectorPermission",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "collector_user_ips",
  "Fap::Model::Fcs::Backend::Result::CollectorUserIp",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-01-17 11:54:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:WBLoWh/dKLy/z2gd+Y27Zw


sub column_defaults {
   return {
      created=>\'NULL',
   }
}



__PACKAGE__->has_many( permissions => "Fap::Model::Fcs::Backend::Result::CollectorPermission", { "foreign.user_id" => "self.id" } );
__PACKAGE__->has_many( ip          => "Fap::Model::Fcs::Backend::Result::CollectorUserIp",     { "foreign.user_id" => "self.id" } );

# You can replace this text with custom content, and it will be preserved on regeneration
1;
