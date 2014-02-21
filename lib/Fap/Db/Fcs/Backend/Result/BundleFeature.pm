package Fap::Db::Fcs::Backend::Result::BundleFeature;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("bundle_feature");
__PACKAGE__->add_columns(
  "bundle_feature_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "bundle_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "feature_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "date_entered",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
);
__PACKAGE__->set_primary_key("bundle_feature_id");
__PACKAGE__->belongs_to(
  "feature",
  "Fap::Db::Fcs::Backend::Result::Feature",
  { feature_id => "feature_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);
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


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-09 16:46:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ir+dODafbSgdC4YDn3HzSA

__PACKAGE__->has_one(feature=>"Fap::Db::Fcs::Backend::Result::Feature",{"foreign.feature_id"=>"self.feature_id"});



# You can replace this text with custom content, and it will be preserved on regeneration
1;
