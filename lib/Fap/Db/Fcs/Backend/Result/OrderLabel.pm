package Fap::Db::Fcs::Backend::Result::OrderLabel;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

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
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "description",
  { data_type => "mediumtext", is_nullable => 1 },
  "priority",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "display",
  {
    data_type => "enum",
    default_value => "dropdown",
    extra => { list => ["dropdown", "number", "radio", "checkbox", "text"] },
    is_nullable => 0,
  },
  "required",
  {
    data_type => "enum",
    default_value => "no",
    extra => { list => ["yes", "no"] },
    is_nullable => 0,
  },
  "validation_type",
  {
    data_type => "enum",
    extra => {
      list => [
        "default",
        "alphanumeric",
        "form_name",
        "form_companyname",
        "form_postal_code",
        "form_phone_number",
        "form_cc_number",
        "comments",
        "email_address",
        "numbers",
        "letters",
        "price",
        "text",
        "url",
      ],
    },
    is_nullable => 1,
  },
  "max",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "min",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "dropdown_has_null",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "dropdown_null_text",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);
__PACKAGE__->set_primary_key("label_id");
__PACKAGE__->has_many(
  "bundles",
  "Fap::Db::Fcs::Backend::Result::Bundle",
  { "foreign.order_label_id" => "self.label_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "order_category_label_xrefs",
  "Fap::Db::Fcs::Backend::Result::OrderCategoryLabelXref",
  { "foreign.label_id" => "self.label_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-14 13:31:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:N9zp7DqWugb3/cd9TljY8A

#__PACKAGE__->has_many(bundles=>"Fap::Db::Fcs::Backend::Result::Bundle",{"foreign.order_label_id"=>"self.label_id"});


# You can replace this text with custom content, and it will be preserved on regeneration
1;
