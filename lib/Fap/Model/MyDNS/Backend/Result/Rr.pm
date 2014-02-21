package Fap::Model::MyDNS::Backend::Result::Rr;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("rr");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "zone",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "name",
  { data_type => "char", default_value => "", is_nullable => 0, size => 64 },
  "type",
  {
    data_type => "enum",
    extra => {
      list => ["A", "AAAA", "CNAME", "HINFO", "MX", "NS", "PTR", "RP", "SRV", "TXT"],
    },
    is_nullable => 1,
  },
  "data",
  { data_type => "char", default_value => "", is_nullable => 0, size => 128 },
  "aux",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "ttl",
  { data_type => "integer", default_value => 600, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("rr", ["zone", "name", "type", "data"]);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-02-13 09:58:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:40VBi0QfH8SbvvL7cNPZOQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
