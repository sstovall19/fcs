package Fap::Db::Pbxtra::Backend::Result::CollectorUser;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("collector_users");
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


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-09 08:46:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:297i8Kw9jxlAjqGt3xLmfQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;


