package Fap::Db::Fcs::Backend::Result::EntityAddress;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("entity_address");
__PACKAGE__->add_columns(
  "entity_address_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "label",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "addr1",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "addr2",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "city",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "state",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "postal",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "country",
  { data_type => "char", is_nullable => 1, size => 3 },
);
__PACKAGE__->set_primary_key("entity_address_id");
__PACKAGE__->has_many(
  "order_groups",
  "Fap::Db::Fcs::Backend::Result::OrderGroup",
  { "foreign.address_id" => "self.entity_address_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "order_transactions",
  "Fap::Db::Fcs::Backend::Result::OrderTransaction",
  { "foreign.billing_address_id" => "self.entity_address_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-13 10:37:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:YLxjlucRBKT7ec+Px0wsEw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
