package Fap::Model::Fcs::Backend::Result::OrderBundleDetail;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("order_bundle_detail");
__PACKAGE__->add_columns(
  "order_bundle_detail_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "order_bundle_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "extension_number",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "mac_address",
  { data_type => "varchar", is_nullable => 1, size => 12 },
  "did_number",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 20 },
  "desired_did_number",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "is_lnp",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("order_bundle_detail_id");
__PACKAGE__->add_unique_constraint("order_bundle_id", ["order_bundle_id", "extension_number"]);
__PACKAGE__->add_unique_constraint("order_bundle_id_2", ["order_bundle_id", "mac_address"]);
__PACKAGE__->belongs_to(
  "order_bundle",
  "Fap::Model::Fcs::Backend::Result::OrderBundle",
  { order_bundle_id => "order_bundle_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-02-28 13:35:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:F6fMIhHdsBvmu8e6OIik0Q

# You can replace this text with custom content, and it will be preserved on regeneration
1;
