package Fap::Model::Pbxtra::Backend::Result::ServerBundle;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("server_bundles");
__PACKAGE__->add_columns(
  "server_id",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "bundle_id",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "date_entered",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
);
__PACKAGE__->set_primary_key("server_id", "bundle_id");
__PACKAGE__->belongs_to(
  "server",
  "Fap::Model::Pbxtra::Backend::Result::Server",
  { server_id => "server_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-21 10:52:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JWaCwA2P3gudX3imC1li8g

# You can replace this text with custom content, and it will be preserved on regeneration
1;
