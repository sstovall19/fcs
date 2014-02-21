package Fap::Model::Pbxtra::Backend::Result::ProviderDid;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("provider_dids");
__PACKAGE__->add_columns(
  "did",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 20 },
  "provider",
  { data_type => "varchar", is_nullable => 0, size => 40 },
  "status",
  {
    data_type => "varchar",
    default_value => "available",
    is_nullable => 0,
    size => 16,
  },
  "expiration",
  { data_type => "datetime", is_nullable => 1 },
  "customer_id",
  { data_type => "integer", is_nullable => 1 },
  "server_id",
  { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("did");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-27 13:20:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:wDy3XrMTOGIIjVFdf1EGaQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
