package Fap::Model::Fcs::Backend::Result::UnboundCdrTest;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("unbound_cdr_test");
__PACKAGE__->add_columns(
  "server_id",
  { data_type => "integer", is_nullable => 0 },
  "unique_id",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "invoice_id",
  { data_type => "integer", is_nullable => 1 },
  "calldate",
  { data_type => "datetime", is_nullable => 0 },
  "did",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "ani",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "dialed_number",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "is_mobile",
  { data_type => "varchar", is_nullable => 1, size => 1 },
  "call_duration",
  { data_type => "integer", is_nullable => 1 },
  "billable_duration",
  { data_type => "integer", is_nullable => 1 },
  "billed_amount",
  { data_type => "float", is_nullable => 1 },
  "customer_billed_amount",
  { data_type => "float", is_nullable => 1 },
  "disposition",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "virtual_phone",
  { data_type => "varchar", is_nullable => 1, size => 7 },
  "inphonex_id",
  { data_type => "varchar", is_nullable => 1, size => 7 },
  "country",
  { data_type => "varchar", is_nullable => 1, size => 2 },
  "info",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "provider_id",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "provider_type",
  { data_type => "varchar", is_nullable => 1, size => 40 },
  "provider_customer_id",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "international",
  { data_type => "tinyint", is_nullable => 1 },
  "direction",
  {
    data_type => "enum",
    extra => { list => ["inbound", "outbound"] },
    is_nullable => 1,
  },
  "call_type",
  {
    data_type => "enum",
    extra => {
      list => ["standard", "mobile", "tollfree", "emergency", "premium"],
    },
    is_nullable => 1,
  },
);
__PACKAGE__->set_primary_key("unique_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-01-14 11:59:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:NWhiHL/x8Y64FrihK5cWaA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
