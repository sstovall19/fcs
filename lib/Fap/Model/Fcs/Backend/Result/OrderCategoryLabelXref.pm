package Fap::Model::Fcs::Backend::Result::OrderCategoryLabelXref;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("order_category_label_xref");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "category_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "label_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("category_id_2", ["category_id", "label_id"]);
__PACKAGE__->belongs_to(
  "category",
  "Fap::Model::Fcs::Backend::Result::OrderCategory",
  { category_id => "category_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);
__PACKAGE__->belongs_to(
  "label",
  "Fap::Model::Fcs::Backend::Result::OrderLabel",
  { label_id => "label_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-01-08 15:10:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:IE55XVHVwcO2QY0dirXuvA

__PACKAGE__->has_one( order_label => "Fap::Model::Fcs::Backend::Result::OrderLabel", { "foreign.label_id" => "self.label_id" } );

# You can replace this text with custom content, and it will be preserved on regeneration
1;
