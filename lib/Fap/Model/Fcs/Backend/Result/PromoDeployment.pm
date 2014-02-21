package Fap::Model::Fcs::Backend::Result::PromoDeployment;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("promo_deployment");
__PACKAGE__->add_columns(
  "promo_deployment_id",
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
  "deployment_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
);
__PACKAGE__->set_primary_key("promo_deployment_id");
__PACKAGE__->add_unique_constraint("promo_code_id", ["promo_code_id", "deployment_id"]);
__PACKAGE__->belongs_to(
  "promo_code",
  "Fap::Model::Fcs::Backend::Result::PromoCode",
  { promo_code_id => "promo_code_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);
__PACKAGE__->belongs_to(
  "deployment",
  "Fap::Model::Fcs::Backend::Result::Deployment",
  { deployment_id => "deployment_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-02-14 09:21:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:j+yHo1gMJob4XahxrciQpg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
