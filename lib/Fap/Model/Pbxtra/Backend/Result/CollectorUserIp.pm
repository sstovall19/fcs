package Fap::Model::Pbxtra::Backend::Result::CollectorUserIp;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("collector_user_ip");
__PACKAGE__->add_columns(
    "id",
    {   data_type         => "integer",
        extra             => { unsigned => 1 },
        is_auto_increment => 1,
        is_nullable       => 0,
    },
    "user_id",
    { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
    "ip_address",
    { data_type => "varchar", is_nullable => 1, size => 45 },
);
__PACKAGE__->set_primary_key("id");

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:xV33JKXKHDZFRQxPmO74nw

# You can replace this text with custom content, and it will be preserved on regeneration
1;
