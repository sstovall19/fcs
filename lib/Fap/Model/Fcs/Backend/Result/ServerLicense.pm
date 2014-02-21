package Fap::Model::Fcs::Backend::Result::ServerLicense;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

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
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "license_type_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "qty",
  { data_type => "integer", default_value => 1, is_nullable => 0 },
  "created",
  {
    data_type     => "timestamp",
    default_value => "1970-01-01 00:00:00",
    is_nullable   => 0,
  },
);
__PACKAGE__->set_primary_key("server_license_id");
__PACKAGE__->belongs_to(
  "license_type",
  "Fap::Model::Fcs::Backend::Result::LicenseType",
  { license_type_id => "license_type_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-01-17 11:54:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:WQyPJPGt6VnlgtD7OyaccQ


sub column_defaults {
   return {
      created=>\'NULL',
   }
}



# You can replace this text with custom content, and it will be preserved on regeneration
1;
