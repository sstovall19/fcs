package Fap::Model::Pbxtra::Backend::Result::IntranetUserPermissionXref;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("intranet_user_permission_xref");
__PACKAGE__->add_columns(
    "id", { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
    "user_id",       { data_type => "integer", is_nullable   => 0 },
    "permission_id", { data_type => "integer", is_nullable   => 0 },
    "level",         { data_type => "char",    default_value => "r", is_nullable => 0, size => 1 },
);
__PACKAGE__->set_primary_key("id");

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:bXkTb6N5JVqaskBYzHEiPA

# You can replace this text with custom content, and it will be preserved on regeneration
1;
