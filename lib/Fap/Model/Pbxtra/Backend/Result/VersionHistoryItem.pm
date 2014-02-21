package Fap::Model::Pbxtra::Backend::Result::VersionHistoryItem;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("version_history_item");
__PACKAGE__->add_columns(
    "id",                 { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
    "version_history_id", { data_type => "integer", is_foreign_key    => 1, is_nullable => 1 },
    "version_item_id",    { data_type => "integer", is_foreign_key    => 1, is_nullable => 1 },
    "edition",            { data_type => "varchar", is_nullable       => 1, size        => 20 },
    "category",           { data_type => "varchar", is_nullable       => 1, size        => 20 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to(
    "version_item",
    "Fap::Model::Pbxtra::Backend::Result::VersionItem",
    { id => "version_item_id" },
    {   is_deferrable => 1,
        join_type     => "LEFT",
        on_delete     => "CASCADE",
        on_update     => "CASCADE",
    },
);

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-20 13:26:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:mbWmfW42xjUfJIYtYMyYSA

# You can replace this text with custom content, and it will be preserved on regeneration
1;
