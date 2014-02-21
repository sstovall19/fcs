package Fap::Model::Pbxtra::Backend::Result::IpUserLog;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("ip_user_log");
__PACKAGE__->add_columns(
    "ip_log_id",
    {   data_type         => "integer",
        extra             => { unsigned => 1 },
        is_auto_increment => 1,
        is_nullable       => 0,
    },
    "ip",
    { data_type => "char", is_nullable => 1, size => 15 },
    "username",
    { data_type => "varchar", is_nullable => 1, size => 24 },
    "tries",
    { data_type => "integer", is_nullable => 1 },
    "time",
    { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("ip_log_id");

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:gshsgeT8L9TBTSxFY7v0XA

# You can replace this text with custom content, and it will be preserved on regeneration
1;
