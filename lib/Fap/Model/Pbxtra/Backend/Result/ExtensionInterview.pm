package Fap::Model::Pbxtra::Backend::Result::ExtensionInterview;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("extension_interviews");
__PACKAGE__->add_columns(
    "extension_interview_id",
    { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
    "order_header_id",
    { data_type => "integer", is_nullable => 1 },
    "creation_date",
    {   data_type     => "datetime",
        default_value => "0000-00-00 00:00:00",
        is_nullable   => 0,
    },
    "deleted",
    { data_type => "integer", is_nullable => 1 },
    "extension_name",
    { data_type => "varchar", is_nullable => 1, size => 255 },
    "extension_value",
    { data_type => "varchar", is_nullable => 1, size => 255 },
    "ported",
    { data_type => "integer", default_value => 0, is_nullable => 0 },
    "provisioned",
    { data_type => "integer", default_value => 0, is_nullable => 0 },
    "item_type",
    { data_type => "varchar", is_nullable => 1, size => 255 },
    "netsuite_internal_id",
    { data_type => "varchar", is_nullable => 1, size => 55 },
    "parent_extension",
    { data_type => "varchar", is_nullable => 1, size => 10 },
    "addon",
    { data_type => "char", default_value => 0, is_nullable => 1, size => 1 },
    "call_center_agent",
    { data_type => "char", default_value => 0, is_nullable => 1, size => 1 },
    "mobility",
    { data_type => "char", default_value => 0, is_nullable => 1, size => 1 },
    "extension_no",
    { data_type => "varchar", is_nullable => 1, size => 10 },
);
__PACKAGE__->set_primary_key("extension_interview_id");

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:TBhXJHL8afFWPG0H1nT21A

# You can replace this text with custom content, and it will be preserved on regeneration
1;
