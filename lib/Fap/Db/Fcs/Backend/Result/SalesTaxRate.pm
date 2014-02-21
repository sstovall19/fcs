package Fap::Db::Fcs::Backend::Result::SalesTaxRate;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("sales_tax_rate");
__PACKAGE__->add_columns(
  "sales_tax_rate_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "state",
  { data_type => "varchar", is_nullable => 0, size => 2 },
  "zip",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "rate",
  {
    data_type => "decimal",
    default_value => "0.00000",
    is_nullable => 0,
    size => [10, 5],
  },
);
__PACKAGE__->set_primary_key("sales_tax_rate_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-15 14:12:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:mkxqKgM1E3MmzE3npLNOxg

__PACKAGE__->has_one(collect=>"Fap::Db::Fcs::Backend::Result::SalesTaxCollectionState",{"foreign.state"=>"self.state"});


# You can replace this text with custom content, and it will be preserved on regeneration
1;
