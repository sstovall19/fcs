package Fap::Model::Opensips::Backend::Result::Subscriber;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("subscriber");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "username",
  { data_type => "char", is_nullable => 0, size => 64 },
  "domain",
  { data_type => "char", is_nullable => 0, size => 64 },
  "password",
  { data_type => "char", is_nullable => 0, size => 25 },
  "email_address",
  { data_type => "char", is_nullable => 0, size => 64 },
  "ha1",
  { data_type => "char", is_nullable => 0, size => 64 },
  "ha1b",
  { data_type => "char", default_value => "NULL", is_nullable => 1, size => 64 },
  "quota",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraints(
  "account_idx" => [ qw/username domain/ ],
  "username_idx" => [ qw/username/ ],
);

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-03-07 22:51:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:mbWlyPhDKIwiakU9iuaFnw

sub column_defaults {
   return {
      'quota' => 0,
      'email_address' => '' 
   }
}

# You can replace this text with custom content, and it will be preserved on regeneration
1;
