package Fap::Model::Pbxtra::Backend::Result::ItemGroup;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("item_group");
__PACKAGE__->add_columns(
    "item_group_id",
    { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
    "status",
    {   data_type     => "varchar",
        default_value => "active",
        is_nullable   => 0,
        size          => 15,
    },
    "group_name",
    { data_type => "varchar", default_value => "", is_nullable => 0, size => 25 },
    "parent_group_name",
    { data_type => "varchar", is_nullable => 1, size => 25 },
);
__PACKAGE__->set_primary_key("item_group_id");

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:AIG0k5mmE+/FcfMuTZ22jw

# You can replace this text with custom content, and it will be preserved on regeneration
1;
