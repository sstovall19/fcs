package Fap::Model::Pbxtra::Backend::Result::Device;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("devices");
__PACKAGE__->add_columns(
  "device_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "server_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 40 },
  "password",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "description",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "type",
  {
    data_type => "varchar",
    default_value => "none",
    is_nullable => 1,
    size => 20,
  },
  "created",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
  "remotely_provisioned",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "has_sidecar",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "firmware",
  { data_type => "varchar", default_value => "", is_nullable => 1, size => 50 },
  "parent_device_id",
  { data_type => "integer", is_nullable => 1 },
  "ehs",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "label",
  { data_type => "varchar", is_nullable => 1, size => 40 },
  "port",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "is_rented",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("device_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-28 09:09:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:qVRfiSO3uWoArN+hX4JNEA


# You can replace this text with custom content, and it will be preserved on regeneration
__PACKAGE__->has_many(
  "extensions",
  "Fap::Model::Fcs::Backend::Result::PbxtraExtension",
  { "foreign.device_id" => "self.device_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" }
);

1;
