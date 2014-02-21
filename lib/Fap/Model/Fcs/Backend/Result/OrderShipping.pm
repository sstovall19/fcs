package Fap::Model::Fcs::Backend::Result::OrderShipping;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("order_shipping");
__PACKAGE__->add_columns(
  "order_shipping_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "order_group_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "shipping_text",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "shipping_rate",
  {
    data_type => "decimal",
    default_value => "0.00",
    is_nullable => 0,
    size => [10, 2],
  },
);
__PACKAGE__->set_primary_key("order_shipping_id");
__PACKAGE__->add_unique_constraint("order_group_id_2", ["order_group_id", "shipping_text"]);
__PACKAGE__->has_many(
  "order_groups",
  "Fap::Model::Fcs::Backend::Result::OrderGroup",
  { "foreign.chosen_shipping_id" => "self.order_shipping_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->belongs_to(
  "order_group",
  "Fap::Model::Fcs::Backend::Result::OrderGroup",
  { order_group_id => "order_group_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-01-08 15:10:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:x7lufLiaXKh/v6qV8PumBQ

# You can replace this text with custom content, and it will be preserved on regeneration
1;
