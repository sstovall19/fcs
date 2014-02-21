package Fap::Model::Fcs::Backend::Result::Provider;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("provider");
__PACKAGE__->add_columns(
  "provider_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "provider_reseller_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 80 },
);
__PACKAGE__->set_primary_key("provider_id");
__PACKAGE__->add_unique_constraint("name", ["name"]);
__PACKAGE__->has_many(
  "provider_countries",
  "Fap::Model::Fcs::Backend::Result::ProviderCountry",
  { "foreign.provider_id" => "self.provider_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "server_providers",
  "Fap::Model::Fcs::Backend::Result::ServerProvider",
  { "foreign.provider_id" => "self.provider_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-01-31 11:25:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:P6ILYBPBed5dwzJejSzfTA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
