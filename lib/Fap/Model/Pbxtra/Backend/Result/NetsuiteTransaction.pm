package Fap::Model::Pbxtra::Backend::Result::NetsuiteTransaction;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("netsuite_transactions");
__PACKAGE__->add_columns(
    "id",
    { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
    "function",
    { data_type => "varchar", is_nullable => 1, size => 20 },
    "type",
    { data_type => "varchar", is_nullable => 1, size => 20 },
    "time_stamp",
    {   data_type     => "timestamp",
        default_value => \"current_timestamp",
        is_nullable   => 0,
    },
    "success",
    { data_type => "tinyint", is_nullable => 1 },
    "cc_id",
    { data_type => "integer", is_nullable => 1 },
    "data",
    { data_type => "mediumtext", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:r6cp1fTq6RnlC02kLR/Z3Q

# You can replace this text with custom content, and it will be preserved on regeneration
1;
