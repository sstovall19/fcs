package Fap::Model::Pbxtra::Backend::Result::OrderContact;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("order_contact");
__PACKAGE__->add_columns(
    "order_contact_id",
    { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
    "product_id",
    { data_type => "integer", is_nullable => 0 },
    "creation_date",
    {   data_type     => "timestamp",
        default_value => \"current_timestamp",
        is_nullable   => 0,
    },
    "changed_by",
    { data_type => "varchar", is_nullable => 0, size => 255 },
    "label_name",
    { data_type => "varchar", is_nullable => 0, size => 255 },
    "label_value",
    { data_type => "varchar", is_nullable => 1, size => 255 },
    "label_priority",
    { data_type => "integer", is_nullable => 0 },
    "label_type",
    { data_type => "varchar", is_nullable => 0, size => 255 },
    "dropdown_has_null",
    { data_type => "integer", default_value => 0, is_nullable => 1 },
    "dropdown_null_text",
    { data_type => "varchar", is_nullable => 1, size => 255 },
    "required_field",
    { data_type => "integer", default_value => 0, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("order_contact_id");

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:XlipFciT5FzY7+sB143ZwQ

# You can replace this text with custom content, and it will be preserved on regeneration
1;
