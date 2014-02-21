package Fap::Db::Pbxtra::Backend::Result::BundleDependency;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("bundle_dependencies");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "bundle_id",
  { data_type => "integer", is_nullable => 0 },
  "required_deployment",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "required_version",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "required_product_id",
  { data_type => "integer", is_nullable => 1 },
  "required_edition_id",
  { data_type => "integer", is_nullable => 1 },
  "required_bundle_id",
  { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-10-08 11:13:00
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+KlFke4xc86o2T8yusCu1g


# You can replace this text with custom content, and it will be preserved on regeneration
1;


