package Fap::Model::Pbxtra::Backend::Result::OrderTran;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("order_trans");
__PACKAGE__->add_columns(
    "order_trans_id", { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
    "order_header_id",      { data_type => "integer", is_nullable   => 1 },
    "item_id",              { data_type => "integer", default_value => 0, is_nullable => 0 },
    "quantity",             { data_type => "integer", default_value => 1, is_nullable => 1 },
    "item_price",           { data_type => "float",   is_nullable   => 1 },
    "prorated",             { data_type => "tinyint", default_value => 0, is_nullable => 0 },
    "prorate_memo",         { data_type => "varchar", is_nullable   => 1, size => 255 },
    "item_type",            { data_type => "varchar", is_nullable   => 1, size => 255 },
    "netsuite_internal_id", { data_type => "varchar", is_nullable   => 1, size => 55 },
);
__PACKAGE__->set_primary_key("order_trans_id");

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:6cJxYFtsW97LSCwc3AYlMw

# You can replace this text with custom content, and it will be preserved on regeneration
1;
