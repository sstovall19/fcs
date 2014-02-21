package Fap::Model::Fcs::Backend::Result::TransactionJob;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("transaction_job");
__PACKAGE__->add_columns(
  "transaction_job_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "transaction_submit_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "transaction_step_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "sequence_name",
  { data_type => "varchar", is_nullable => 0, size => 8 },
  "iterations",
  {
    data_type => "tinyint",
    default_value => 3,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "rollback_iterations",
  { data_type => "tinyint", default_value => 3, is_nullable => 0 },
  "input",
  { data_type => "blob", is_nullable => 0 },
  "output",
  { data_type => "blob", is_nullable => 0 },
  "rollback_output",
  { data_type => "blob", is_nullable => 0 },
  "error",
  { data_type => "blob", is_nullable => 0 },
  "rollback_error",
  { data_type => "blob", is_nullable => 0 },
  "status",
  {
    data_type => "enum",
    default_value => "NEW",
    extra => {
      list => [
        "NEW",
        "HALTED",
        "RESTART",
        "FAILURE",
        "ROLLBACK_FAILURE",
        "ROLLBACK_SUCCESS",
        "SUCCESS",
        "RUNNING",
      ],
    },
    is_nullable => 0,
  },
  "execution_time",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "created",
  {
    data_type     => "timestamp",
    default_value => "1970-01-01 00:00:00",
    is_nullable   => 0,
  },
  "updated",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
);
__PACKAGE__->set_primary_key("transaction_job_id");
__PACKAGE__->belongs_to(
  "transaction_submit",
  "Fap::Model::Fcs::Backend::Result::TransactionSubmit",
  { transaction_submit_id => "transaction_submit_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);
__PACKAGE__->belongs_to(
  "transaction_step",
  "Fap::Model::Fcs::Backend::Result::TransactionStep",
  { transaction_step_id => "transaction_step_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-02-14 09:21:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7l7TW0wT4coiHa31WLfSeQ
sub column_defaults {
    return {
        created=>\'NULL',
    };
}


# You can replace this text with custom content, and it will be preserved on regeneration
1;
