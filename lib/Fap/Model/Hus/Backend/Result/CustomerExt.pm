package Fap::Model::Hus::Backend::Result::CustomerExt;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("customer_ext");
__PACKAGE__->add_columns(
    "customer_id",
    {   data_type     => "integer",
        default_value => 0,
        extra         => { unsigned => 1 },
        is_nullable   => 0,
    },
    "edition",
    { data_type => "char", default_value => "PE", is_nullable => 1, size => 4 },
    "policy",
    { data_type => "char", default_value => "GA", is_nullable => 1, size => 8 },
);
__PACKAGE__->set_primary_key("customer_id");

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-18 13:09:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:VwX3KlsJAiGOK71mGTcZQA

# You can replace this text with custom content, and it will be preserved on regeneration
1;
