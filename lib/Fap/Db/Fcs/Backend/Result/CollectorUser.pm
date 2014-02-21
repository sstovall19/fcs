package Fap::Db::Fcs::Backend::Result::CollectorUser;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("collector_user");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
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
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->has_many(
  "collector_permissions",
  "Fap::Db::Fcs::Backend::Result::CollectorPermission",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "collector_user_ips",
  "Fap::Db::Fcs::Backend::Result::CollectorUserIp",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-14 13:31:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1NVIpByO3GVIP88gsROKnQ

__PACKAGE__->has_many(permissions=>"Fap::Db::Fcs::Backend::Result::CollectorPermission",{"foreign.user_id"=>"self.id"});
__PACKAGE__->has_many(ip=>"Fap::Db::Fcs::Backend::Result::CollectorUserIp",{"foreign.user_id"=>"self.id"});



# You can replace this text with custom content, and it will be preserved on regeneration
1;
