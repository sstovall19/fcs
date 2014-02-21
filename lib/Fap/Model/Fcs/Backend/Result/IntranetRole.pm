package Fap::Model::Fcs::Backend::Result::IntranetRole;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("intranet_role");
__PACKAGE__->add_columns(
  "intranet_role_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "description",
  { data_type => "mediumtext", is_nullable => 0 },
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
__PACKAGE__->set_primary_key("intranet_role_id");
__PACKAGE__->add_unique_constraint("name", ["name"]);
__PACKAGE__->has_many(
  "intranet_role_xrefs",
  "Fap::Model::Fcs::Backend::Result::IntranetRoleXref",
  { "foreign.role_id" => "self.intranet_role_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "intranet_user_role_xrefs",
  "Fap::Model::Fcs::Backend::Result::IntranetUserRoleXref",
  { "foreign.role_id" => "self.intranet_role_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "promo_roles",
  "Fap::Model::Fcs::Backend::Result::PromoRole",
  { "foreign.intranet_role_id" => "self.intranet_role_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-02-14 09:21:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:NniHItcHDRnpTuU1rsMxxQ


sub column_defaults {
   return {
      created=>\'NULL',
   }
}




# You can replace this text with custom content, and it will be preserved on regeneration
1;
