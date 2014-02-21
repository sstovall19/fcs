package Fap::Model::Fcs::Backend::Result::PbxtraCustomer;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("pbxtra.customer");
__PACKAGE__->add_columns(
  "customer_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "netsuite_id",
  { data_type => "integer", is_nullable => 1 },
  "inphonex_id",
  { data_type => "integer", is_nullable => 1 },
  "inphonex_pw",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "can_link_servers",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "main_address_id",
  { data_type => "integer", is_nullable => 1 },
  "cancelled",
  { data_type => "datetime", is_nullable => 1 },
  "cancelled_description",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "created",
  { data_type => "datetime", is_nullable => 1 },
  "reseller_id",
  { data_type => "integer", is_nullable => 1 },
  "inphonex_reseller_id",
  { data_type => "integer", is_nullable => 1 },
  "order_date",
  { data_type => "date", is_nullable => 1 },
  "website",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "industry",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "telecommuters",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "branch_offices",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "prepaid_devices",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "prepaid_softphones",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "golddisk_licenses",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "ee_licenses",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "cce_licenses",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "billing_cycle",
  { data_type => "date", is_nullable => 1 },
  "primary_server_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "cancelled_by_user",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "premium_support",
  { data_type => "tinyint", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("customer_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-01-30 13:29:41
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:r/to/EfonWfU4oO0DPsp3Q

__PACKAGE__->has_many( "server" => "Fap::Model::Fcs::Backend::Result::PbxtraServer", { "foreign.customer_id" => "self.customer_id" } );

__PACKAGE__->might_have(
  "contact",
  "Fap::Model::Fcs::Backend::Result::PbxtraContact",
  { "foreign.customer_id" => "self.customer_id" },
  { is_deferrable => 1, on_update => "CASCADE" },
);

# You can replace this text with custom content, and it will be preserved on regeneration
1;
