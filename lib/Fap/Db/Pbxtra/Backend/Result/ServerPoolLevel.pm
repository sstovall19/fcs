package Fap::Db::Pbxtra::Backend::Result::ServerPoolLevel;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("server_pool_levels");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "deployment",
  {
    data_type => "enum",
    default_value => "multitenant",
    extra => { list => ["dedicated", "multitenant"] },
    is_nullable => 0,
  },
  "location",
  { data_type => "varchar", default_value => "LA", is_nullable => 0, size => 50 },
  "minimum_depth",
  { data_type => "integer", default_value => 10, is_nullable => 0 },
  "maximum_depth_per_host",
  { data_type => "integer", default_value => 10, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-09 08:46:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/TzJt31D7+m7W97N4+QfCA


# You can replace this text with custom content, and it will be preserved on regeneration
1;


