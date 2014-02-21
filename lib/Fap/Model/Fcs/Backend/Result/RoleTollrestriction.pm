package Fap::Model::Fcs::Backend::Result::RoleTollrestriction;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("role_tollrestriction");
__PACKAGE__->add_columns(
  "role_tollrestriction_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "role_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "type",
  {
    data_type => "enum",
    default_value => "DIAL_STRING",
    extra => { list => ["DIAL_STRING", "LINKED_SERVER"] },
    is_nullable => 0,
  },
  "content",
  { data_type => "varchar", is_nullable => 0, size => 80 },
  "updated",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
);
__PACKAGE__->set_primary_key("role_tollrestriction_id");
__PACKAGE__->add_unique_constraint("role_id", ["role_id", "content"]);
__PACKAGE__->belongs_to(
  "role",
  "Fap::Model::Fcs::Backend::Result::Role",
  { role_id => "role_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-02-14 09:21:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:jlfxFs65q36i2xugucyxGw

# You can replace this text with custom content, and it will be preserved on regeneration
1;
