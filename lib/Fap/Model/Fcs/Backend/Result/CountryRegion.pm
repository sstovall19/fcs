package Fap::Model::Fcs::Backend::Result::CountryRegion;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("country_region");
__PACKAGE__->add_columns(
  "country_region_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "country_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "region_code",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 3 },
  "region_name",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 28 },
);
__PACKAGE__->set_primary_key("country_region_id");
__PACKAGE__->belongs_to(
  "country",
  "Fap::Model::Fcs::Backend::Result::Country",
  { country_id => "country_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);
__PACKAGE__->has_many(
  "region_area_codes",
  "Fap::Model::Fcs::Backend::Result::RegionAreaCode",
  { "foreign.country_region_id" => "self.country_region_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-03-14 10:41:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:uoROZkfK9uBiRzZ3Axs0/Q


# You can replace this text with custom content, and it will be preserved on regeneration
1;
