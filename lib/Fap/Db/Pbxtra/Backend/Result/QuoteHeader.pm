package Fap::Db::Pbxtra::Backend::Result::QuoteHeader;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("quote_header");
__PACKAGE__->add_columns(
  "quote_header_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "creation_date",
  {
    data_type     => "datetime",
    default_value => "0000-00-00 00:00:00",
    is_nullable   => 0,
  },
  "order_header_id",
  { data_type => "integer", is_nullable => 1 },
  "total",
  { data_type => "double precision", is_nullable => 1 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "email",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "phone",
  { data_type => "varchar", is_nullable => 1, size => 25 },
  "reseller",
  { data_type => "integer", is_nullable => 1 },
  "reseller_id",
  { data_type => "integer", is_nullable => 1 },
  "referral_site",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "referral_date",
  { data_type => "datetime", is_nullable => 1 },
  "first_requesturl",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "sugar_opportunity_id",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "website",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "industry",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "telecommuters",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "branch_offices",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "salesperson_id",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "random_proposal_string",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "deduction",
  { data_type => "integer", is_nullable => 1 },
  "deduction_expire_date",
  { data_type => "date", is_nullable => 1 },
  "promo_code",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "shipping_country",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "shipping_state",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "shipping_city",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "shipping_zip",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "shipping_service",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "shipping_cost",
  { data_type => "double precision", is_nullable => 1 },
  "sales_tax",
  { data_type => "float", is_nullable => 1 },
  "company",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "purchase_timeframe",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "rental_phones",
  { data_type => "integer", is_nullable => 1 },
  "market",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);
__PACKAGE__->set_primary_key("quote_header_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-09 08:46:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:TVywI+2TymMeUEAoUcZXbQ

__PACKAGE__->has_many(trans=>'Fap::Db::Pbxtra::Backend::Result::QuoteTran',{'foreign.quote_header_id'=>'self.quote_header_id'});
__PACKAGE__->has_many(reseller=>'Fap::Db::Pbxtra::Backend::Result::Reseller',{'foreign.reseller_id'=>'self.reseller_id'});

# You can replace this text with custom content, and it will be preserved on regeneration
1;


