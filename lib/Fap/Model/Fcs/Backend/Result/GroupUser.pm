package Fap::Model::Fcs::Backend::Result::GroupUser;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("group_user");
__PACKAGE__->add_columns(
  "group_user_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "group_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "user_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("group_user_id");
__PACKAGE__->add_unique_constraint("group_id", ["group_id", "user_id"]);
__PACKAGE__->belongs_to(
  "group",
  "Fap::Model::Fcs::Backend::Result::Group",
  { group_id => "group_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-01-17 11:54:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:lZ+2OxlM7nX21RSA4VMuTQ

# You can replace this text with custom content, and it will be preserved on regeneration
1;
