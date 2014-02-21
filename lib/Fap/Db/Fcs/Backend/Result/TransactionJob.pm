package Fap::Db::Fcs::Backend::Result::TransactionJob;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("transaction_job");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "guid",
  { data_type => "varchar", is_nullable => 0, size => 36 },
  "familyname",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "sequence_name",
  { data_type => "varchar", is_nullable => 1, size => 8 },
  "iterations",
  {
    data_type => "tinyint",
    default_value => 3,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "input",
  { data_type => "blob", is_nullable => 1 },
  "output",
  { data_type => "blob", is_nullable => 1 },
  "error",
  { data_type => "blob", is_nullable => 1 },
  "status",
  {
    data_type => "enum",
    default_value => "NEW",
    extra => {
      list => [
        "NEW",
        "PAUSED",
        "FAILURE",
        "ROLLBACK_FAILURE",
        "ROLLBACK_SUCCESS",
        "SUCCESS",
        "RUNNING",
      ],
    },
    is_nullable => 0,
  },
  "queue_time",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
  "start_time",
  {
    data_type     => "timestamp",
    default_value => "0000-00-00 00:00:00",
    is_nullable   => 0,
  },
  "end_time",
  {
    data_type     => "timestamp",
    default_value => "0000-00-00 00:00:00",
    is_nullable   => 0,
  },
  "sequence_success",
  { data_type => "varchar", is_nullable => 1, size => 8 },
  "sequence_failure",
  { data_type => "varchar", is_nullable => 1, size => 8 },
  "objectname",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "objectargs",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "rollback_output",
  { data_type => "blob", is_nullable => 1 },
  "rollback_error",
  { data_type => "blob", is_nullable => 1 },
  "rollback_iterations",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "objectlocation",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("UN_GUID_SEQ", ["guid", "sequence_name"]);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-16 14:51:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:drRPdZrvTXLcUn9FQqu8HA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
