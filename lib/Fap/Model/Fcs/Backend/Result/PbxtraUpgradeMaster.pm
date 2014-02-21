package Fap::Model::Fcs::Backend::Result::PbxtraUpgradeMaster;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("pbxtra.upgrade_master");
__PACKAGE__->add_columns(
    "upgrade_master_id",
    { data_type => "integer", default_value => 0, is_nullable => 0 },
    "project_name",
    { data_type => "varchar", is_nullable => 1, size => 255 },
    "server_class",
    { data_type => "varchar", default_value => 0, is_nullable => 0, size => 20 },
    "start_time",
    {   data_type     => "datetime",
        default_value => "0000-00-00 00:00:00",
        is_nullable   => 0,
    },
    "due_date",
    { data_type => "datetime", is_nullable => 1 },
    "last_updated",
    {   data_type     => "timestamp",
        default_value => \"current_timestamp",
        is_nullable   => 0,
    },
    "restart_asterisk",
    { data_type => "tinyint", default_value => 0, is_nullable => 0 },
    "banner_id",
    { data_type => "integer", is_nullable => 1 },
    "upgrade_type",
    {   data_type     => "enum",
        default_value => "update",
        extra         => { list => [ "upgrade", "update" ] },
        is_nullable   => 0,
    },
    "upgrade_location",
    { data_type => "varchar", is_nullable => 1, size => 100 },
    "repo_version",
    {   data_type     => "enum",
        default_value => "P",
        extra         => { list => [ "A", "B", "P" ] },
        is_nullable   => 0,
    },
    "cp_version",
    { data_type => "varchar", is_nullable => 1, size => 20 },
    "hud_upgrade",
    { data_type => "tinyint", default_value => 0, is_nullable => 0 },
    "patch_upgrade",
    { data_type => "tinyint", default_value => 0, is_nullable => 1 },
);
__PACKAGE__->set_primary_key( "upgrade_master_id", "server_class" );

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/tcytQVECeHHXThlQDgsGQ

# You can replace this text with custom content, and it will be preserved on regeneration
1;
