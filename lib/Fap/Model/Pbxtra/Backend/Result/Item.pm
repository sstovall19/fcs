package Fap::Model::Pbxtra::Backend::Result::Item;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("item");
__PACKAGE__->add_columns(
    "item_id",
    { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
    "netsuite_id",
    { data_type => "integer", is_nullable => 1 },
    "status",
    {   data_type     => "varchar",
        default_value => "active",
        is_nullable   => 0,
        size          => 15,
    },
    "part_number",
    { data_type => "varchar", is_nullable => 1, size => 255 },
    "name",
    { data_type => "varchar", default_value => "", is_nullable => 0, size => 80 },
    "description",
    { data_type => "varchar", is_nullable => 1, size => 255 },
    "price",
    { data_type => "float", default_value => 0, is_nullable => 0 },
    "group_name",
    { data_type => "varchar", is_nullable => 1, size => 50 },
    "recurrence",
    {   data_type     => "enum",
        default_value => "none",
        extra         => { list => [ "none", "monthly", "yearly" ] },
        is_nullable   => 0,
    },
    "weight",
    { data_type => "float", is_nullable => 1 },
    "base_assembly_id",
    { data_type => "float", is_nullable => 1 },
    "discount_group",
    { data_type => "varchar", is_nullable => 1, size => 50 },
    "netsuite_type",
    { data_type => "varchar", is_nullable => 1, size => 40 },
    "netsuite_parent",
    { data_type => "varchar", is_nullable => 1, size => 50 },
    "mnemonic",
    { data_type => "varchar", is_nullable => 1, size => 55 },
    "taxable",
    { data_type => "integer", is_nullable => 1 },
    "rrf_applies",
    { data_type => "integer", default_value => 0, is_nullable => 0 },
    "market",
    { data_type => "varchar", is_nullable => 1, size => 255 },
);
__PACKAGE__->set_primary_key("item_id");

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:5znMoDJoyw29NMz0UvSVOw

# You can replace this text with custom content, and it will be preserved on regeneration
1;
