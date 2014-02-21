package Fap::Model::Fcs::Backend::Result::PromoAction;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("promo_action");
__PACKAGE__->add_columns(
  "promo_action_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "promo_code_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "action",
  {
    data_type => "enum",
    default_value => "BUNDLE_DISCOUNT",
    extra => {
      list => [
        "BUNDLE_BOGO",
        "BUNDLE_DISCOUNT",
        "BUNDLE_UPGRADE",
        "SHIPPING_DISCOUNT",
      ],
    },
    is_nullable => 0,
  },
  "bundle_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "upgrade_bundle_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "discount_type",
  {
    data_type => "enum",
    default_value => "MRC",
    extra => { list => ["ONE_TIME", "MRC", "ALL"] },
    is_nullable => 0,
  },
  "discount_amount",
  {
    data_type => "decimal",
    default_value => "0.00",
    is_nullable => 0,
    size => [10, 2],
  },
  "discount_percent",
  {
    data_type => "decimal",
    default_value => "0.00",
    is_nullable => 0,
    size => [5, 2],
  },
  "discount_months",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "min_quantity",
  {
    data_type => "integer",
    default_value => 1,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "max_quantity",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("promo_action_id");
__PACKAGE__->add_unique_constraint("promo_code_id", ["promo_code_id", "action", "bundle_id"]);
__PACKAGE__->belongs_to(
  "promo_code",
  "Fap::Model::Fcs::Backend::Result::PromoCode",
  { promo_code_id => "promo_code_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);
__PACKAGE__->belongs_to(
  "bundle",
  "Fap::Model::Fcs::Backend::Result::Bundle",
  { bundle_id => "bundle_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);
__PACKAGE__->belongs_to(
  "upgrade_bundle",
  "Fap::Model::Fcs::Backend::Result::Bundle",
  { bundle_id => "upgrade_bundle_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-02-14 09:21:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rCVQ9dDHnJ35s3yz2t63EQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
