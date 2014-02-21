package Fap::Db::Pbxtra::Backend::Result::BillsoftTransaction;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("billsoft_transaction");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "invoice_id",
  { data_type => "integer", is_nullable => 1 },
  "type",
  {
    data_type => "enum",
    default_value => "orderline",
    extra => { list => ["orderline", "overage", "tax_item"] },
    is_nullable => 0,
  },
  "description",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "amount",
  { data_type => "float", default_value => 0, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-07 14:40:55
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:SIvE2Wv0AzXhPX79m5FJwg


# You can replace this text with custom content, and it will be preserved on regeneration
1;


