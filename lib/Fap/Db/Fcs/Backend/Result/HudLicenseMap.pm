package Fap::Db::Fcs::Backend::Result::HudLicenseMap;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("hud_license_map");
__PACKAGE__->add_columns(
  "hud_license_map_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "license_type_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "hud_fc",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "date_entered",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
);
__PACKAGE__->set_primary_key("hud_license_map_id");
__PACKAGE__->add_unique_constraint("license_type_id", ["license_type_id"]);
__PACKAGE__->belongs_to(
  "license_type",
  "Fap::Db::Fcs::Backend::Result::LicenseType",
  { license_type_id => "license_type_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-29 09:59:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ZJwKgYE0y7u283KAgjnqBQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
