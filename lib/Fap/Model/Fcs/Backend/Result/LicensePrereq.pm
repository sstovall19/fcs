package Fap::Model::Fcs::Backend::Result::LicensePrereq;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("license_prereq");
__PACKAGE__->add_columns(
  "license_prereq_id",
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
  "prereq_license_type_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
);
__PACKAGE__->set_primary_key("license_prereq_id");
__PACKAGE__->add_unique_constraint(
  "license_type_id",
  ["license_type_id", "prereq_license_type_id"],
);
__PACKAGE__->belongs_to(
  "license_type",
  "Fap::Model::Fcs::Backend::Result::LicenseType",
  { license_type_id => "license_type_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);
__PACKAGE__->belongs_to(
  "prereq_license_type",
  "Fap::Model::Fcs::Backend::Result::LicenseType",
  { license_type_id => "prereq_license_type_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-01-08 15:10:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JSQYuYnonOTNRZuUQzaU5Q

# You can replace this text with custom content, and it will be preserved on regeneration
1;
