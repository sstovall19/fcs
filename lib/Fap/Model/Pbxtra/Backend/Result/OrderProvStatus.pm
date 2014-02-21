package Fap::Model::Pbxtra::Backend::Result::OrderProvStatus;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("order_prov_status");
__PACKAGE__->add_columns(
    "id",          { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
    "module_name", { data_type => "varchar", is_nullable       => 0, size        => 50 },
    "order_id",    { data_type => "integer", default_value     => 0, is_nullable => 0 },
    "provisioned", { data_type => "tinyint", default_value     => 0, is_nullable => 1 },
    "last_updated", { data_type => "timestamp", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:qtCDrlI03s+2X2h8lzuTPw

# You can replace this text with custom content, and it will be preserved on regeneration
1;
