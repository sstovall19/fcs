package Fap::Db::Pbxtra::Backend::Result::OrderConfig;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("order_config");
__PACKAGE__->add_columns(
  "config_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "keyname",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "value",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);
__PACKAGE__->set_primary_key("config_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-09 08:46:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:c3h1uQkZ7n827diy5ISEaA


# You can replace this text with custom content, and it will be preserved on regeneration
1;


