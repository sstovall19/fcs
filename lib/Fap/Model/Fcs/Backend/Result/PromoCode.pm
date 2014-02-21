package Fap::Model::Fcs::Backend::Result::PromoCode;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("promo_code");
__PACKAGE__->add_columns(
  "promo_code_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "promo_code",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 80 },
  "description",
  { data_type => "mediumtext", is_nullable => 0 },
  "netsuite_campaign_id",
  { data_type => "bigint", is_nullable => 1 },
  "type",
  {
    data_type => "enum",
    default_value => "promo",
    extra => { list => ["promo", "kit"] },
    is_nullable => 0,
  },
  "start_date",
  {
    data_type     => "timestamp",
    default_value => "1970-01-01 00:00:00",
    is_nullable   => 0,
  },
  "expire_date",
  {
    data_type     => "timestamp",
    default_value => "1970-01-01 00:00:00",
    is_nullable   => 0,
  },
  "is_stackable",
  {
    data_type => "tinyint",
    default_value => 1,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "new_business_only",
  { data_type => "tinyint", default_value => 1, is_nullable => 0 },
  "term_in_months",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "force_prepay",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "prepay_percent",
  {
    data_type => "decimal",
    default_value => "0.00",
    is_nullable => 0,
    size => [5, 2],
  },
  "min_users",
  {
    data_type => "integer",
    default_value => 1,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "max_users",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "kit_user_bundle_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "one_time_price",
  {
    data_type => "decimal",
    default_value => "0.00",
    is_nullable => 0,
    size => [10, 2],
  },
  "mrc_price",
  {
    data_type => "decimal",
    default_value => "0.00",
    is_nullable => 0,
    size => [10, 2],
  },
  "created",
  {
    data_type     => "timestamp",
    default_value => "1970-01-01 00:00:00",
    is_nullable   => 0,
  },
  "updated",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
);
__PACKAGE__->set_primary_key("promo_code_id");
__PACKAGE__->add_unique_constraint("promo_code", ["promo_code"]);
__PACKAGE__->has_many(
  "order_discounts",
  "Fap::Model::Fcs::Backend::Result::OrderDiscount",
  { "foreign.promo_code_id" => "self.promo_code_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "promo_actions",
  "Fap::Model::Fcs::Backend::Result::PromoAction",
  { "foreign.promo_code_id" => "self.promo_code_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->belongs_to(
  "kit_user_bundle",
  "Fap::Model::Fcs::Backend::Result::Bundle",
  { bundle_id => "kit_user_bundle_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);
__PACKAGE__->has_many(
  "promo_deployments",
  "Fap::Model::Fcs::Backend::Result::PromoDeployment",
  { "foreign.promo_code_id" => "self.promo_code_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "promo_kits",
  "Fap::Model::Fcs::Backend::Result::PromoKit",
  { "foreign.promo_code_id" => "self.promo_code_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "promo_roles",
  "Fap::Model::Fcs::Backend::Result::PromoRole",
  { "foreign.promo_code_id" => "self.promo_code_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-02-14 09:21:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:HURJeBoAP/a8NICRcY0RQg

sub column_defaults {
    return {
        created=>\'NULL',
    }
}


# You can replace this text with custom content, and it will be preserved on regeneration
1;
