package Fap::Db::Pbxtra::Backend::Result::SugarSalesperson;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("sugar_salesperson");
__PACKAGE__->add_columns(
  "salesperson_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "sugar_salesperson_id",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "netsuite_id",
  { data_type => "integer", default_value => 526, is_nullable => 0 },
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


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-09 08:46:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JQiD/EujvjiUYp/k9I349A


# You can replace this text with custom content, and it will be preserved on regeneration
1;


