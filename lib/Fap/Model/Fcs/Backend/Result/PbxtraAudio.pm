package Fap::Model::Fcs::Backend::Result::PbxtraAudio;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("pbxtra.audio");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "server_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "filename",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "filesize",
  { data_type => "integer", is_nullable => 1 },
  "comment",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "internal",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("server_id_2", ["server_id", "filename"]);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-02-07 10:08:25
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:6+gFgnIJvU69CllXMeytwA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
