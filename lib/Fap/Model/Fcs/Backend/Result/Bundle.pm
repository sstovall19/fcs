package Fap::Model::Fcs::Backend::Result::Bundle;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("bundle");
__PACKAGE__->add_columns(
  "bundle_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "display_name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "description",
  { data_type => "mediumtext", is_nullable => 0 },
  "manufacturer",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "model",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "is_inventory",
  {
    data_type => "tinyint",
    default_value => 1,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "category_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "cost_price",
  {
    data_type => "decimal",
    default_value => "0.00",
    is_nullable => 0,
    size => [10, 2],
  },
  "base_price",
  {
    data_type => "decimal",
    default_value => "0.00",
    is_nullable => 0,
    size => [10, 2],
  },
  "mrc_price",
  {
    data_type => "decimal",
    default_value => "0.00",
    is_nullable => 0,
    size => [10, 2],
  },
  "netsuite_order_id",
  { data_type => "bigint", extra => { unsigned => 1 }, is_nullable => 1 },
  "netsuite_one_time_id",
  { data_type => "bigint", extra => { unsigned => 1 }, is_nullable => 1 },
  "netsuite_mrc_id",
  { data_type => "bigint", extra => { unsigned => 1 }, is_nullable => 1 },
  "is_active",
  {
    data_type => "tinyint",
    default_value => 1,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "display_priority",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "order_label_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
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
__PACKAGE__->set_primary_key("bundle_id");
__PACKAGE__->add_unique_constraint("name", ["name"]);
__PACKAGE__->belongs_to(
  "order_label",
  "Fap::Model::Fcs::Backend::Result::OrderLabel",
  { label_id => "order_label_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);
__PACKAGE__->belongs_to(
  "category",
  "Fap::Model::Fcs::Backend::Result::BundleCategory",
  { bundle_category_id => "category_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);
__PACKAGE__->has_many(
  "bundle_discounts",
  "Fap::Model::Fcs::Backend::Result::BundleDiscount",
  { "foreign.bundle_id" => "self.bundle_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "bundle_features",
  "Fap::Model::Fcs::Backend::Result::BundleFeature",
  { "foreign.bundle_id" => "self.bundle_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "bundle_licenses",
  "Fap::Model::Fcs::Backend::Result::BundleLicense",
  { "foreign.bundle_id" => "self.bundle_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->might_have(
  "bundle_packing",
  "Fap::Model::Fcs::Backend::Result::BundlePacking",
  { "foreign.bundle_id" => "self.bundle_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "bundle_price_models",
  "Fap::Model::Fcs::Backend::Result::BundlePriceModel",
  { "foreign.bundle_id" => "self.bundle_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "bundle_relationship_bundles",
  "Fap::Model::Fcs::Backend::Result::BundleRelationship",
  { "foreign.bundle_id" => "self.bundle_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "bundle_relationship_provides_bundles",
  "Fap::Model::Fcs::Backend::Result::BundleRelationship",
  { "foreign.provides_bundle_id" => "self.bundle_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "bundle_relationship_disables_bundles",
  "Fap::Model::Fcs::Backend::Result::BundleRelationship",
  { "foreign.disables_bundle_id" => "self.bundle_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "bundle_relationship_enables_bundles",
  "Fap::Model::Fcs::Backend::Result::BundleRelationship",
  { "foreign.enables_bundle_id" => "self.bundle_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "bundle_relationship_sets_max_bundles",
  "Fap::Model::Fcs::Backend::Result::BundleRelationship",
  { "foreign.sets_max_bundle_id" => "self.bundle_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "bundle_relationship_sets_min_bundles",
  "Fap::Model::Fcs::Backend::Result::BundleRelationship",
  { "foreign.sets_min_bundle_id" => "self.bundle_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "bundle_relationship_requires_bundles",
  "Fap::Model::Fcs::Backend::Result::BundleRelationship",
  { "foreign.requires_bundle_id" => "self.bundle_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "order_bundles",
  "Fap::Model::Fcs::Backend::Result::OrderBundle",
  { "foreign.bundle_id" => "self.bundle_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "order_transaction_items",
  "Fap::Model::Fcs::Backend::Result::OrderTransactionItem",
  { "foreign.bundle_id" => "self.bundle_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "promo_action_bundles",
  "Fap::Model::Fcs::Backend::Result::PromoAction",
  { "foreign.bundle_id" => "self.bundle_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "promo_action_upgrade_bundles",
  "Fap::Model::Fcs::Backend::Result::PromoAction",
  { "foreign.upgrade_bundle_id" => "self.bundle_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "promo_codes",
  "Fap::Model::Fcs::Backend::Result::PromoCode",
  { "foreign.kit_user_bundle_id" => "self.bundle_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "promo_kits",
  "Fap::Model::Fcs::Backend::Result::PromoKit",
  { "foreign.bundle_id" => "self.bundle_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "server_bundles",
  "Fap::Model::Fcs::Backend::Result::ServerBundle",
  { "foreign.bundle_id" => "self.bundle_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-03-14 10:41:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:5doozrkMmZeLWdOacqveEg


sub column_defaults {
   return {
      created=>\'NULL',
   }
}



sub allowed_operations { return {update=>1,delete=>0};}


# You can replace this text with custom content, and it will be preserved on regeneration
1;
