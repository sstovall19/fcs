package Fap::Model::Fcs::Ref::PaymentMethod;
use strict;


sub options {
return {
	ach=>2,
	check=>4,
	credit_card=>1,
	paypal=>5,
	wire_transfer=>3,
};
}


1;
