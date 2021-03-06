package Fap::Model::Pbxtra::Backend::Result::CustomerInfo;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("customer_info");
__PACKAGE__->add_columns(
    "customer_id",   { data_type => "integer", default_value => 0, is_nullable => 0 },
    "recurring_day", { data_type => "integer", default_value => 1, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("customer_id");

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:m0ycnWs7cDoXkr8pYccbww

# You can replace this text with custom content, and it will be preserved on regeneration
1;
