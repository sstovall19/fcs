package Fap::Model::Pbxtra::Backend::Result::BundleRelationship;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("bundle_relationships");
__PACKAGE__->add_columns(
    "id",
    {   data_type         => "integer",
        extra             => { unsigned => 1 },
        is_auto_increment => 1,
        is_nullable       => 0,
    },
    "bundle_id",
    { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
    "product_id",
    { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
    "provides_bundle_id",
    { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
    "provides_bundle_id_multiplier",
    { data_type => "decimal", is_nullable => 1, size => [ 3, 1 ] },
    "disables_bundle_id",
    { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
    "enables_bundle_id",
    { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
    "sets_max_bundle_id",
    { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
    "sets_max_bundle_id_multiplier",
    { data_type => "decimal", is_nullable => 1, size => [ 3, 1 ] },
    "sets_min_bundle_id",
    { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
    "sets_min_bundle_id_multiplier",
    { data_type => "decimal", is_nullable => 1, size => [ 3, 1 ] },
    "requires_bundle_id",
    { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
    "requires_bundle_id_multiplier",
    { data_type => "decimal", is_nullable => 1, size => [ 3, 1 ] },
    "disables_bundle_id_message",
    { data_type => "varchar", is_nullable => 1, size => 255 },
);
__PACKAGE__->set_primary_key("id");

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:3HzgQf8acO/5cQizgIMTFg

# You can replace this text with custom content, and it will be preserved on regeneration
1;
