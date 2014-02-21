package Fap::Model::Pbxtra::Backend::Result::UserExtThirdpartyCredential;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("user_ext_thirdparty_credentials");
__PACKAGE__->add_columns(
    "id", { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
    "server_id",  { data_type => "integer", is_nullable => 1 },
    "user_id",    { data_type => "integer", is_nullable => 1 },
    "account_id", { data_type => "varchar", is_nullable => 1, size => 255 },
    "login",      { data_type => "varchar", is_nullable => 1, size => 255 },
    "password",   { data_type => "varchar", is_nullable => 1, size => 255 },
    "options",    { data_type => "text",    is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint( "ids", [ "server_id", "user_id", "account_id" ] );

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:l2DOLLaKIYkpKM8EZp3nmw

# You can replace this text with custom content, and it will be preserved on regeneration
1;
