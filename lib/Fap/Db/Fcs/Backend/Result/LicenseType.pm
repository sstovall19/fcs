package Fap::Db::Fcs::Backend::Result::LicenseType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("license_type");
__PACKAGE__->add_columns(
  "license_type_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "label",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);
__PACKAGE__->set_primary_key("license_type_id");
__PACKAGE__->has_many(
  "bundle_licenses",
  "Fap::Db::Fcs::Backend::Result::BundleLicense",
  { "foreign.license_type_id" => "self.license_type_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->might_have(
  "hud_license_map",
  "Fap::Db::Fcs::Backend::Result::HudLicenseMap",
  { "foreign.license_type_id" => "self.license_type_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "license_features",
  "Fap::Db::Fcs::Backend::Result::LicenseFeature",
  { "foreign.license_type_id" => "self.license_type_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "roles",
  "Fap::Db::Fcs::Backend::Result::Role",
  { "foreign.license_type_id" => "self.license_type_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "server_licenses",
  "Fap::Db::Fcs::Backend::Result::ServerLicense",
  { "foreign.license_type_id" => "self.license_type_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "user_licenses",
  "Fap::Db::Fcs::Backend::Result::UserLicense",
  { "foreign.license_type_id" => "self.license_type_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-28 09:38:16
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:b1PpavSoYmUKfuYC2pRN3Q


# You can replace this text with custom content, and it will be preserved on regeneration
1;
