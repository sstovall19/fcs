package Fap::Model::Pbxtra::Backend::Result::CreditTransaction;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("credit_transaction");
__PACKAGE__->add_columns(
    "transaction_id",
    { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
    "customer_id",
    { data_type => "integer", default_value => 0, is_nullable => 0 },
    "delta",
    { data_type => "integer", default_value => 0, is_nullable => 0 },
    "total",
    { data_type => "integer", default_value => 0, is_nullable => 0 },
    "updated",
    {   data_type     => "timestamp",
        default_value => \"current_timestamp",
        is_nullable   => 0,
    },
    "updated_by",
    { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
    "type",
    { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
);
__PACKAGE__->set_primary_key("transaction_id");

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:qqtMYeW0xp6Kyf/KToaudg

# You can replace this text with custom content, and it will be preserved on regeneration
1;
