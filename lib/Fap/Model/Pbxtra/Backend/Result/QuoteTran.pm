package Fap::Model::Pbxtra::Backend::Result::QuoteTran;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("quote_trans");
__PACKAGE__->add_columns(
    "quote_trans_id", { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
    "quote_header_id", { data_type => "integer", is_nullable   => 1 },
    "item_id",         { data_type => "integer", default_value => 0, is_nullable => 0 },
    "quantity",        { data_type => "integer", default_value => 1, is_nullable => 1 },
    "item_price",      { data_type => "float",   is_nullable   => 1 },
);
__PACKAGE__->set_primary_key("quote_trans_id");

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0gdT3xLsl4HfW/Aq8NShSA

# You can replace this text with custom content, and it will be preserved on regeneration
1;
