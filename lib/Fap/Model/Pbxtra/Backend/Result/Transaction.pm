package Fap::Model::Pbxtra::Backend::Result::Transaction;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("transactions");
__PACKAGE__->add_columns(
    "trans_id",
    { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
    "customer_id",
    { data_type => "integer", default_value => 0, is_nullable => 0 },
    "authcode",
    { data_type => "integer", is_nullable => 1 },
    "charged",
    {   data_type     => "datetime",
        default_value => "0000-00-00 00:00:00",
        is_nullable   => 0,
    },
    "amount",
    { data_type => "float", default_value => 0, is_nullable => 0 },
    "accepted",
    { data_type => "integer", default_value => 0, is_nullable => 0 },
    "rejected_message",
    { data_type => "varchar", is_nullable => 1, size => 255 },
    "cc_id",
    { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("trans_id");

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7u0Ui3GfEvVBfdNKofwtnw

# You can replace this text with custom content, and it will be preserved on regeneration
1;
