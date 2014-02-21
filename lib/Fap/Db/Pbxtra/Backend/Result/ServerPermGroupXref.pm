package Fap::Db::Pbxtra::Backend::Result::ServerPermGroupXref;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("server_perm_group_xref");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "server_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "perm_group_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "auto_add_new_user",
  { data_type => "integer", is_nullable => 1 },
  "type",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "group_ext",
  { data_type => "integer", is_nullable => 1 },
  "hud_default",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "department",
  { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-09 08:46:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7WD2x+gQ/UGvZClzSYLHpg


# You can replace this text with custom content, and it will be preserved on regeneration
1;


