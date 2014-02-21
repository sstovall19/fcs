package Fap::Model::Pbxtra::Backend::Result::LiveInvoiceItem;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("live_invoice_items");
__PACKAGE__->add_columns(
    "id",
    { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
    "server_id",
    { data_type => "integer", default_value => 0, is_nullable => 0 },
    "item_id",
    { data_type => "integer", default_value => 0, is_nullable => 0 },
    "quantity",
    { data_type => "integer", default_value => 0, is_nullable => 0 },
    "price",
    { data_type => "float", default_value => 0, is_nullable => 0 },
    "order_header_id",
    { data_type => "integer", is_nullable => 1 },
    "date_added",
    {   data_type     => "datetime",
        default_value => "0000-00-00 00:00:00",
        is_nullable   => 0,
    },
    "updated",
    {   data_type     => "datetime",
        default_value => "0000-00-00 00:00:00",
        is_nullable   => 0,
    },
);
__PACKAGE__->set_primary_key("id");

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2Iqc8IL3vZNRXwjOABLwsw

# You can replace this text with custom content, and it will be preserved on regeneration
1;
