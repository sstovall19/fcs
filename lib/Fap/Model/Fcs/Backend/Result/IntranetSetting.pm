package Fap::Model::Fcs::Backend::Result::IntranetSetting;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("intranet_setting");
__PACKAGE__->add_columns(
  "intranet_setting_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "setting",
  { data_type => "varchar", is_nullable => 0, size => 128 },
  "value",
  { data_type => "varchar", is_nullable => 0, size => 128 },
);
__PACKAGE__->set_primary_key("intranet_setting_id");
__PACKAGE__->add_unique_constraint("setting", ["setting"]);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-01-17 11:54:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ALZCdlthRdsChAoqEaaIkA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
