package Fap::Db::Fcs::Backend::Result::ServerBundle;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("server_bundle");
__PACKAGE__->add_columns(
  "server_bundle_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "server_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "bundle_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "date_entered",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
);
__PACKAGE__->set_primary_key("server_bundle_id");
__PACKAGE__->belongs_to(
  "bundle",
  "Fap::Db::Fcs::Backend::Result::Bundle",
  { bundle_id => "bundle_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);
__PACKAGE__->has_many(
	bundle_license => "Fap::Db::Fcs::Backend::Result::BundleLicense",
	{ "foreign.bundle_id" => "self.bundle_id" }
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-09 16:46:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:630KrzF6luHtU1x5W5TFwA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
