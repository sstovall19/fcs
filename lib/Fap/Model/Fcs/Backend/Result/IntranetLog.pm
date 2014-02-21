package Fap::Model::Fcs::Backend::Result::IntranetLog;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("intranet_log");
__PACKAGE__->add_columns(
  "intranet_log_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "intranet_user",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 50 },
  "module",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 36 },
  "level",
  {
    data_type => "varchar",
    default_value => "INFO",
    is_nullable => 0,
    size => 16,
  },
  "function",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 128 },
  "message",
  { data_type => "mediumtext", is_nullable => 0 },
  "ip_address",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 45 },
  "updated",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
);
__PACKAGE__->set_primary_key("intranet_log_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-01-17 11:54:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JAEHCNNzdi34ixPlQy8JTA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
