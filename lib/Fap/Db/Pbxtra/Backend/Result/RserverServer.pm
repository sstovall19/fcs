package Fap::Db::Pbxtra::Backend::Result::RserverServer;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("rserver_server");
__PACKAGE__->add_columns(
  "rserver_id",
  { data_type => "integer", is_nullable => 0 },
  "server_id",
  { data_type => "integer", is_nullable => 0 },
);
__PACKAGE__->add_unique_constraint("server_id", ["server_id"]);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-09 08:46:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:DY8rkH9LrGYBwhyjsqmI2g


# You can replace this text with custom content, and it will be preserved on regeneration
1;


