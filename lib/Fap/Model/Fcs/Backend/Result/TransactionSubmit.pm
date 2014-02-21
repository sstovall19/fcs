package Fap::Model::Fcs::Backend::Result::TransactionSubmit;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("transaction_submit");
__PACKAGE__->add_columns(
  "transaction_submit_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "familyname",
  { data_type => "varchar", is_nullable => 0, size => 16 },
  "input",
  { data_type => "blob", is_nullable => 0 },
  "status",
  {
    data_type => "enum",
    default_value => "NEW",
    extra => { list => ["NEW", "FAILURE", "RUNNING", "SUCCESS", "HALTED"] },
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
__PACKAGE__->set_primary_key("transaction_submit_id");
__PACKAGE__->has_many(
  "orders",
  "Fap::Model::Fcs::Backend::Result::Order",
  { "foreign.transaction_submit_id" => "self.transaction_submit_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "transaction_jobs",
  "Fap::Model::Fcs::Backend::Result::TransactionJob",
  { "foreign.transaction_submit_id" => "self.transaction_submit_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-02-22 10:07:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:PUyoUpasMD1JmVDgrqJXtg

__PACKAGE__->has_many("jobs"=>"Fap::Model::Fcs::Backend::Result::TransactionJob",{"foreign.guid"=>"self.guid"},{on_delete=>"CASCADE"});



sub column_defaults {
   return {
      created=>\'NULL',
   }
}



# You can replace this text with custom content, and it will be preserved on regeneration
1;
