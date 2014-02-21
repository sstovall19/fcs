package Fap::Model::Fcs::Backend::Result::BundlePacking;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("bundle_packing");
__PACKAGE__->add_columns(
  "bundle_packing_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "bundle_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "ounces",
  { data_type => "decimal", is_nullable => 0, size => [6, 2] },
  "l",
  { data_type => "decimal", is_nullable => 0, size => [6, 2] },
  "w",
  { data_type => "decimal", is_nullable => 0, size => [6, 2] },
  "h",
  { data_type => "decimal", is_nullable => 0, size => [6, 2] },
  "packing",
  {
    data_type => "enum",
    default_value => "NEEDS_BOX",
    extra => { list => ["FILLER", "IS_BOXED", "NEEDS_BOX"] },
    is_nullable => 0,
  },
  "created",
  {
    data_type     => "timestamp",
    default_value => "1970-01-01 00:00:00",
    is_nullable   => 0,
  },
  "updated",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
);
__PACKAGE__->set_primary_key("bundle_packing_id");
__PACKAGE__->add_unique_constraint("bundle_id", ["bundle_id"]);
__PACKAGE__->belongs_to(
  "bundle",
  "Fap::Model::Fcs::Backend::Result::Bundle",
  { bundle_id => "bundle_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-02-14 09:21:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:6eIAegwLz4Y6KoY+788quA


sub column_defaults {
   return {
      created=>\'NULL',
   }
}



# You can replace this text with custom content, and it will be preserved on regeneration
1;
