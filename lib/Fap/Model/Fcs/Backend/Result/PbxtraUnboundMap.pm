package Fap::Model::Fcs::Backend::Result::PbxtraUnboundMap;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("pbxtra.unbound_map");
__PACKAGE__->add_columns(
  "unbound_virtual_number",
  { data_type => "varchar", is_nullable => 0, size => 12 },
  "server_id",
  { data_type => "integer", is_nullable => 1 },
  "host",
  { data_type => "integer", is_nullable => 1 },
  "phone_number",
  { data_type => "varchar", default_value => "", is_nullable => 1, size => 50 },
  "device_id",
  { data_type => "integer", is_nullable => 1 },
  "e911_confirmed",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "is_default",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("unbound_virtual_number");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-01-15 09:12:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:mru/1BXH8rwYwBXWoczl8Q


# You can replace this text with custom content, and it will be preserved on regeneration
1;
