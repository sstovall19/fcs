package Fap::Model::Pbxtra::Backend::Result::ContactDropdownOption;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("contact_dropdown_options");
__PACKAGE__->add_columns(
    "contact_dropdown_option_id",
    { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
    "order_contact_id",
    { data_type => "integer", is_nullable => 0 },
    "creation_date",
    {   data_type     => "timestamp",
        default_value => \"current_timestamp",
        is_nullable   => 0,
    },
    "changed_by",
    { data_type => "varchar", is_nullable => 0, size => 255 },
    "option_name",
    { data_type => "varchar", is_nullable => 0, size => 255 },
    "option_value",
    { data_type => "varchar", is_nullable => 0, size => 255 },
    "option_priority",
    { data_type => "integer", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("contact_dropdown_option_id");

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:xnjk9KclehYF4QpCnSFbOg

# You can replace this text with custom content, and it will be preserved on regeneration
1;
