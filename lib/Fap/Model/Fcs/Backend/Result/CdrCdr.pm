package Fap::Model::Fcs::Backend::Result::CdrCdr;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("pbxtra.cdr");
__PACKAGE__->add_columns(
  "cdr_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "userfield",
  { data_type => "mediumtext", is_nullable => 1 },
  "accountcode",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 20 },
  "src",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "dst",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 80 },
  "dcontext",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 80 },
  "clid",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 80 },
  "channel",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 80 },
  "dstchannel",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 80 },
  "lastapp",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 80 },
  "lastdata",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 80 },
  "calldate",
  {
    data_type     => "datetime",
    default_value => "0000-00-00 00:00:00",
    is_nullable   => 0,
  },
  "callend",
  {
    data_type     => "datetime",
    default_value => "0000-00-00 00:00:00",
    is_nullable   => 0,
  },
  "duration",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "billsec",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "disposition",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 45 },
  "amaflags",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "origsrc",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 80 },
  "cost",
  { data_type => "float", is_nullable => 1 },
  "ip",
  { data_type => "varchar", is_nullable => 1, size => 28 },
);
__PACKAGE__->set_primary_key("cdr_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-02-12 11:05:37
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:TMMX14EvJtJAGZ3MOSjNFw

# You can replace this text with custom content, and it will be preserved on regeneration
1;
