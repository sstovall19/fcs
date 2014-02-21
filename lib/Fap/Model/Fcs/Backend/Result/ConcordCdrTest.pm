package Fap::Model::Fcs::Backend::Result::ConcordCdrTest;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("concord_cdr_test");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "salesorgid",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "companyid",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "countrycode",
  { data_type => "varchar", is_nullable => 1, size => 8 },
  "areacode",
  { data_type => "varchar", is_nullable => 1, size => 8 },
  "faxphonenumber",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "departmentcode",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "customcode1",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "customcode2",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "customcode3",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "customcode4",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "tollfreeflag",
  {
    data_type => "enum",
    extra => { list => ["True", "False"] },
    is_nullable => 1,
  },
  "userid",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "lastname",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "firstname",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "emailaddress",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "pagecount",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "date",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "time",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "timezone",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "faxdestnumber",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "faxsourcecsid",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "referenceid",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "eventtypedescription",
  {
    data_type => "enum",
    extra => { list => ["FaxFwd", "FaxRcvd", "FaxDlvry"] },
    is_nullable => 1,
  },
  "subject",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "userfield1",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "userfield2",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "userfield3",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "userfield4",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "userfield5",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "userfield6",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "userfield7",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "userfield8",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "userfield9",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "userfield10",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "userfield11",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "userfield12",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "faxsourcesendernumber",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "epochgmt",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "invoice_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "messageid",
  { data_type => "varchar", is_nullable => 0, size => 128 },
  "recordid",
  { data_type => "varchar", is_nullable => 0, size => 128 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("RecordId", ["recordid"]);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-01-14 11:59:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Ko6xrfUErUmxsZUcE2g8Ew


# You can replace this text with custom content, and it will be preserved on regeneration
1;
