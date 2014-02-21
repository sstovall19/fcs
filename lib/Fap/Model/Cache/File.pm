package Fap::Model::Cache::File;
use strict;

use Cache::FileCache;
use Fap;

sub new {
    my ( $class, $conf ) = @_;

    my $conf = $conf || Fap->load_conf("cache/file");
    my $self = bless { conf => $conf, }, $class;
    $self->{cache} = Cache::FileCache->new( { cache_root => $conf->{cache_root}, } );
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

    my $value = $self->get($key) || 0;
    $value += $by || 1;
    $self->set( $key, $value );
    return $value;
}

sub decrement {
    my ( $self, $key, $by ) = @_;

    my $value = $self->get($key) || 0;
    $value -= $by || 1;
    $value = 0 if ( $value < 0 );
    $self->set( $key, $value );
    return $value;
}

sub delete {
    my $self = shift;

    return $self->{cache}->remove(@_);
}

1;
