package Fap::Model::Pbxtra::Backend::Result::BundleFeature;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("bundle_features");
__PACKAGE__->add_columns(
    "bundle_id",
    {   data_type      => "integer",
        default_value  => 0,
        is_foreign_key => 1,
        is_nullable    => 0,
    },
    "feature_id",
    {   data_type      => "integer",
        default_value  => 0,
        is_foreign_key => 1,
        is_nullable    => 0,
    },
    "date_entered",
    {   data_type     => "timestamp",
        default_value => \"current_timestamp",
        is_nullable   => 0,
    },
);
__PACKAGE__->set_primary_key( "bundle_id", "feature_id" );
__PACKAGE__->belongs_to(
    "bundle",
    "Fap::Model::Pbxtra::Backend::Result::Bundle",
    { bundle_id     => "bundle_id" },
    { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:UrEQGIpFAjgLSIOR72/w3A

# You can replace this text with custom content, and it will be preserved on regeneration
1;
