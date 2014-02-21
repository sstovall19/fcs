package Fap::Model::Fcs::Backend::Result::OpensipsSipTrace;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("opensips.sip_trace");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "time_stamp",
  {
    data_type     => "datetime",
    default_value => "1900-01-01 00:00:01",
    is_nullable   => 0,
  },
  "callid",
  { data_type => "char", default_value => "", is_nullable => 0, size => 255 },
  "traced_user",
  { data_type => "char", is_nullable => 1, size => 128 },
  "msg",
  { data_type => "text", is_nullable => 0 },
  "method",
  { data_type => "char", default_value => "", is_nullable => 0, size => 32 },
  "status",
  { data_type => "char", is_nullable => 1, size => 128 },
  "fromip",
  { data_type => "char", default_value => "", is_nullable => 0, size => 50 },
  "toip",
  { data_type => "char", default_value => "", is_nullable => 0, size => 50 },
  "fromtag",
  { data_type => "char", default_value => "", is_nullable => 0, size => 64 },
  "direction",
  { data_type => "char", default_value => "", is_nullable => 0, size => 4 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-03-12 20:39:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1cYi+SHPiCOuxcgVzkEuzA

sub column_defaults {
    return {
       'time_stamp' => \'NOW()' 
    }
}

# You can replace this text with custom content, and it will be preserved on regeneration
1;
