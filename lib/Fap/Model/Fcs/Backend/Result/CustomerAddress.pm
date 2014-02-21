package Fap::Model::Fcs::Backend::Result::CustomerAddress;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("customer_address");
__PACKAGE__->add_columns(
  "customer_address_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "customer_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "address_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
);
__PACKAGE__->set_primary_key("customer_address_id");
__PACKAGE__->add_unique_constraint("customer_id", ["customer_id", "address_id"]);
__PACKAGE__->belongs_to(
  "address",
  "Fap::Model::Fcs::Backend::Result::EntityAddress",
  { entity_address_id => "address_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-01-17 11:54:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:bF0DQwNvRTTb3ulpyX+Kqw

# You can replace this text with custom content, and it will be preserved on regeneration
1;
