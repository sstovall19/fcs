package Fap::Db::Pbxtra::Backend::Result::DynamicItemXref;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("dynamic_item_xref");
__PACKAGE__->add_columns(
  "item_keyname",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "item_id",
  { data_type => "integer", is_nullable => 0 },
  "creation_date",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
  "changed_by",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);
__PACKAGE__->set_primary_key("item_keyname");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-09 08:46:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rs3vOTEGKw154j46uJZuUg


# You can replace this text with custom content, and it will be preserved on regeneration
1;


