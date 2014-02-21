package Fap::Db::Fcs::Backend::Result::Deployment;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("deployment");
__PACKAGE__->add_columns(
  "deployment_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "description",
  { data_type => "mediumtext", is_nullable => 1 },
  "date_entered",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
  "is_hosted",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
);
__PACKAGE__->set_primary_key("deployment_id");
__PACKAGE__->has_many(
  "products",
  "Fap::Db::Fcs::Backend::Result::Product",
  { "foreign.deployment_id" => "self.deployment_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-12 12:50:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ETJftv73Rmyr46qNcnBY+w


# You can replace this text with custom content, and it will be preserved on regeneration
1;
