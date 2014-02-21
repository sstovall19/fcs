package Fap::Model::Fcs::Backend::Result::LicensePerm;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("license_perm");
__PACKAGE__->add_columns(
  "license_perm_id",
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
  "perm_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "type",
  {
    data_type => "enum",
    default_value => "USER",
    extra => { list => ["USER", "GROUP"] },
    is_nullable => 0,
  },
);
__PACKAGE__->set_primary_key("license_perm_id");
__PACKAGE__->add_unique_constraint("license_type_id", ["license_type_id", "perm_id"]);
__PACKAGE__->belongs_to(
  "license_type",
  "Fap::Model::Fcs::Backend::Result::LicenseType",
  { license_type_id => "license_type_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);
__PACKAGE__->belongs_to(
  "perm",
  "Fap::Model::Fcs::Backend::Result::Perm",
  { perm_id => "perm_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-02-14 09:21:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FaqNXIAT1Xph/44vjdvFhg

# You can replace this text with custom content, and it will be preserved on regeneration
1;
