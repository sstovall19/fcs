package Fap::Db::Pbxtra::Backend::Result::UserLicense;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("user_licenses");
__PACKAGE__->add_columns(
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "license_key",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 20 },
  "date_entered",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
);
__PACKAGE__->set_primary_key("user_id", "license_key");
__PACKAGE__->belongs_to(
  "user",
  "Fap::Db::Pbxtra::Backend::Result::User",
  { user_id => "user_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-09 08:46:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:iAi/lSAgPz8I4Kq8WVKG4g


# You can replace this text with custom content, and it will be preserved on regeneration
1;


