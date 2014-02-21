package Fap::Model::Fcs::Ref::DiscountType;
use strict;


sub options {
return {
	discretionary=>1,
	pre_pay=>9,
	promotion=>2,
	reseller_calling_plan=>6,
	reseller_hardware=>4,
	reseller_services_and_fees=>7,
	reseller_software=>3,
	reseller_support=>5,
	volume=>8,
};
}


1;
