package Fap::Model::Fcs::Backend::Result::Country;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("country");
__PACKAGE__->add_columns(
  "country_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 80 },
  "dialing_code",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "national_prefix",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "numeric_code",
  { data_type => "char", is_nullable => 1, size => 3 },
  "alpha_code_2",
  { data_type => "char", default_value => "", is_nullable => 0, size => 2 },
  "alpha_code_3",
  { data_type => "char", default_value => "", is_nullable => 0, size => 3 },
  "loadzone",
  { data_type => "char", default_value => "", is_nullable => 0, size => 2 },
  "default_language",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 80 },
);
__PACKAGE__->set_primary_key("country_id");
__PACKAGE__->add_unique_constraint("name", ["name"]);
__PACKAGE__->has_many(
  "country_regions",
  "Fap::Model::Fcs::Backend::Result::CountryRegion",
  { "foreign.country_id" => "self.country_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "datacenters",
  "Fap::Model::Fcs::Backend::Result::Datacenter",
  { "foreign.country_id" => "self.country_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "provider_countries",
  "Fap::Model::Fcs::Backend::Result::ProviderCountry",
  { "foreign.country_id" => "self.country_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-03-14 10:41:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:VROTYV6PYdbBZ2PpxPZf7Q


# You can replace this text with custom content, and it will be preserved on regeneration
1;
