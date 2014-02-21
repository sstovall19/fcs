package Fap::Model::Fcs::Backend::Result::OrderStatus;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'Fap::Model::DBIx::Result';

__PACKAGE__->table("order_status");
__PACKAGE__->add_columns(
  "order_status_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "description",
  { data_type => "mediumtext", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("order_status_id");
__PACKAGE__->add_unique_constraint("name", ["name"]);
__PACKAGE__->has_many(
  "orders_order_statuses",
  "Fap::Model::Fcs::Backend::Result::Order",
  { "foreign.order_status_id" => "self.order_status_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "orders_provisioning_statuses",
  "Fap::Model::Fcs::Backend::Result::Order",
  { "foreign.provisioning_status_id" => "self.order_status_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "orders_manager_approval_statuses",
  "Fap::Model::Fcs::Backend::Result::Order",
  { "foreign.manager_approval_status_id" => "self.order_status_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "orders_billing_approval_statuses",
  "Fap::Model::Fcs::Backend::Result::Order",
  { "foreign.billing_approval_status_id" => "self.order_status_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "orders_credit_approval_statuses",
  "Fap::Model::Fcs::Backend::Result::Order",
  { "foreign.credit_approval_status_id" => "self.order_status_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2013-01-17 11:54:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:vipZrnrvJMzua9T5w0Jk4w


# You can replace this text with custom content, and it will be preserved on regeneration
1;
