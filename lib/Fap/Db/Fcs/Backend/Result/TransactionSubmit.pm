package Fap::Db::Fcs::Backend::Result::TransactionSubmit;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("transaction_submit");
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
  "date_entered",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
  "date_to_run",
  {
    data_type     => "timestamp",
    default_value => "0000-00-00 00:00:00",
    is_nullable   => 0,
  },
  "input",
  { data_type => "blob", is_nullable => 1 },
  "status",
  {
    data_type => "enum",
    default_value => "NEW",
    extra => { list => ["NEW", "FAILURE", "RUNNING", "SUCCESS"] },
    is_nullable => 0,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("guid", ["guid"]);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-16 14:51:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:bPuiSTZTLowg8/rzwZnVBA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
