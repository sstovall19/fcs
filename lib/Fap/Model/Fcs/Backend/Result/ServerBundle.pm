package Fap::Model::Fcs::Backend::Result::ServerBundle;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("server_bundle");
__PACKAGE__->add_columns(
  "server_bundle_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "server_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "bundle_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "created",
  {
    data_type     => "timestamp",
    default_value => "1970-01-01 00:00:00",
    is_nullable   => 0,
  },
);
__PACKAGE__->set_primary_key("server_bundle_id");
__PACKAGE__->add_unique_constraint("server_id", ["server_id", "bundle_id"]);
__PACKAGE__->belongs_to(
  "bundle",
  "Fap::Model::Fcs::Backend::Result::Bundle",
  { bundle_id => "bundle_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-01-17 11:54:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8RALLb38FDJ2n5AFGXXBog


sub column_defaults {
   return {
      created=>\'NULL',
   }
}



# Defined manually to allow a join across server_bundle -> bundle -> bundle_license
__PACKAGE__->has_many(
  bundle_license => "Fap::Model::Fcs::Backend::Result::BundleLicense",
  { "foreign.bundle_id" => "self.bundle_id" },
   { cascade_copy => 0, cascade_delete => 0 }   
);

# You can replace this text with custom content, and it will be preserved on regeneration
1;
