package Fap::Model::Pbxtra::Backend::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("user");
__PACKAGE__->add_columns(
    "user_id",              { data_type => "integer", is_auto_increment => 1,  is_nullable => 0 },
    "customer_id",          { data_type => "integer", default_value     => 0,  is_nullable => 0 },
    "extension",            { data_type => "varchar", is_nullable       => 1,  size        => 255 },
    "username",             { data_type => "varchar", default_value     => "", is_nullable => 0, size => 255 },
    "password",             { data_type => "varchar", is_nullable       => 1,  size        => 40 },
    "first_name",           { data_type => "varchar", is_nullable       => 1,  size        => 255 },
    "last_name",            { data_type => "varchar", is_nullable       => 1,  size        => 255 },
    "type",                 { data_type => "varchar", is_nullable       => 1,  size        => 30 },
    "help_rollover",        { data_type => "integer", default_value     => 1,  is_nullable => 1 },
    "language",             { data_type => "varchar", is_nullable       => 1,  size        => 20 },
    "employee_email",       { data_type => "varchar", is_nullable       => 1,  size        => 99 },
    "employee_im",          { data_type => "varchar", is_nullable       => 1,  size        => 99 },
    "employee_phonenumber", { data_type => "varchar", is_nullable       => 1,  size        => 40 },
    "humor_rollover",       { data_type => "integer", default_value     => 0,  is_nullable => 1 },
    "default_server_id",  { data_type => "integer",  is_nullable => 1 },
    "sms_gateway",        { data_type => "varchar",  is_nullable => 1, size => 255 },
    "feature_components", { data_type => "varchar",  is_nullable => 1, size => 255 },
    "hud_password",       { data_type => "varchar",  is_nullable => 1, size => 40 },
    "foncall_password",   { data_type => "varchar",  is_nullable => 1, size => 40 },
    "password_expiry",    { data_type => "datetime", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("user_id");
__PACKAGE__->has_many(
    "user_licenses",
    "Fap::Model::Pbxtra::Backend::Result::UserLicense",
    { "foreign.user_id" => "self.user_id" },
    { cascade_copy      => 0, cascade_delete => 0 },
);

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:xgp3KD62N+JbHmZfT2kGww

# You can replace this text with custom content, and it will be preserved on regeneration
__PACKAGE__->has_one( server => "Fap::Model::Fcs::Backend::Result::PbxtraServerUserXref", { "foreign.user_id" => "self.user_id" }, { on_delete => undef } );

1;
