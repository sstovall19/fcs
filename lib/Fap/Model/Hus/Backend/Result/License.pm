package Fap::Model::Hus::Backend::Result::License;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("licenses");
__PACKAGE__->add_columns(
    "id", { data_type => "varchar", is_nullable => 0, size => 50 }, "lictype", { data_type => "integer", is_nullable => 0 },
    "licorder", { data_type => "integer", is_nullable => 0 }, "xml", { data_type => "text", is_nullable => 0 },
    "timestamp", { data_type => "varchar", is_nullable => 0, size => 255 },
);
__PACKAGE__->set_primary_key("id");

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-18 13:09:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:idutGcDXuxOtloc5xP/inw

# You can replace this text with custom content, and it will be preserved on regeneration
1;
