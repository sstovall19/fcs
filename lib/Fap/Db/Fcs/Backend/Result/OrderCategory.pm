package Fap::Db::Fcs::Backend::Result::OrderCategory;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("order_category");
__PACKAGE__->add_columns(
  "category_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "description",
  { data_type => "mediumtext", is_nullable => 1 },
  "priority",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "display_type",
  { data_type => "varchar", default_value => "", is_nullable => 1, size => 128 },
  "product_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
);
__PACKAGE__->set_primary_key("category_id");
__PACKAGE__->belongs_to(
  "product",
  "Fap::Db::Fcs::Backend::Result::Product",
  { product_id => "product_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);
__PACKAGE__->has_many(
  "order_category_label_xrefs",
  "Fap::Db::Fcs::Backend::Result::OrderCategoryLabelXref",
  { "foreign.category_id" => "self.category_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-15 16:49:38
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:kX9z4OTrafcqyqF/DifgCw

__PACKAGE__->has_many(label_xref=>"Fap::Db::Fcs::Backend::Result::OrderCategoryLabelXref",{"foreign.category_id"=>"self.category_id"});

sub map_reference {
        my $self = shift;
        return {label_xref=>"label"};
}


# You can replace this text with custom content, and it will be preserved on regeneration
1;
