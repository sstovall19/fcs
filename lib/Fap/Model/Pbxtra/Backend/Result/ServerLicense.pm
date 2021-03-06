package Fap::Model::Pbxtra::Backend::Result::ServerLicense;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("server_licenses");
__PACKAGE__->add_columns(
    "id",
    { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
    "server_id",
    { data_type => "integer", is_nullable => 1 },
    "type",
    { data_type => "varchar", is_nullable => 1, size => 20 },
    "qty",
    { data_type => "integer", is_nullable => 1 },
    "date_purchased",
    {   data_type     => "timestamp",
        default_value => \"current_timestamp",
        is_nullable   => 0,
    },
);
__PACKAGE__->set_primary_key("id");

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:SzwbeLaGXyDg91qzTkU28g

# You can replace this text with custom content, and it will be preserved on regeneration
1;
