package Fap::Db::Pbxtra::Backend::Result::ServerBundleFeature;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("server_bundle_features");
__PACKAGE__->add_columns(
  "bundle_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "feature_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "date_entered",
  { data_type => "datetime", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("bundle_id", "feature_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-09 08:46:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:w1aE1zt1lwCHUKEdXwO55A


# You can replace this text with custom content, and it will be preserved on regeneration
1;


