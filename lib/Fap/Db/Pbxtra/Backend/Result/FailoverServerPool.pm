package Fap::Db::Pbxtra::Backend::Result::FailoverServerPool;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("failover_server_pool");
__PACKAGE__->add_columns(
  "server_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "created",
  { data_type => "datetime", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("server_id");
__PACKAGE__->belongs_to(
  "server",
  "Fap::Db::Pbxtra::Backend::Result::Server",
  { server_id => "server_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);
__PACKAGE__->might_have(
  "failover_server",
  "Fap::Db::Pbxtra::Backend::Result::FailoverServer",
  { "foreign.server_id" => "self.server_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-09 08:46:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:DORia1/U6Hh8MQSZ+bo/Kg


# You can replace this text with custom content, and it will be preserved on regeneration
1;


