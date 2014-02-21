package Fap::Db::Pbxtra::Backend::Result::ItemPhone;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("item_phone");
__PACKAGE__->add_columns(
  "item_phone_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "item_id",
  { data_type => "integer", is_nullable => 1 },
  "popup_name",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "img_large",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "img_small",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "img_small2",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "headset",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "telecommute",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "comments",
  { data_type => "mediumtext", is_nullable => 1 },
  "features1_html",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "features2_html",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "call_appearances",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "lcd_size",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "speakerphone_quality",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "paging_intercom",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "blf",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "ethernet",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "built_in_poe",
  { data_type => "varchar", is_nullable => 1, size => 100 },
);
__PACKAGE__->set_primary_key("item_phone_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-09 08:46:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JCGnrq2eXEtWEn4Vj4ASfg


# You can replace this text with custom content, and it will be preserved on regeneration
1;


