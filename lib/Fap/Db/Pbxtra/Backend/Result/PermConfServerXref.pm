package Fap::Db::Pbxtra::Backend::Result::PermConfServerXref;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("perm_conf_server_xref");
__PACKAGE__->add_columns(
  "server_id",
  { data_type => "integer", is_nullable => 1 },
  "extension",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "perm_enum",
  { data_type => "integer", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-09 08:46:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:lc++kYaauj4DK7cCP0wsRQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;


