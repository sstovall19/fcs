package Fap::Model::Fcs::Backend::Result::NetsuiteSalesperson;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

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
  { data_type => "bigint", extra => { unsigned => 1 }, is_nullable => 0 },
  "intranet_username",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "first_name",
  { data_type => "varchar", is_nullable => 0, size => 80 },
  "last_name",
  { data_type => "varchar", is_nullable => 0, size => 80 },
  "phone",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 20 },
  "email",
  { data_type => "varchar", is_nullable => 0, size => 128 },
  "title",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 128 },
  "can_deduct",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "is_active",
  { data_type => "tinyint", default_value => 1, is_nullable => 0 },
  "extension",
  { data_type => "integer", is_nullable => 1 },
  "created",
  {
    data_type     => "timestamp",
    default_value => "1970-01-01 00:00:00",
    is_nullable   => 0,
  },
  "updated",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
);
__PACKAGE__->set_primary_key("salesperson_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-01-25 16:51:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:5iE5/1Q9bisRLYRo6SMe3Q


sub column_defaults {
   return {
      created=>\'NULL',
   }
}



# You can replace this text with custom content, and it will be preserved on regeneration
1;
