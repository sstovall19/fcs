package Fap::Db::Fcs::Backend::Result::SmRegistry;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("sm_registry");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "familyname",
  { data_type => "varchar", is_nullable => 0, size => 16 },
  "sm_host",
  { data_type => "varchar", is_nullable => 0, size => 115 },
  "sm_pid",
  { data_type => "integer", is_nullable => 0 },
  "guid",
  { data_type => "varchar", is_nullable => 0, size => 36 },
  "objectname",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "object_message",
  { data_type => "text", is_nullable => 0 },
  "create_date",
  { data_type => "datetime", is_nullable => 0 },
  "last_update",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
  "port",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-13 12:20:37
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Pvk5tjRlgGOB01/EQXtMBg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
