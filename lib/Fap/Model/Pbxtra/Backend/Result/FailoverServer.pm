package Fap::Model::Pbxtra::Backend::Result::FailoverServer;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("failover_servers");
__PACKAGE__->add_columns(
    "server_id",
    { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
    "failover_for",
    { data_type => "integer", is_nullable => 0 },
    "state",
    {   data_type   => "enum",
        extra       => { list => [ "provisioning", "syncing", "restoring", "active", "recycling", "trashed", ], },
        is_nullable => 0,
    },
    "description",
    { data_type => "varchar", is_nullable => 1, size => 255 },
    "created",
    { data_type => "datetime", is_nullable => 0 },
    "last_modified",
    { data_type => "datetime", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("server_id");
__PACKAGE__->add_unique_constraint( "failover_for", ["failover_for"] );
__PACKAGE__->belongs_to(
    "server",
    "Fap::Model::Pbxtra::Backend::Result::FailoverServerPool",
    { server_id     => "server_id" },
    { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:XmcxvE5XSXIyB4a0s7rtHA

# You can replace this text with custom content, and it will be preserved on regeneration
1;
