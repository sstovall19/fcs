package Fap::Db::Pbxtra::Backend::Result::ItemConnectivity;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("item_connectivity");
__PACKAGE__->add_columns(
  "item_connectivity_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "item_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "name_short",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 50 },
);
__PACKAGE__->set_primary_key("item_connectivity_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-09 08:46:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:X5HVSrsEo6j0vPG/lgTrow


# You can replace this text with custom content, and it will be preserved on regeneration
1;


