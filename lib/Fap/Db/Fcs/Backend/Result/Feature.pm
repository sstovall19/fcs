package Fap::Db::Fcs::Backend::Result::Feature;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("feature");
__PACKAGE__->add_columns(
  "feature_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "description",
  { data_type => "mediumtext", is_nullable => 1 },
  "date_entered",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
);
__PACKAGE__->set_primary_key("feature_id");
__PACKAGE__->has_many(
  "bundle_features",
  "Fap::Db::Fcs::Backend::Result::BundleFeature",
  { "foreign.feature_id" => "self.feature_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "license_features",
  "Fap::Db::Fcs::Backend::Result::LicenseFeature",
  { "foreign.feature_id" => "self.feature_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-14 11:00:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:62HyqFk3ZNw4qlJ5N2pdKQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
