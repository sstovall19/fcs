package Fap::Db::Fcs::Backend::Result::OrderBundleDetail;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("order_bundle_detail");
__PACKAGE__->add_columns(
  "order_bundle_detail_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "order_bundle_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "extension_number",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "did_number",
  { data_type => "varchar", is_nullable => 1, size => 15 },
  "lnp",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("order_bundle_detail_id");
__PACKAGE__->belongs_to(
  "order_bundle",
  "Fap::Db::Fcs::Backend::Result::OrderBundle",
  { order_bundle_id => "order_bundle_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-09 08:45:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:csh4TctlNvWGREsOOJ61EA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
