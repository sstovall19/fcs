package Fap::Model::Fcs::Backend::Result::PbxtraE911Address;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("pbxtra.e911_address");
__PACKAGE__->add_columns(
  "did",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "first_name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "last_name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "house_number",
  { data_type => "varchar", is_nullable => 0, size => 20 },
  "house_number_suffix",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "prefix_directional",
  { data_type => "varchar", is_nullable => 1, size => 2 },
  "street_name",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "street_suffix",
  { data_type => "varchar", is_nullable => 0, size => 10 },
  "post_directional",
  { data_type => "varchar", is_nullable => 1, size => 2 },
  "city",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "state",
  { data_type => "varchar", is_nullable => 0, size => 3 },
  "postal_code",
  { data_type => "varchar", is_nullable => 0, size => 6 },
  "unit_number",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "unit_type",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "country",
  { data_type => "varchar", default_value => "US", is_nullable => 0, size => 2 },
  "updated",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
  "submitted",
  {
    data_type     => "timestamp",
    default_value => "0000-00-00 00:00:00",
    is_nullable   => 0,
  },
);
__PACKAGE__->set_primary_key("did");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-03-05 21:47:31
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:De/OPTEd5HMmkkX30WunkA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
