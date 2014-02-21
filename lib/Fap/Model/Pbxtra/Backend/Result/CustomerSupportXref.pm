package Fap::Model::Pbxtra::Backend::Result::CustomerSupportXref;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("customer_support_xref");
__PACKAGE__->add_columns(
    "xref_id",
    { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
    "customer_id",
    { data_type => "integer", is_nullable => 0 },
    "user_id",
    { data_type => "integer", is_nullable => 0 },
    "role",
    {   data_type   => "enum",
        extra       => { list => [ "primary", "secondary" ] },
        is_nullable => 1,
    },
    "route_call",
    { data_type => "integer", is_nullable => 0 },
    "tag_ticket",
    { data_type => "integer", is_nullable => 0 },
    "own_ticket",
    { data_type => "integer", is_nullable => 0 },
    "created",
    { data_type => "date", is_nullable => 1 },
    "last_updated",
    {   data_type     => "timestamp",
        default_value => \"current_timestamp",
        is_nullable   => 0,
    },
    "created_by",
    { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("xref_id");

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:YG9OgSMWYEfwA9fLUK6yvQ

# You can replace this text with custom content, and it will be preserved on regeneration
1;
