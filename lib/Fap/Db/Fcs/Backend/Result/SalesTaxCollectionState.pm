package Fap::Db::Fcs::Backend::Result::SalesTaxCollectionState;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("sales_tax_collection_state");
__PACKAGE__->add_columns("state", { data_type => "char", is_nullable => 0, size => 2 });
__PACKAGE__->set_primary_key("state");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-15 11:40:01
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:c2RohojUvttT8TOnyXxDxA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
