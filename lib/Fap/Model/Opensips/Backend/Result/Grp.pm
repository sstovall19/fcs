package Fap::Model::Opensips::Backend::Result::Grp;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("grp");
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
  "grp",
  { data_type => "char", is_nullable => 0, size => 64 },
  "last_modified",
  {
    data_type     => "datetime",
    default_value => "1900-01-01 00:00:01",
    is_nullable   => 0,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint(
  "account_group_idx" => [ qw/username domain grp/ ]
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-03-07 22:51:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:oSHQ/2I8+xnpuL2/18cl5A

sub column_defaults {
   return {
      'last_modified' => \'NOW()' 
   }
}

# You can replace this text with custom content, and it will be preserved on regeneration
1;
