package Fap::Db::Fcs::Backend::Result::OrderBundle;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("order_bundle");
__PACKAGE__->add_columns(
  "order_bundle_id",
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
  "order_group_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "quantity",
  { data_type => "integer", default_value => 1, is_nullable => 1 },
  "list_price",
  {
    data_type => "decimal",
    default_value => "0.00",
    is_nullable => 0,
    size => [10, 2],
  },
  "unit_price",
  {
    data_type => "decimal",
    default_value => "0.00",
    is_nullable => 0,
    size => [10, 2],
  },
  "total_price",
  {
    data_type => "decimal",
    default_value => "0.00",
    is_nullable => 0,
    size => [10, 2],
  },
);
__PACKAGE__->set_primary_key("order_bundle_id");
__PACKAGE__->belongs_to(
  "bundle",
  "Fap::Db::Fcs::Backend::Result::Bundle",
  { bundle_id => "bundle_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);
__PACKAGE__->belongs_to(
  "order_group",
  "Fap::Db::Fcs::Backend::Result::OrderGroup",
  { order_group_id => "order_group_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);
__PACKAGE__->has_many(
  "order_bundle_details",
  "Fap::Db::Fcs::Backend::Result::OrderBundleDetail",
  { "foreign.order_bundle_id" => "self.order_bundle_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-13 10:37:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+mtp+2v5wn7ruNmhpbJLKg

__PACKAGE__->has_one(bundle=>'Fap::Db::Fcs::Backend::Result::Bundle',{'foreign.bundle_id'=>'self.bundle_id'});
__PACKAGE__->has_many(detail=>'Fap::Db::Fcs::Backend::Result::OrderBundleDetail',{'foreign.order_bundle_id'=>'self.order_bundle_id'});





# You can replace this text with custom content, and it will be preserved on regeneration
1;
