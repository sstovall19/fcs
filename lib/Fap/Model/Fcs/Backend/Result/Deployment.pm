package Fap::Model::Fcs::Backend::Result::Deployment;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("deployment");
__PACKAGE__->add_columns(
  "deployment_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 80 },
  "description",
  { data_type => "mediumtext", is_nullable => 0 },
  "is_hosted",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
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
__PACKAGE__->set_primary_key("deployment_id");
__PACKAGE__->add_unique_constraint("name", ["name"]);
__PACKAGE__->might_have(
  "product",
  "Fap::Model::Fcs::Backend::Result::Product",
  { "foreign.deployment_id" => "self.deployment_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "promo_deployments",
  "Fap::Model::Fcs::Backend::Result::PromoDeployment",
  { "foreign.deployment_id" => "self.deployment_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-02-14 09:21:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:wtBzmdA+vov7FKr8cWtfog


sub column_defaults {
   return {
      created=>\'NULL',
   }
}



# You can replace this text with custom content, and it will be preserved on regeneration
1;
