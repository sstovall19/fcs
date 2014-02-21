package Fap::External::NetSuite::Types::CashSale;
use base(Fap::External::NetSuite::Types::Base);
use strict;

sub type { return "cashSale"; }

sub create {
    my ( $self, %args ) = @_;

    my $rec = {
        itemList => $args{items},
	chargeIt=>($args{test})?'false':'true',
	toBeEmailed=>'false',
	entity=>{type=>"customer",value=>$args{netsuite_lead_id}},
	account=>$args{account},
	email=>$args{email},
	#ccApproved=>'true',
	creditCard=>$args{netsuite_card_id},
	memo=>$args{memo},
	shipAddress=>'735 West Fake Street\nLos Angeles, CA 90034\nUSA',
	location=>20,
	class=>'44',
    };
    if ($args{opportunity}) {
	$rec->{opportunity} = {type=>"opportunity",value=>$args{opportunity}};
    }
    my $res = $self->ns->add( "cashSale", $rec );
    if ( !$res ) {
        return undef;
    }
    return $res;
}

sub update {
    my ( $self, %args ) = @_;

    return $self->ns->update( "cashSale", {%args}, 1 );
}

1;
__DATA__
