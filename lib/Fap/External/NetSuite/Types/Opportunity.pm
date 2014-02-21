package Fap::External::NetSuite::Types::Opportunity;
use base(Fap::External::NetSuite::Types::Base);
use strict;

sub type { return "opportunity"; }

sub create {
    my ( $self, %args ) = @_;

    my $rec = {
        entity   => { type => "customer", value => $args{customer} },
        itemList => $args{items},
        class => $args{class} || 25,
    };
    my $res = $self->ns->add( "opportunity", $rec );
    if ( !$res ) {
        return undef;
    }
    return $res;
}

sub update {
    my ( $self, %args ) = @_;

    return $self->ns->update( "opportunity", {%args}, 1 );
}

1;
__DATA__
