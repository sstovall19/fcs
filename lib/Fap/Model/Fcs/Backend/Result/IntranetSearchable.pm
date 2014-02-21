package Fap::Model::Fcs::Backend::Result::IntranetSearchable;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("intranet_searchable");
__PACKAGE__->add_columns(
  "intranet_searchable_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "mode",
  { data_type => "varchar", is_nullable => 0, size => 36 },
  "format",
  { data_type => "varchar", is_nullable => 0, size => 72 },
  "action",
  {
    data_type => "varchar",
    default_value => "searchable",
    is_nullable => 0,
    size => 36,
  },
  "param",
  {
    data_type => "varchar",
    default_value => "query",
    is_nullable => 0,
    size => 36,
  },
);
__PACKAGE__->set_primary_key("intranet_searchable_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-26 10:25:12
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:jJ1yeXJLHD319J/c6SMZWg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
