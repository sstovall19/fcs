package Fap::Db::Fcs::Backend::Result::BundlePacking;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

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
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "l",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "w",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "h",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "packing",
  {
    data_type => "enum",
    default_value => "needs_box",
    extra => { list => ["filler", "is_boxed", "needs_box"] },
    is_nullable => 0,
  },
);
__PACKAGE__->set_primary_key("bundle_packing_id");
__PACKAGE__->add_unique_constraint("bundle_id", ["bundle_id"]);
__PACKAGE__->belongs_to(
  "bundle",
  "Fap::Db::Fcs::Backend::Result::Bundle",
  { bundle_id => "bundle_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-09 08:45:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:pkTftuiBYDQ1w1pD5KA3Hw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
