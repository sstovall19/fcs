package Fap::Model::Fcs::Backend::Result::ResellerType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("reseller_type");
__PACKAGE__->add_columns(
  "reseller_type_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 80 },
);
__PACKAGE__->set_primary_key("reseller_type_id");
__PACKAGE__->add_unique_constraint("name", ["name"]);
__PACKAGE__->has_many(
  "reseller_discounts",
  "Fap::Model::Fcs::Backend::Result::ResellerDiscount",
  { "foreign.reseller_type_id" => "self.reseller_type_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-02-11 10:54:35
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:YAWiAlvnRBRIFPITIxGDSw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
