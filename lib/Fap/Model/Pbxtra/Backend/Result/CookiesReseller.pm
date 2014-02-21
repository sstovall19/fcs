package Fap::Model::Pbxtra::Backend::Result::CookiesReseller;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("cookies_reseller");
__PACKAGE__->add_columns(
    "cookie_value",
    { data_type => "varchar", default_value => "", is_nullable => 0, size => 25 },
    "username",
    { data_type => "varchar", is_nullable => 1, size => 50 },
    "password",
    { data_type => "varchar", is_nullable => 1, size => 20 },
    "created",
    {   data_type     => "timestamp",
        default_value => \"current_timestamp",
        is_nullable   => 0,
    },
    "ip",
    { data_type => "varchar", is_nullable => 1, size => 20 },
);
__PACKAGE__->set_primary_key("cookie_value");

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:efSYhjActxzAKMaqn9v1zA

# You can replace this text with custom content, and it will be preserved on regeneration
1;
