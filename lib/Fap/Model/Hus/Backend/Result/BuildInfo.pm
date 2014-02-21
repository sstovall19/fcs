package Fap::Model::Hus::Backend::Result::BuildInfo;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("build_info");
__PACKAGE__->add_columns(
    "build",
    {   data_type     => "integer",
        default_value => 0,
        extra         => { unsigned => 1 },
        is_nullable   => 0,
    },
    "branch",
    { data_type => "varchar", default_value => "", is_nullable => 1, size => 256 },
    "version",
    { data_type => "text", is_nullable => 1 },
    "description",
    { data_type => "text", is_nullable => 1 },
    "qa",
    { data_type => "text", is_nullable => 1 },
    "date",
    { data_type => "text", is_nullable => 1 },
    "xml",
    { data_type => "text", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("build");

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-18 13:09:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0OpKW6DYUdjqtEYTxsbpoA

# You can replace this text with custom content, and it will be preserved on regeneration
1;
