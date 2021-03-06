package Fap::Db::Pbxtra::Backend::Result::ServerFeature;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("server_features");
__PACKAGE__->add_columns(
  "server_id",
  { data_type => "integer", is_nullable => 0 },
  "feature",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "description",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);
__PACKAGE__->set_primary_key("server_id", "feature");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-09 08:46:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:w3gw7TeZmRWqxMBOIAjo5A


# You can replace this text with custom content, and it will be preserved on regeneration
1;


