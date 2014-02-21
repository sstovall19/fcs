package Fap::Model::Fcs::Backend::Result::OrderLabel;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("order_label");
__PACKAGE__->add_columns(
  "label_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "description",
  { data_type => "mediumtext", is_nullable => 0 },
  "priority",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "display",
  {
    data_type => "enum",
    default_value => "DROPDOWN",
    extra => { list => ["DROPDOWN", "NUMBER", "RADIO", "CHECKBOX", "TEXT"] },
    is_nullable => 0,
  },
  "required",
  {
    data_type => "enum",
    default_value => "NO",
    extra => { list => ["YES", "NO"] },
    is_nullable => 0,
  },
  "validation_type",
  {
    data_type => "enum",
    default_value => "DEFAULT",
    extra => {
      list => [
        "DEFAULT",
        "ALPHANUMERIC",
        "FORM_NAME",
        "FORM_COMPANYNAME",
        "FORM_POSTAL_CODE",
        "FORM_PHONE_NUMBER",
        "FORM_CC_NUMBER",
        "COMMENTS",
        "EMAIL_ADDRESS",
        "NUMBERS",
        "LETTERS",
        "PRICE",
        "TEXT",
        "URL",
      ],
    },
    is_nullable => 0,
  },
  "max",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "min",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "dropdown_has_null",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "dropdown_null_text",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
);
__PACKAGE__->set_primary_key("label_id");
__PACKAGE__->add_unique_constraint("name", ["name"]);
__PACKAGE__->has_many(
  "bundles",
  "Fap::Model::Fcs::Backend::Result::Bundle",
  { "foreign.order_label_id" => "self.label_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "order_category_label_xrefs",
  "Fap::Model::Fcs::Backend::Result::OrderCategoryLabelXref",
  { "foreign.label_id" => "self.label_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-02-14 09:21:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:aBl0uKWcm0nQprjdEFyIQQ

#__PACKAGE__->has_many(bundles=>"Fap::Model::Fcs::Backend::Result::Bundle",{"foreign.order_label_id"=>"self.label_id"});

# You can replace this text with custom content, and it will be preserved on regeneration
1;
