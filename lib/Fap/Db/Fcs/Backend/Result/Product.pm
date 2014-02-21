package Fap::Db::Fcs::Backend::Result::Product;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("product");
__PACKAGE__->add_columns(
  "product_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "deployment_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "description",
  { data_type => "mediumtext", is_nullable => 1 },
  "date_entered",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
);
__PACKAGE__->set_primary_key("product_id");
__PACKAGE__->has_many(
  "order_categories",
  "Fap::Db::Fcs::Backend::Result::OrderCategory",
  { "foreign.product_id" => "self.product_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "order_groups",
  "Fap::Db::Fcs::Backend::Result::OrderGroup",
  { "foreign.product_id" => "self.product_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->belongs_to(
  "deployment",
  "Fap::Db::Fcs::Backend::Result::Deployment",
  { deployment_id => "deployment_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-16 15:28:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:P+vZhNL2TXZYrrAKJrjzAA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
