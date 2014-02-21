package Fap::Db::Fcs::Backend::Result::ShippingType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("shipping_type");
__PACKAGE__->add_columns(
  "shipping_type_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "label",
  { data_type => "varchar", is_nullable => 1, size => 23 },
  "active",
  { data_type => "tinyint", default_value => 1, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("shipping_type_id");
__PACKAGE__->has_many(
  "order_groups",
  "Fap::Db::Fcs::Backend::Result::OrderGroup",
  { "foreign.shipping_type_id" => "self.shipping_type_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-13 10:37:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:XCOIeiT27VfE792wIjnK2g


# You can replace this text with custom content, and it will be preserved on regeneration
1;
