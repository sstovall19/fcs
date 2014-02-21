package Fap::Model::Fcs::Backend::Result::TransactionStep;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("transaction_step");
__PACKAGE__->add_columns(
  "transaction_step_id",
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
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "objectargs",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "sequence_success",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 8 },
  "sequence_failure",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 8 },
  "objectlocation",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "iterations",
  {
    data_type => "tinyint",
    default_value => 3,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
);
__PACKAGE__->set_primary_key("transaction_step_id");
__PACKAGE__->add_unique_constraint("familyname_2", ["familyname", "sequence_name"]);
__PACKAGE__->has_many(
  "transaction_jobs",
  "Fap::Model::Fcs::Backend::Result::TransactionJob",
  { "foreign.transaction_step_id" => "self.transaction_step_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-02-14 09:21:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:oqlx9AofGOXXcSOGkbtYyQ

# You can replace this text with custom content, and it will be preserved on regeneration
1;
