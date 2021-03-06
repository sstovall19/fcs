package Fap::Db::Pbxtra::Backend::Result::ServerCustomerXref;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("server_customer_xref");
__PACKAGE__->add_columns(
  "server_customer_xref_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "server_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "customer_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("server_customer_xref_id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-09 08:46:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:YZXkdJ7UtAUV5sWg4kTa6A


# You can replace this text with custom content, and it will be preserved on regeneration
1;


