package Fap::Model::Cache::Memory;
use strict;

use Cache::Memcached;
use Fap;

sub new {
    my ( $class, $conf ) = @_;

    $conf ||= Fap->load_conf("cache/memcached");
    my $self = bless { conf => $conf, }, $class;

    my $servers =
      ( Fap->is_development_environment() )
      ? $conf->{servers}->{devel}
      : $conf->{servers}->{production};

    $self->{cache} = Cache::Memcached->new( {
            servers => $servers,
            debug   => 0,
        } );
    return $self;
}

sub get {
    my $self = shift;

    return $self->{cache}->get(@_);
}

sub set {
    my $self = shift;

    return $self->{cache}->set(@_);
}

sub increment {
    my ( $self, $key, $by ) = @_;

    my $ret = $self->{cache}->incr( $key, $by );
    if ( !defined $ret ) {
        $ret = $self->set( $key, $by || 1 );
    }
    return $ret;
}

sub decrement {
    my ( $self, $key, $by ) = @_;

    my $ret = $self->{cache}->decr( $key, $by );
    if ( !defined $ret ) {
        $ret = $self->set( $key, 0 );
    }
    return $ret;
}

sub delete {
    my $self = shift;

    return $self->{cache}->delete(@_);
}

1;
