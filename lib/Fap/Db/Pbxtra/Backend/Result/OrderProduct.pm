package Fap::Db::Pbxtra::Backend::Result::OrderProduct;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("order_products");
__PACKAGE__->add_columns(
  "product_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "netsuite_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "l",
  { data_type => "tinyint", is_nullable => 0 },
  "w",
  { data_type => "tinyint", is_nullable => 0 },
  "h",
  { data_type => "tinyint", is_nullable => 0 },
  "ounces",
  { data_type => "tinyint", is_nullable => 0 },
  "price",
  { data_type => "decimal", is_nullable => 0, size => [10, 2] },
);
__PACKAGE__->set_primary_key("product_id");
__PACKAGE__->add_unique_constraint("netsuite_id", ["netsuite_id"]);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-10-17 14:28:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:A8Wx9Kuf45gTokv5uA/Ykw


# You can replace this text with custom content, and it will be preserved on regeneration
1;


