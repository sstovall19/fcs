package Fap::Db::Pbxtra::Backend::Result::BundleItem;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("bundle_items");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "bundle_id",
  { data_type => "integer", is_nullable => 1 },
  "item_name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "item_description",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "provisioning_type",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-10-08 11:13:00
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:AJLvfcAXHRqKkmipHrmKLg


# You can replace this text with custom content, and it will be preserved on regeneration
1;


