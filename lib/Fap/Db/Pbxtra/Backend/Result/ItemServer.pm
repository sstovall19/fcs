package Fap::Db::Pbxtra::Backend::Result::ItemServer;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("item_server");
__PACKAGE__->add_columns(
  "item_server_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "item_id",
  { data_type => "integer", is_nullable => 1 },
  "abbreviated_name",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "popup_name",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "img_large",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "img_small",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "features",
  { data_type => "mediumtext", is_nullable => 1 },
  "optional_upgrades_html",
  { data_type => "mediumtext", is_nullable => 1 },
  "max_capacity_html",
  { data_type => "mediumtext", is_nullable => 1 },
  "cards_html",
  { data_type => "mediumtext", is_nullable => 1 },
  "supports_fxs",
  { data_type => "integer", is_nullable => 1 },
  "analog_card_type",
  { data_type => "varchar", is_nullable => 1, size => 4 },
);
__PACKAGE__->set_primary_key("item_server_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-09 08:46:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ypooU6pgR95c2ghBYEM8PA


# You can replace this text with custom content, and it will be preserved on regeneration
1;


