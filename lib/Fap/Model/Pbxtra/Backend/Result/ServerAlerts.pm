package Fap::Model::Pbxtra::Backend::Result::ServerAlerts;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("server_alerts");
__PACKAGE__->add_columns(
    "id",        { data_type => "integer", is_auto_increment => 1,  is_nullable => 0 },
    "server_id", { data_type => "integer", default_value     => 0,  is_nullable => 0 },
    "alert",     { data_type => "varchar", default_value     => "", is_nullable => 0, size => 30 },
    "value",     { data_type => "varchar", is_nullable       => 1,  size        => 255 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint( "alert", [ "server_id", "alert" ] );

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:sKgrCZhsPEKhGtVLdXg5bw

# You can replace this text with custom content, and it will be preserved on regeneration
1;
