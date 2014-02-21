package Fap::Model::Fcs::Backend::Result::PbxtraCid;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("pbxtra.cid");
__PACKAGE__->add_columns(
  "server_id",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
  "extension",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "cid",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "cidname",
  { data_type => "varchar", is_nullable => 1, size => 32 },
);
__PACKAGE__->set_primary_key("server_id", "extension");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-01-31 11:22:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:H632Hq/Uh1vGXIKBXMSlxQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
