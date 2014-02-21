package Fap::Model::Fcs::Backend::Result::DiscountType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("discount_type");
__PACKAGE__->add_columns(
  "discount_type_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 50 },
);
__PACKAGE__->set_primary_key("discount_type_id");
__PACKAGE__->add_unique_constraint("name_3", ["name"]);
__PACKAGE__->has_many(
  "order_discounts",
  "Fap::Model::Fcs::Backend::Result::OrderDiscount",
  { "foreign.discount_type_id" => "self.discount_type_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "reseller_discounts",
  "Fap::Model::Fcs::Backend::Result::ResellerDiscount",
  { "foreign.discount_type_id" => "self.discount_type_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-03-05 12:23:33
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:C2CLEDB2rjLJ14u7H/P7Ng


# You can replace this text with custom content, and it will be preserved on regeneration
1;
