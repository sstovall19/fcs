package Fap::Db::Pbxtra::Backend::Result::ServerConfigOption;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("server_config_options");
__PACKAGE__->add_columns(
  "server_config_option_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "active",
  { data_type => "integer", default_value => 1, is_nullable => 0 },
  "creation_date",
  {
    data_type     => "datetime",
    default_value => "0000-00-00 00:00:00",
    is_nullable   => 0,
  },
  "config_option_name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "base_assembly_id",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "required_ram_item_id",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "required_cpu_item_id",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "max_calls",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "max_calls_acd",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "last_changed_by",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "last_changed",
  { data_type => "datetime", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("server_config_option_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-09 08:46:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FmJ//Xy/cs/s7Bl1OOlPvg


# You can replace this text with custom content, and it will be preserved on regeneration
1;


