package Fap::Db::Fcs::Backend::Result::NetsuiteSalesperson;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("netsuite_salesperson");
__PACKAGE__->add_columns(
  "salesperson_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "netsuite_id",
  { data_type => "bigint", extra => { unsigned => 1 }, is_nullable => 1 },
  "intranet_username",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "phone",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "email",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "title",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "can_deduct",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "active",
  { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("salesperson_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-14 11:00:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Lor4lD4V0LlHTbRWlZiJyA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
