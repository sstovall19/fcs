package Fap::Db::Pbxtra::Backend::Result::Customer;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("customer");
__PACKAGE__->add_columns(
  "customer_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "netsuite_id",
  { data_type => "integer", is_nullable => 1 },
  "inphonex_id",
  { data_type => "integer", is_nullable => 1 },
  "inphonex_pw",
  { data_type => "varchar", is_nullable => 1, size => 10 },
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
  "primary_server",
  { data_type => "integer", is_nullable => 1 },
  "primary_server_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "cancelled_by_user",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "premium_support",
  { data_type => "tinyint", is_nullable => 1 },
  "billing_schedule",
  { data_type => "integer", is_nullable => 1 },
  "billing_rollup",
  { data_type => "tinyint", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("customer_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-09 08:46:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:5zTANQ3z+u1n3ThzLPQCBw


# You can replace this text with custom content, and it will be preserved on regeneration
__PACKAGE__->has_many("server"=>"Fap::Db::Pbxtra::Backend::Result::Server",{"foreign.customer_id"=>"self.customer_id"});
1;


