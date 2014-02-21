package Fap::Model::Fcs::Backend::Result::ProviderCountry;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("provider_country");
__PACKAGE__->add_columns(
  "provider_country_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "provider_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "country_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
);
__PACKAGE__->set_primary_key("provider_country_id");
__PACKAGE__->add_unique_constraint("provider_id", ["provider_id", "country_id"]);
__PACKAGE__->belongs_to(
  "provider",
  "Fap::Model::Fcs::Backend::Result::Provider",
  { provider_id => "provider_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);
__PACKAGE__->belongs_to(
  "country",
  "Fap::Model::Fcs::Backend::Result::Country",
  { country_id => "country_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-01-31 11:25:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Nu4Wdsn/w5U8+vSCHl2T1g


# You can replace this text with custom content, and it will be preserved on regeneration
1;
