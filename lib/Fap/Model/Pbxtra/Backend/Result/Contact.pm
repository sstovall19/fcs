package Fap::Model::Pbxtra::Backend::Result::Contact;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("contact");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "customer_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "address_id",
  { data_type => "integer", is_nullable => 1 },
  "want_tech_updates",
  { data_type => "integer", default_value => 1, is_nullable => 0 },
  "want_general_updates",
  { data_type => "integer", default_value => 1, is_nullable => 0 },
  "is_admin_primary",
  { data_type => "tinyint", is_nullable => 1 },
  "is_admin",
  { data_type => "tinyint", is_nullable => 1 },
  "is_tech_primary",
  { data_type => "tinyint", is_nullable => 1 },
  "is_tech",
  { data_type => "tinyint", is_nullable => 1 },
  "last_name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "first_name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "email1",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "email2",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "phone1",
  { data_type => "bigint", is_nullable => 1 },
  "phone2",
  { data_type => "bigint", is_nullable => 1 },
  "mobile",
  { data_type => "bigint", is_nullable => 1 },
  "text_device",
  { data_type => "bigint", is_nullable => 1 },
  "fax",
  { data_type => "bigint", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-01-31 17:25:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:AYYvW4/kQstQi+PHUDdCbA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
