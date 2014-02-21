package Fap::Db::Fcs::Backend::Result::Bundle;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

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
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "short_description",
  { data_type => "mediumtext", is_nullable => 1 },
  "long_description",
  { data_type => "mediumtext", is_nullable => 1 },
  "type",
  {
    data_type => "enum",
    default_value => "inventory",
    extra => { list => ["inventory", "non-inventory", "phonenumber"] },
    is_nullable => 0,
  },
  "purchase_price",
  {
    data_type => "decimal",
    default_value => "0.00",
    is_nullable => 0,
    size => [10, 2],
  },
  "lease_price",
  {
    data_type => "decimal",
    default_value => "0.00",
    is_nullable => 0,
    size => [10, 2],
  },
  "netsuite_id",
  { data_type => "bigint", extra => { unsigned => 1 }, is_nullable => 1 },
  "netsuite_external_id",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "tax_schedule",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "billsoft_transaction_type",
  { data_type => "integer", is_nullable => 1 },
  "billsoft_service_type",
  { data_type => "integer", is_nullable => 1 },
  "status",
  {
    data_type => "enum",
    default_value => "active",
    extra => { list => ["active", "inactive"] },
    is_nullable => 0,
  },
  "date_entered",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
  "display_priority",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "order_label_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
);
__PACKAGE__->set_primary_key("bundle_id");
__PACKAGE__->belongs_to(
  "order_label",
  "Fap::Db::Fcs::Backend::Result::OrderLabel",
  { label_id => "order_label_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);
__PACKAGE__->has_many(
  "bundle_features",
  "Fap::Db::Fcs::Backend::Result::BundleFeature",
  { "foreign.bundle_id" => "self.bundle_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "bundle_licenses",
  "Fap::Db::Fcs::Backend::Result::BundleLicense",
  { "foreign.bundle_id" => "self.bundle_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->might_have(
  "bundle_packing",
  "Fap::Db::Fcs::Backend::Result::BundlePacking",
  { "foreign.bundle_id" => "self.bundle_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "order_bundles",
  "Fap::Db::Fcs::Backend::Result::OrderBundle",
  { "foreign.bundle_id" => "self.bundle_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "server_bundles",
  "Fap::Db::Fcs::Backend::Result::ServerBundle",
  { "foreign.bundle_id" => "self.bundle_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-29 09:59:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ZuxfwYmZsMgXhSSvY3IHpg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
