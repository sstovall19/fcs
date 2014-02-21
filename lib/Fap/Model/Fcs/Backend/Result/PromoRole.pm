package Fap::Model::Fcs::Backend::Result::PromoRole;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("promo_role");
__PACKAGE__->add_columns(
  "promo_role_id",
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
  "intranet_role_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
);
__PACKAGE__->set_primary_key("promo_role_id");
__PACKAGE__->add_unique_constraint("promo_code_id", ["promo_code_id", "intranet_role_id"]);
__PACKAGE__->belongs_to(
  "promo_code",
  "Fap::Model::Fcs::Backend::Result::PromoCode",
  { promo_code_id => "promo_code_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);
__PACKAGE__->belongs_to(
  "intranet_role",
  "Fap::Model::Fcs::Backend::Result::IntranetRole",
  { intranet_role_id => "intranet_role_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-02-14 09:21:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:VKCLzGSwPVjpZz1FvKRJ4g


# You can replace this text with custom content, and it will be preserved on regeneration
1;
