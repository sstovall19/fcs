package Fap::Model::Pbxtra::Backend::Result::PromotionCustomerType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("promotion_customer_type");
__PACKAGE__->add_columns(
    "id",   { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
    "type", { data_type => "varchar", is_nullable       => 0, size        => 20 },
);
__PACKAGE__->set_primary_key("id");

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rK+0OK53F/aJJdEZXdqP6g

# You can replace this text with custom content, and it will be preserved on regeneration
1;
