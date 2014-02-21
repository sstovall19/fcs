package Fap::Model::Pbxtra::Backend::Result::UpgradeMasterComponent;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("upgrade_master_component");
__PACKAGE__->add_columns(
    "upgrade_master_component_id",
    { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
    "upgrade_master_id",
    { data_type => "integer", default_value => 0, is_nullable => 0 },
    "component_priority",
    { data_type => "integer", default_value => 0, is_nullable => 0 },
    "component_name",
    { data_type => "varchar", is_nullable => 1, size => 255 },
    "component_arch",
    {   data_type     => "enum",
        default_value => "i386",
        extra         => { list => [ "i386", "noarch" ] },
        is_nullable   => 0,
    },
    "component_version",
    { data_type => "varchar", is_nullable => 1, size => 255 },
    "component_release",
    { data_type => "varchar", is_nullable => 1, size => 255 },
    "component_check",
    { data_type => "varchar", is_nullable => 1, size => 255 },
    "component_config",
    { data_type => "varchar", is_nullable => 1, size => 255 },
    "component_unconfig",
    { data_type => "varchar", is_nullable => 1, size => 255 },
    "last_updated",
    {   data_type     => "timestamp",
        default_value => \"current_timestamp",
        is_nullable   => 0,
    },
    "help_text",
    { data_type => "integer", is_nullable => 1 },
    "append_kernel_version",
    { data_type => "char", default_value => 0, is_nullable => 1, size => 1 },
    "component_config_arg",
    { data_type => "varchar", is_nullable => 1, size => 255 },
);
__PACKAGE__->set_primary_key("upgrade_master_component_id");

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:OuksC4O5emtk86+ig9sxDQ

# You can replace this text with custom content, and it will be preserved on regeneration
1;
