package Fap::Db::Pbxtra::Backend::Result::InvoiceItem;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("invoice_items");
__PACKAGE__->add_columns(
  "ii_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "purchase_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "invoice_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "linked",
  {
    data_type     => "datetime",
    default_value => "0000-00-00 00:00:00",
    is_nullable   => 0,
  },
);
__PACKAGE__->set_primary_key("ii_id");
__PACKAGE__->add_unique_constraint("ii", ["purchase_id", "invoice_id"]);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-09 08:46:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:u2p6euyu2g+pHH3uKc7Oxw


# You can replace this text with custom content, and it will be preserved on regeneration
1;


