package Fap::Db::Pbxtra::Backend::Result::Auth2user;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("auth2user");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "user_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "auth",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "created",
  { data_type => "datetime", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("auth", ["auth"]);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-07 14:40:55
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:H6PFTWe5aGr2qZzMY76pYg


# You can replace this text with custom content, and it will be preserved on regeneration
1;


