package Fap::Db::Fcs::Backend::Result::CollectorPermission;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("collector_permission");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "application",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 28 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to(
  "user",
  "Fap::Db::Fcs::Backend::Result::CollectorUser",
  { id => "user_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-14 13:31:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8/3Bq5/yhThlFaMoEIOmXw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
