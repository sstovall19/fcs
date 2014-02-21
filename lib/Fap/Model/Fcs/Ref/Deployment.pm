package Fap::Model::Fcs::Ref::Deployment;
use strict;


sub options {
return {
	dedicated_hosted=>1,
	multi_tenant_hosted=>2,
	on_premise=>3,
	software=>4,
};
}


1;
