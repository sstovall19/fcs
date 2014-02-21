package Fap::Model::Pbxtra::Backend::Result::ServerCustomerXref;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("server_customer_xref");
__PACKAGE__->add_columns(
    "server_customer_xref_id", { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
    "server_id",               { data_type => "integer", default_value     => 0, is_nullable => 0 },
    "customer_id",             { data_type => "integer", default_value     => 0, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("server_customer_xref_id");

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:D15k6IrmbSLd9MGjHc4cZw

# You can replace this text with custom content, and it will be preserved on regeneration
1;
