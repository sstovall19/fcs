package Fap::Db::Pbxtra::Backend::Result::UpgradeMasterComponentHelpText;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("upgrade_master_component_help_text");
__PACKAGE__->add_columns(
  "help_text_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "help_text",
  { data_type => "mediumtext", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("help_text_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-20 09:07:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:dXkHUFvm9a6nyJJGE/pRrQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
