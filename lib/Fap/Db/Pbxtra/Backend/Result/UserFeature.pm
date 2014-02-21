package Fap::Db::Pbxtra::Backend::Result::UserFeature;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("user_features");
__PACKAGE__->add_columns(
  "user_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "feature_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "date_entered",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
);
__PACKAGE__->set_primary_key("user_id", "feature_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-10-02 17:35:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:IbXeW0dgvl+wNZ6egIt08Q


# You can replace this text with custom content, and it will be preserved on regeneration
1;


