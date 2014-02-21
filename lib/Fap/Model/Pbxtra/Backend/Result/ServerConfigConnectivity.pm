package Fap::Model::Pbxtra::Backend::Result::ServerConfigConnectivity;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("server_config_connectivity");
__PACKAGE__->add_columns(
    "server_config_option_id",
    { data_type => "integer", default_value => 0, is_nullable => 0 },
    "connectivity_group",
    { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
    "creation_date",
    {   data_type     => "datetime",
        default_value => "0000-00-00 00:00:00",
        is_nullable   => 0,
    },
    "card_type",
    { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
    "card_max",
    { data_type => "integer", default_value => 0, is_nullable => 0 },
    "last_changed_by",
    { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
    "last_changed",
    {   data_type     => "datetime",
        default_value => "0000-00-00 00:00:00",
        is_nullable   => 0,
    },
);
__PACKAGE__->set_primary_key( "server_config_option_id", "connectivity_group", "card_type" );

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+E70CPTo0Mla17RqGHFxXg

# You can replace this text with custom content, and it will be preserved on regeneration
1;
