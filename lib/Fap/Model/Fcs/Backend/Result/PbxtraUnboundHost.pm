package Fap::Model::Fcs::Backend::Result::PbxtraUnboundHost;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

=head1 NAME

Fap::Db::Pbxtra::Backend::Result::UnboundHost

=cut

__PACKAGE__->table("pbxtra.unbound_hosts");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 server_id

  data_type: 'integer'
  is_nullable: 0

=head2 server_type

  data_type: 'varchar'
  is_nullable: 0
  size: 20

=head2 location

  data_type: 'varchar'
  default_value: 'LA'
  is_nullable: 1
  size: 5

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "server_id",
  { data_type => "integer", is_nullable => 0 },
  "server_type",
  { data_type => "varchar", is_nullable => 0, size => 20 },
  "location",
  { data_type => "varchar", default_value => "LA", is_nullable => 1, size => 5 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-11-20 20:40:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:vYUx9H6Vvnik5Ai3DsUU8A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
