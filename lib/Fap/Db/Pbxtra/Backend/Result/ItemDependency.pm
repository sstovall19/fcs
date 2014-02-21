package Fap::Db::Pbxtra::Backend::Result::ItemDependency;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("item_dependency");
__PACKAGE__->add_columns(
  "item_dependency_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "item_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "item_depends_on_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "description",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);
__PACKAGE__->set_primary_key("item_dependency_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-09 08:46:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Bp9qJipCNz4ZfeRTQYQ0VQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;


