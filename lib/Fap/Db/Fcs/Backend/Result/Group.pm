package Fap::Db::Fcs::Backend::Result::Group;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

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
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "name",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 50 },
  "extension",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "auto_add_user",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
  "is_department",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("group_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-28 09:38:16
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:m4CPyD2tIOTjEMd0RE3kMQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
