package Fap::Db::Pbxtra::Backend::Result::OrderCategory;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("order_categories");
__PACKAGE__->add_columns(
  "category_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "product_id",
  { data_type => "integer", is_nullable => 0 },
  "category_name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "category_priority",
  { data_type => "integer", is_nullable => 1 },
  "category_description",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);
__PACKAGE__->set_primary_key("category_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-09 08:46:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:I3l00rWFFGgImf+RrD7E1w


# You can replace this text with custom content, and it will be preserved on regeneration
1;


