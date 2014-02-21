package Fap::Model::Fcs::Backend::Result::Datacenter;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("datacenter");
__PACKAGE__->add_columns(
  "datacenter_id",
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
  "state_prov",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
  "location",
  {
    data_type => "enum",
    default_value => "LA",
    extra => { list => ["LA", "VA", "JPN", "AUS"] },
    is_nullable => 0,
  },
);
__PACKAGE__->set_primary_key("datacenter_id");
__PACKAGE__->add_unique_constraint("country_id", ["country_id", "state_prov", "location"]);
__PACKAGE__->belongs_to(
  "country",
  "Fap::Model::Fcs::Backend::Result::Country",
  { country_id => "country_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-02-11 10:54:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/mTllfehcRW7Odzncbe+fw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
