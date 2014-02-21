package Fap::Model::Pbxtra::Backend::Result::Rserver;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("rserver");
__PACKAGE__->add_columns(
    "rserver_id", { data_type => "integer", is_nullable => 0 },
    "proxy_server_flag", { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);
__PACKAGE__->add_unique_constraint( "rserver_id", ["rserver_id"] );

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:pqgjvyPxWvNPC1w0FWlTfg

# You can replace this text with custom content, and it will be preserved on regeneration
1;
