package Fap::Db::Fcs::Backend::Result::OrderBox;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("order_box");
__PACKAGE__->add_columns(
  "box_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "internal_l",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "internal_w",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "internal_h",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "external_l",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "external_w",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "external_h",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "ounces",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("box_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-10-30 16:03:47
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ERccS3BDxeyGSJcBHE0tfQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
