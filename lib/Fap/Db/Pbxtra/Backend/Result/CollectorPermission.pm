package Fap::Db::Pbxtra::Backend::Result::CollectorPermission;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("collector_permissions");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "user_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "application",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 28 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-09 08:46:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:6UqXINGGt5wdLUAWlWqVjg


# You can replace this text with custom content, and it will be preserved on regeneration
1;


