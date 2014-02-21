package Fap::Model::Hus::Backend::Result::UpdatePolicy;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("update_policy");
__PACKAGE__->add_columns(
    "id",
    { data_type => "varchar", default_value => "", is_nullable => 0, size => 8 },
    "name",
    { data_type => "varchar", default_value => "", is_nullable => 0, size => 45 },
    "build",
    {   data_type     => "integer",
        default_value => 0,
        extra         => { unsigned => 1 },
        is_nullable   => 0,
    },
    "message",
    { data_type => "text", is_nullable => 1 },
    "forceupdate",
    { data_type => "tinyint", default_value => 0, is_nullable => 0 },
    "forceautomatic",
    { data_type => "tinyint", default_value => 0, is_nullable => 0 },
    "forcetimeout",
    {   data_type     => "integer",
        default_value => 0,
        extra         => { unsigned => 1 },
        is_nullable   => 0,
    },
    "client_type",
    {   data_type     => "integer",
        default_value => 0,
        extra         => { unsigned => 1 },
        is_nullable   => 0,
    },
);
__PACKAGE__->set_primary_key( "id", "client_type" );

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-18 13:09:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:M7uTU6k0Lv+e3q8jS1VTDA

# You can replace this text with custom content, and it will be preserved on regeneration
1;
