package Fap::Model::Hus::Backend::Result::HudEdition;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("hud_edition");
__PACKAGE__->add_columns(
    "id",   { data_type => "varchar", default_value => "", is_nullable => 0, size => 4 },
    "name", { data_type => "varchar", default_value => "", is_nullable => 0, size => 45 },
    "definition", { data_type => "text", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-12-18 13:09:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ZDzdQEx/LK8WzRKa1fC+ew

# You can replace this text with custom content, and it will be preserved on regeneration
1;
