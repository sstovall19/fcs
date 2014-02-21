package Fap::Model::Fcs::Backend::Result::RegionAreaCode;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("region_area_code");
__PACKAGE__->add_columns(
  "region_area_code_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "country_region_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "area_code",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "region_name",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 28 },
);
__PACKAGE__->set_primary_key("region_area_code_id");
__PACKAGE__->belongs_to(
  "country_region",
  "Fap::Model::Fcs::Backend::Result::CountryRegion",
  { country_region_id => "country_region_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-03-14 10:41:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:qUB9N99XdyDawZLSBf3cvA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
