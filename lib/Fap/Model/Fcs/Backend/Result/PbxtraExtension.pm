package Fap::Model::Fcs::Backend::Result::PbxtraExtension;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("pbxtra.extensions");
__PACKAGE__->add_columns(
    "extension",
    { data_type => "varchar", default_value => 0, is_nullable => 0, size => 255 },
    "device_id",
    { data_type => "integer", default_value => 0, is_nullable => 0 },
    "server_id",
    { data_type => "integer", default_value => 0, is_nullable => 0 },
    "vm_enabled",
    { data_type => "tinyint", default_value => 1, is_nullable => 0 },
    "mailbox",
    { data_type => "varchar", is_nullable => 1, size => 255 },
    "vm_pass",
    { data_type => "varchar", is_nullable => 1, size => 16 },
    "vm_attach",
    { data_type => "tinyint", default_value => 0, is_nullable => 0 },
    "vm_email",
    { data_type => "varchar", is_nullable => 1, size => 255 },
    "vm_pager",
    { data_type => "varchar", is_nullable => 1, size => 255 },
    "is_private",
    { data_type => "tinyint", default_value => 0, is_nullable => 0 },
    "insert_into_dir",
    { data_type => "tinyint", default_value => 1, is_nullable => 0 },
    "in_blast_group",
    { data_type => "tinyint", default_value => 0, is_nullable => 0 },
    "press_to_accept",
    { data_type => "tinyint", default_value => 0, is_nullable => 0 },
    "auto_logoff",
    { data_type => "tinyint", default_value => 0, is_nullable => 0 },
    "q_ignore_if_busy",
    { data_type => "tinyint", default_value => 1, is_nullable => 0 },
    "description",
    { data_type => "varchar", is_nullable => 1, size => 255 },
    "ring_seconds",
    { data_type => "integer", default_value => 20, is_nullable => 0 },
    "address_id",
    { data_type => "integer", is_nullable => 1 },
    "call_return",
    { data_type => "tinyint", default_value => 1, is_nullable => 0 },
    "call_out",
    { data_type => "tinyint", default_value => 1, is_nullable => 0 },
    "vm_auto_delete",
    { data_type => "tinyint", default_value => 0, is_nullable => 1 },
    "in_company_dir",
    { data_type => "tinyint", default_value => 1, is_nullable => 1 },
    "incominglines",
    { data_type => "tinyint", default_value => 0, is_nullable => 1 },
    "in_hud",
    { data_type => "tinyint", default_value => 0, is_nullable => 1 },
    "q_call_on_qcall",
    { data_type => "tinyint", default_value => 0, is_nullable => 0 },
    "q_dont_req_pass",
    { data_type => "tinyint", default_value => 0, is_nullable => 0 },
    "created",
    {   data_type     => "timestamp",
        default_value => \"current_timestamp",
        is_nullable   => 0,
    },
    "free_ext",
    { data_type => "tinyint", default_value => 0, is_nullable => 1 },
    "visual_only",
    { data_type => "tinyint", default_value => 0, is_nullable => 1 },
    "user_id",
    { data_type => "integer", is_nullable => 1 },
    "location",
    { data_type => "varchar", is_nullable => 1, size => 255 },
    "moh_dialargs",
    { data_type => "varchar", is_nullable => 1, size => 255 },
    "call_forwarding",
    {   data_type     => "enum",
        default_value => "no",
        extra         => { list => [ "no", "yes", "fm" ] },
        is_nullable   => 1,
    },
    "forward_after",
    { data_type => "smallint", default_value => 10, is_nullable => 1 },
    "forward_no",
    { data_type => "varchar", is_nullable => 1, size => 20 },
    "forward_return_vm",
    { data_type => "tinyint", default_value => 0, is_nullable => 1 },
);
__PACKAGE__->set_primary_key( "extension", "server_id" );

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:NjzQPgsdzmf05KaKWP5b6Q

# You can replace this text with custom content, and it will be preserved on regeneration
__PACKAGE__->has_one( user => "Fap::Model::Fcs::Backend::Result::PbxtraUser", { "foreign.user_id" => "self.user_id" }, { on_delete => undef } );

1;
