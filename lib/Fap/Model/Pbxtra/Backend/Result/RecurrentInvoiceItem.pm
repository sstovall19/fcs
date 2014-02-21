package Fap::Model::Pbxtra::Backend::Result::RecurrentInvoiceItem;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("recurrent_invoice_items");
__PACKAGE__->add_columns(
    "id",
    { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
    "mnemonic",
    { data_type => "varchar", is_nullable => 1, size => 55 },
    "invoice_id",
    { data_type => "integer", default_value => 0, is_nullable => 0 },
    "server_id",
    { data_type => "integer", default_value => 0, is_nullable => 0 },
    "netsuite_id",
    { data_type => "integer", default_value => 0, is_nullable => 0 },
    "retail_price",
    { data_type => "float", default_value => 0, is_nullable => 0 },
    "price",
    { data_type => "float", default_value => 0, is_nullable => 0 },
    "quantity",
    { data_type => "integer", default_value => 0, is_nullable => 0 },
    "amount",
    { data_type => "float", default_value => 0, is_nullable => 0 },
    "created",
    {   data_type     => "timestamp",
        default_value => \"current_timestamp",
        is_nullable   => 0,
    },
    "notes",
    { data_type => "varchar", is_nullable => 1, size => 55 },
    "support_contract_id",
    { data_type => "integer", default_value => 0, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:nXi5Swnzj/mjx3yScx6qYg

# You can replace this text with custom content, and it will be preserved on regeneration
1;
