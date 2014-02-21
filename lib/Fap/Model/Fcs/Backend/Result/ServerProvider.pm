package Fap::Model::Fcs::Backend::Result::ServerProvider;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("server_provider");
__PACKAGE__->add_columns(
  "server_provider_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "server_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "provider_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "provider_customer_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "provider_username",
  { data_type => "varchar", is_nullable => 1, size => 40 },
  "provider_password",
  { data_type => "char", is_nullable => 1, size => 32 },
  "provider_pin",
  { data_type => "char", is_nullable => 1, size => 5 },
);
__PACKAGE__->set_primary_key("server_provider_id");
__PACKAGE__->add_unique_constraint("server_id", ["server_id", "provider_id"]);
__PACKAGE__->belongs_to(
  "provider",
  "Fap::Model::Fcs::Backend::Result::Provider",
  { provider_id => "provider_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-02-14 09:21:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:03NkAMK3FjX/zlkfHZbOug


# You can replace this text with custom content, and it will be preserved on regeneration
1;
