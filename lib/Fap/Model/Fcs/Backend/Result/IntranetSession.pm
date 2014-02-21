package Fap::Model::Fcs::Backend::Result::IntranetSession;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("intranet_session");
__PACKAGE__->add_columns(
  "intranet_session_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "guid",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "session",
  { data_type => "text", is_nullable => 0 },
  "ip_address",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 45 },
  "created",
  {
    data_type     => "timestamp",
    default_value => "1970-01-01 00:00:00",
    is_nullable   => 0,
  },
  "updated",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
);
__PACKAGE__->set_primary_key("intranet_session_id");
__PACKAGE__->add_unique_constraint("guid_unq", ["guid"]);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-02-07 10:08:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:z/q8jxtghR3PBEha8gELiw


sub column_defaults {
   return {
      created=>\'NULL',
   }
}




# You can replace this text with custom content, and it will be preserved on regeneration
1;
