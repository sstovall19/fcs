package Fap::Model::Fcs::Backend::Result::OpensipsDbalias;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("opensips.dbaliases");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "alias_username",
  { data_type => "char", default_value => "", is_nullable => 0, size => 64 },
  "alias_domain",
  { data_type => "char", default_value => "", is_nullable => 0, size => 64 },
  "username",
  { data_type => "char", default_value => "", is_nullable => 0, size => 64 },
  "domain",
  { data_type => "char", default_value => "", is_nullable => 0, size => 64 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraints(
    "alias_idx" => ["alias_username", "alias_domain"],
    "alias_username_UNIQ" => [ qw/alias_username/ ],
    "target_idx" => ["username", "domain"]
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-03-12 20:39:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:TaowgfahArPFMOBSv41UKA

sub column_defaults {
   return {
      'alias_domain' => ''
   }
}

# You can replace this text with custom content, and it will be preserved on regeneration
1;
