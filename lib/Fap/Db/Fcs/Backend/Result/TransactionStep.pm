package Fap::Db::Fcs::Backend::Result::TransactionStep;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("transaction_step");
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
  "sequence_name",
  { data_type => "varchar", is_nullable => 0, size => 8 },
  "objectname",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "objectargs",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "sequence_success",
  { data_type => "varchar", is_nullable => 1, size => 8 },
  "sequence_failure",
  { data_type => "varchar", is_nullable => 1, size => 8 },
  "objectlocation",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "iterations",
  {
    data_type => "tinyint",
    default_value => 3,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("familyname_2", ["familyname", "sequence_name"]);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-29 09:59:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:QPn2kyyhDjFpyqyBUWzk/w


# You can replace this text with custom content, and it will be preserved on regeneration
1;
