package Fap::Db::Pbxtra::Backend::Result::VersionItem;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("version_item");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "title",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "body",
  { data_type => "text", is_nullable => 1 },
  "feature",
  { data_type => "char", default_value => 0, is_nullable => 1, size => 1 },
  "tweak",
  { data_type => "char", default_value => 0, is_nullable => 1, size => 1 },
  "bug",
  { data_type => "char", default_value => 0, is_nullable => 1, size => 1 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->has_many(
  "version_history_items",
  "Fap::Db::Pbxtra::Backend::Result::VersionHistoryItem",
  { "foreign.version_item_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-09 08:46:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:SBsO1BxRz/700l985ydMig


# You can replace this text with custom content, and it will be preserved on regeneration
1;


