package Fap::Model::Pbxtra::Backend::Result::OrderProviderDid;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("order_provider_did");
__PACKAGE__->add_columns(
    "id",
    { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
    "order_id",
    { data_type => "varchar", is_nullable => 0, size => 150 },
    "server_id",
    { data_type => "integer", is_nullable => 0 },
    "request",
    { data_type => "varchar", is_nullable => 1, size => 25 },
    "lnp",
    { data_type => "tinyint", default_value => 0, is_nullable => 0 },
    "tollfree",
    { data_type => "tinyint", default_value => 0, is_nullable => 0 },
    "result",
    { data_type => "varchar", is_nullable => 1, size => 25 },
    "device_id",
    { data_type => "varchar", is_nullable => 1, size => 12 },
    "error",
    { data_type => "varchar", is_nullable => 1, size => 255 },
    "timestamp",
    {   data_type     => "timestamp",
        default_value => \"current_timestamp",
        is_nullable   => 0,
    },
);
__PACKAGE__->set_primary_key("id");

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:4yQndPu3yqLYgau3rRmlAA

# You can replace this text with custom content, and it will be preserved on regeneration
1;
