package Fap::Model::Pbxtra::Backend::Result::ServerPriFailover;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("server_pri_failover");
__PACKAGE__->add_columns(
    "pri_failover_id", { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
    "server_id", { data_type => "integer", is_nullable => 0 },
    "incoming_failover_server",                 { data_type => "integer", is_nullable => 0 },
    "incoming_failover_extension",              { data_type => "integer", is_nullable => 0 },
    "incoming_routing_num",                     { data_type => "varchar", is_nullable => 0, size => 45 },
    "incoming_routing_dest",                    { data_type => "varchar", is_nullable => 0, size => 30 },
    "incoming_secondary_routing_dest",          { data_type => "varchar", is_nullable => 0, size => 45 },
    "incoming_secondary_routing_dest_is_vmbox", { data_type => "varchar", is_nullable => 0, size => 45 },
);
__PACKAGE__->set_primary_key("pri_failover_id");
__PACKAGE__->add_unique_constraint( "server_id", ["server_id"] );

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:g+Yn8634l5PUSEuvMxIMuQ

# You can replace this text with custom content, and it will be preserved on regeneration
1;
