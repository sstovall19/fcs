package Fap::Db::Pbxtra::Backend::Result::ResellerSignupRule;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("reseller_signup_rules");
__PACKAGE__->add_columns(
  "reseller_signup_rules_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "archived",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "creation_date",
  { data_type => "datetime", is_nullable => 0 },
  "send_for_training",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "annual_revenue",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "techs",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "salespeople",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "systems_per_month",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "asterisk",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "changed_by",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);
__PACKAGE__->set_primary_key("reseller_signup_rules_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-09 08:46:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zAQF+EIrhNMwaYBExKpsrw


# You can replace this text with custom content, and it will be preserved on regeneration
1;


