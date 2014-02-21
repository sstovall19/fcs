package Fap::Model::Fcs::Ref::OrderStatus;
use strict;


sub options {
return {
	not_required=>1,
	approved=>2,
	billed=>3,
	cancelled=>4,
	closed=>5,
	error=>6,
	in_progress=>7,
	in_provisioning=>8,
	new=>9,
	partially_provisioned=>10,
	pending=>11,
	provisioned=>12,
	rejected=>17,
	required=>18,
};
}


1;
