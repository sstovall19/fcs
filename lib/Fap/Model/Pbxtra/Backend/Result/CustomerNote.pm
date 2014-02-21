package Fap::Model::Pbxtra::Backend::Result::CustomerNote;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("customer_notes");
__PACKAGE__->add_columns(
    "id",
    { data_type => "mediumint", is_auto_increment => 1, is_nullable => 0 },
    "customer_id",
    { data_type => "integer", is_nullable => 0 },
    "notes",
    { data_type => "varchar", is_nullable => 0, size => 255 },
    "created",
    {   data_type     => "timestamp",
        default_value => \"current_timestamp",
        is_nullable   => 0,
    },
    "user_id",
    { data_type => "varchar", is_nullable => 0, size => 75 },
    "username",
    { data_type => "varchar", is_nullable => 0, size => 75 },
);
__PACKAGE__->set_primary_key("id");

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:63VlL9Ns/TaxxH3NQD0R7A

# You can replace this text with custom content, and it will be preserved on regeneration
1;
