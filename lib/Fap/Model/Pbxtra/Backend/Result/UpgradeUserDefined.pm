package Fap::Model::Pbxtra::Backend::Result::UpgradeUserDefined;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("upgrade_user_defined");
__PACKAGE__->add_columns(
    "upgrade_user_defined_id",
    { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
    "project_id",
    { data_type => "integer", is_nullable => 1 },
    "server_id",
    { data_type => "integer", is_nullable => 1 },
    "date_modified",
    {   data_type     => "timestamp",
        default_value => \"current_timestamp",
        is_nullable   => 0,
    },
);
__PACKAGE__->set_primary_key("upgrade_user_defined_id");

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:itb0uVEB8rEX/ZJ++4zFTw

# You can replace this text with custom content, and it will be preserved on regeneration
1;
