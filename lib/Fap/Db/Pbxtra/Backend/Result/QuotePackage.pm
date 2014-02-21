package Fap::Db::Pbxtra::Backend::Result::QuotePackage;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("quote_packages");
__PACKAGE__->add_columns(
  "calls",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "server_id",
  { data_type => "integer", is_nullable => 1 },
  "cpu_id",
  { data_type => "integer", is_nullable => 1 },
  "ram_id",
  { data_type => "integer", is_nullable => 1 },
  "raid_id",
  { data_type => "integer", is_nullable => 1 },
  "power_id",
  { data_type => "integer", is_nullable => 1 },
  "warranty_id",
  { data_type => "integer", is_nullable => 1 },
  "card_id",
  { data_type => "integer", is_nullable => 1 },
  "setup_id",
  { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("calls");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-09 08:46:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:K7at9bEXaUqfwxa86fdPbA


# You can replace this text with custom content, and it will be preserved on regeneration
1;


