package Fap::Model::Config::Backend::Result::ConfFile;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("conf_files");
__PACKAGE__->add_columns(
  "server_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "filename",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "content",
  { data_type => "longblob", is_nullable => 1 },
  "date_modified",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
);
__PACKAGE__->set_primary_key("server_id", "filename");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-28 09:07:47
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BT2UcITWlRWGXJUM+V+TeQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
