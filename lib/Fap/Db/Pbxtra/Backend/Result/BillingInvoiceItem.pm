package Fap::Db::Pbxtra::Backend::Result::BillingInvoiceItem;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("billing_invoice_items");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "invoice_id",
  { data_type => "integer", is_nullable => 0 },
  "server_id",
  { data_type => "integer", is_nullable => 0 },
  "netsuite_id",
  { data_type => "integer", is_nullable => 1 },
  "retail_price",
  { data_type => "float", default_value => 0, is_nullable => 1 },
  "price",
  { data_type => "float", default_value => 0, is_nullable => 1 },
  "quantity",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "amount",
  { data_type => "float", default_value => 0, is_nullable => 1 },
  "created",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
  "notes",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "support_contract_id",
  { data_type => "integer", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-07 14:40:55
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:jCML/KuKxEab+8TcwDSz0Q


# You can replace this text with custom content, and it will be preserved on regeneration
1;


