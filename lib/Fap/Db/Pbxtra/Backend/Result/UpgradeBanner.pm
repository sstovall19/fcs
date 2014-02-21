package Fap::Db::Pbxtra::Backend::Result::UpgradeBanner;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("upgrade_banners");
__PACKAGE__->add_columns(
  "banner_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "banner_text",
  { data_type => "mediumtext", is_nullable => 1 },
  "before_lockout",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("banner_id", "before_lockout");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-20 09:07:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1MXIj0UstZMBgH3ujG1huA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
