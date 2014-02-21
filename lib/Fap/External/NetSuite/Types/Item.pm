package Fap::External::NetSuite::Types::Item;
use base(Fap::External::NetSuite::Types::Base);
use strict;

sub type { return "item"; }

sub create {
    my ( $self, %args ) = @_;

    my $customer = {
        entityId        => $args{entityId},
        companyName     => $args{companyName},
        email           => $args{email},
        phone           => $args{phone},
        externalId      => $args{externalId},
        url             => $args{url},
        salesRep        => $args{salesRep},
        entityStatus    => 7,
        addressbookList => $args{addressbook},
    };
    if ( $args{contact} ) {
        $customer->{contactList} = [ $args{contact} ];
    }
    if ( $args{customFields} ) {
        $customer->{customFieldList} = $args{customFields};
    }

    #if ($args{reseller_id}) {
    #$customer->{parent} = {value=>$args{reseller_id},type=>"customer"};
    #}

    my $res = $self->{ns}->add( $self->type, $customer );
    if ( !$res ) {
        return undef;
    }
    return $res;
}

sub update {
    my ( $self, %args ) = @_;

    return $self->ns->update( $self->type, {%args}, 1 );
}

1;
__DATA__
