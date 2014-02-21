package Fap::Model::Pbxtra::Backend::Result::UaeUserXref;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("uae_user_xref");
__PACKAGE__->add_columns(
    "user_id",
    { data_type => "integer", default_value => 0, is_nullable => 0 },
    "status",
    {   data_type     => "enum",
        default_value => "None",
        extra         => { list => [ "None", "Active", "Inactive" ] },
        is_nullable   => 1,
    },
    "ext",
    { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
    "server_id",
    { data_type => "integer", default_value => 0, is_nullable => 0 },
    "crm_user_id",
    { data_type => "varchar", is_nullable => 1, size => 255 },
    "primary_ext",
    { data_type => "tinyint", is_nullable => 1 },
    "crm_user_name",
    { data_type => "varchar", is_nullable => 1, size => 255 },
);
__PACKAGE__->set_primary_key("user_id");

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:fV5UZx262BGz1IDkL28z5w

# You can replace this text with custom content, and it will be preserved on regeneration
1;
