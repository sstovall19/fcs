package Fap::Db::Pbxtra::Backend::Result::Bundle;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("bundles");
__PACKAGE__->add_columns(
  "bundle_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "bundle_name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "description",
  { data_type => "mediumtext", is_nullable => 1 },
  "netsuite_id",
  { data_type => "integer", is_nullable => 1 },
  "date_entered",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
  "display_priority",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "order_label_id",
  { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("bundle_id");
__PACKAGE__->has_many(
  "bundle_features",
  "Fap::Db::Pbxtra::Backend::Result::BundleFeature",
  { "foreign.bundle_id" => "self.bundle_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "bundle_licenses",
  "Fap::Db::Pbxtra::Backend::Result::BundleLicense",
  { "foreign.bundle_id" => "self.bundle_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "server_bundles",
  "Fap::Db::Pbxtra::Backend::Result::ServerBundle",
  { "foreign.bundle_id" => "self.bundle_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-09 08:46:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:exfOu1AwrTKy+eICtHWj6g


# You can replace this text with custom content, and it will be preserved on regeneration
1;


