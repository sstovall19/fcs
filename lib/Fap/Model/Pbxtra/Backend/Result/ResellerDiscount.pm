package Fap::Model::Pbxtra::Backend::Result::ResellerDiscount;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("reseller_discounts");
__PACKAGE__->add_columns(
    "reseller_discount_id", { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
    "reseller_id",          { data_type => "integer", is_nullable       => 1 },
    "reseller_status",      { data_type => "varchar", is_nullable       => 1, size        => 50 },
    "reseller_trained",     { data_type => "tinyint", is_nullable       => 1 },
    "reseller_certified",   { data_type => "varchar", is_nullable       => 1, size        => 10 },
    "discount_group", { data_type => "varchar", default_value => "", is_nullable => 0, size => 50 },
    "discount_amt", { data_type => "float", default_value => 0, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("reseller_discount_id");

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zoZsXn7xL/YyYz4/ecXfyQ

# You can replace this text with custom content, and it will be preserved on regeneration
1;
