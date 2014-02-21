package Fap::Model::Hus::Backend::Result::UserExt;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("user_ext");
__PACKAGE__->add_columns(
    "user_id",
    {   data_type     => "integer",
        default_value => 0,
        extra         => { unsigned => 1 },
        is_nullable   => 0,
    },
    "edition",
    { data_type => "char", default_value => "PE", is_nullable => 1, size => 4 },
    "policy",
    { data_type => "char", is_nullable => 1, size => 8 },
    "watch",
    { data_type => "tinyint", default_value => 0, is_nullable => 1 },
    "custom_perm",
    { data_type => "varchar", is_nullable => 1, size => 255 },
    "custom_lic",
    { data_type => "varchar", is_nullable => 1, size => 255 },
    "custom_server_lic",
    { data_type => "varchar", is_nullable => 1, size => 255 },
    "dailysendlogs",
    { data_type => "tinyint", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("user_id");

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-18 13:09:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:v9FNvzkqzBFxYiM5YkSX3A

# You can replace this text with custom content, and it will be preserved on regeneration
1;
