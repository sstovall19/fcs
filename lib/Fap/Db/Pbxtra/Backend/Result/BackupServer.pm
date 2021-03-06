package Fap::Db::Pbxtra::Backend::Result::BackupServer;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("backup_servers");
__PACKAGE__->add_columns(
  "server_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "isa",
  { data_type => "integer", is_nullable => 1 },
  "hasa",
  { data_type => "integer", is_nullable => 1 },
  "original_main",
  { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("server_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-07 14:40:55
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:NS0GCU/SNdrwTEqXfx1GIA


# You can replace this text with custom content, and it will be preserved on regeneration
1;


