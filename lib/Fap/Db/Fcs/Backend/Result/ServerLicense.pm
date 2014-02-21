package Fap::Db::Fcs::Backend::Result::ServerLicense;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("server_license");
__PACKAGE__->add_columns(
  "server_license_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "server_id",
  { data_type => "integer", is_nullable => 1 },
  "license_type_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "qty",
  { data_type => "integer", default_value => 1, is_nullable => 0 },
  "date_entered",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
);
__PACKAGE__->set_primary_key("server_license_id");
__PACKAGE__->belongs_to(
  "license_type",
  "Fap::Db::Fcs::Backend::Result::LicenseType",
  { license_type_id => "license_type_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-13 10:37:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:RVXEkyz283tSwwgJL8QfhA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
