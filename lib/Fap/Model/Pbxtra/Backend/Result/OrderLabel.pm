package Fap::Model::Pbxtra::Backend::Result::OrderLabel;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("order_labels");
__PACKAGE__->add_columns(
    "label_id",
    { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
    "category_id",
    { data_type => "integer", is_nullable => 1 },
    "label_name",
    { data_type => "varchar", is_nullable => 0, size => 255 },
    "label_priority",
    { data_type => "integer", is_nullable => 1 },
    "label_display",
    {   data_type     => "enum",
        default_value => "dropdown",
        extra         => { list => [ "dropdown", "number", "checkbox", "radio" ] },
        is_nullable   => 0,
    },
    "dropdown_has_null",
    { data_type => "tinyint", default_value => 0, is_nullable => 0 },
    "dropdown_null_text",
    { data_type => "varchar", is_nullable => 1, size => 255 },
    "label_cardinality",
    {   data_type     => "enum",
        default_value => "left",
        extra         => { list => [ "left", "right", "top", "bottom" ] },
        is_nullable   => 0,
    },
);
__PACKAGE__->set_primary_key("label_id");

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:4u4yCKzfKZUc0hh2nysJ1g

# You can replace this text with custom content, and it will be preserved on regeneration
1;
