package Fap::Model::Fcs::Backend::Result::HusUserStat;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("hus.user_stat");
__PACKAGE__->add_columns(
    "user_id",
    { data_type => "integer", default_value => 0, is_nullable => 0 },
    "build",
    { data_type => "integer", default_value => 0, is_nullable => 0 },
    "os",
    { data_type => "integer", default_value => 0, is_nullable => 0 },
    "type",
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
    "last_shown_update",
    { data_type => "integer", is_nullable => 1 },
    "lang",
    { data_type => "varchar", is_nullable => 1, size => 25 },
);
__PACKAGE__->set_primary_key( "user_id", "type", "client_type" );

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-18 13:09:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:MwfPf3sVaJDfULo7P/TfXQ

# You can replace this text with custom content, and it will be preserved on regeneration
1;
