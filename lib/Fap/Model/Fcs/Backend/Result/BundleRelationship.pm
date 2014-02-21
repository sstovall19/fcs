package Fap::Model::Fcs::Backend::Result::BundleRelationship;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("bundle_relationship");
__PACKAGE__->add_columns(
  "bundle_relationship_id",
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
  "product_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "provides_bundle_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "provides_bundle_id_multiplier",
  {
    data_type => "decimal",
    default_value => "0.00",
    is_nullable => 0,
    size => [3, 2],
  },
  "disables_bundle_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "disables_bundle_id_message",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "enables_bundle_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "sets_max_bundle_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "sets_max_bundle_id_multiplier",
  {
    data_type => "decimal",
    default_value => "0.00",
    is_nullable => 0,
    size => [3, 2],
  },
  "sets_min_bundle_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "sets_min_bundle_id_multiplier",
  {
    data_type => "decimal",
    default_value => "0.00",
    is_nullable => 0,
    size => [3, 2],
  },
  "requires_bundle_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "requires_bundle_id_multiplier",
  {
    data_type => "decimal",
    default_value => "0.00",
    is_nullable => 0,
    size => [3, 2],
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
__PACKAGE__->set_primary_key("bundle_relationship_id");
__PACKAGE__->belongs_to(
  "bundle",
  "Fap::Model::Fcs::Backend::Result::Bundle",
  { bundle_id => "bundle_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);
__PACKAGE__->belongs_to(
  "product",
  "Fap::Model::Fcs::Backend::Result::Product",
  { product_id => "product_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);
__PACKAGE__->belongs_to(
  "provides_bundle",
  "Fap::Model::Fcs::Backend::Result::Bundle",
  { bundle_id => "provides_bundle_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);
__PACKAGE__->belongs_to(
  "disables_bundle",
  "Fap::Model::Fcs::Backend::Result::Bundle",
  { bundle_id => "disables_bundle_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);
__PACKAGE__->belongs_to(
  "enables_bundle",
  "Fap::Model::Fcs::Backend::Result::Bundle",
  { bundle_id => "enables_bundle_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);
__PACKAGE__->belongs_to(
  "sets_max_bundle",
  "Fap::Model::Fcs::Backend::Result::Bundle",
  { bundle_id => "sets_max_bundle_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);
__PACKAGE__->belongs_to(
  "sets_min_bundle",
  "Fap::Model::Fcs::Backend::Result::Bundle",
  { bundle_id => "sets_min_bundle_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);
__PACKAGE__->belongs_to(
  "requires_bundle",
  "Fap::Model::Fcs::Backend::Result::Bundle",
  { bundle_id => "requires_bundle_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-01-17 11:54:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rDH9Eu3fE8/94kVJaL01PQ


sub column_defaults {
   return {
      created=>\'NULL',
   }
}



# You can replace this text with custom content, and it will be preserved on regeneration
1;
