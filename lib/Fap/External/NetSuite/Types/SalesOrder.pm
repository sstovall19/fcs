package Fap::External::NetSuite::Types::SalesOrder;
use base(Fap::External::NetSuite::Types::Base);
use strict;

sub type { return "salesorder"; }

sub create {
    my ( $self, %args ) = @_;

    my $rec = {
        entity   => { type => "customer", value => $args{customer} },
        itemList => $args{items},
        class => $args{class} || 25,
    };
    my $res = $self->ns->add( "salesorder", $rec );
    if ( !$res ) {
        return undef;
    }
    return $res;
}

sub update {
    my ( $self, %args ) = @_;

    return $self->ns->update( "salesorder", {%args}, 1 );
}

1;
__DATA__
