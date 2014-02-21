package Fap::Model::Pbxtra::Backend::Result::UpgradeStat;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("upgrade_stats");
__PACKAGE__->add_columns(
    "upgrade_id",
    { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
    "project",
    { data_type => "varchar", is_nullable => 1, size => 255 },
    "server_id",
    { data_type => "integer", default_value => 0, is_nullable => 0 },
    "customer_id",
    { data_type => "integer", default_value => 0, is_nullable => 0 },
    "start_time",
    {   data_type     => "datetime",
        default_value => "0000-00-00 00:00:00",
        is_nullable   => 0,
    },
    "last_stage_completed",
    { data_type => "varchar", is_nullable => 1, size => 255 },
    "last_updated",
    {   data_type     => "datetime",
        default_value => "0000-00-00 00:00:00",
        is_nullable   => 0,
    },
    "attempts",
    { data_type => "integer", default_value => 1, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("upgrade_id");

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/9WZLwuuYSs7NYkd4TjTSA

# You can replace this text with custom content, and it will be preserved on regeneration
1;
