package Fap::Model::Pbxtra::Backend::Result::PackagesServer;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("packages_servers");
__PACKAGE__->add_columns(
    "ps_id",
    { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
    "package_id",
    { data_type => "integer", default_value => 0, is_nullable => 0 },
    "server_id",
    { data_type => "integer", default_value => 0, is_nullable => 0 },
    "adddate",
    {   data_type     => "datetime",
        default_value => "0000-00-00 00:00:00",
        is_nullable   => 0,
    },
    "status",
    {   data_type     => "enum",
        default_value => "active",
        extra         => { list => [ "active", "inactive" ] },
        is_nullable   => 0,
    },
    "enddate",
    { data_type => "datetime", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("ps_id");

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9N4FYaI0HLcDV52T4x7GZg

# You can replace this text with custom content, and it will be preserved on regeneration
1;
