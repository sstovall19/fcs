package Fap::Model::Fcs::Backend::Result::HusDownloadSite;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("hus.download_sites");
__PACKAGE__->add_columns(
    "id",
    {   data_type         => "integer",
        extra             => { unsigned => 1 },
        is_auto_increment => 1,
        is_nullable       => 0,
    },
    "url",
    { data_type => "varchar", default_value => "", is_nullable => 0, size => 128 },
    "username",
    { data_type => "varchar", default_value => "", is_nullable => 0, size => 45 },
    "password",
    { data_type => "varchar", default_value => "", is_nullable => 0, size => 45 },
    "description",
    { data_type => "text", is_nullable => 0 },
    "priority",
    {   data_type     => "integer",
        default_value => 0,
        extra         => { unsigned => 1 },
        is_nullable   => 0,
    },
);
__PACKAGE__->set_primary_key("id");

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-18 13:09:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:6b4aYnYFEwDUGRuMT4WUPA

# You can replace this text with custom content, and it will be preserved on regeneration
1;
