package Fap::Model::DBIx::Auth;
use strict;
use Fap;
use Sys::Hostname;
use Time::HiRes;

sub new {
    my ( $class, %args ) = @_;

    my $config   =$args{config}||Fap->load_conf("database/main");
    my $hostname = Sys::Hostname::hostname();
    if ( $config->{databases}->{$hostname} && !$args{server} ) {
        $args{server} = $hostname;
    } elsif ( !$args{server} ) {
        $args{server} = "default";
    }
    my $self = {};
    my $db   = "production";
    if ( defined $ENV{FAP_DB_SWITCH} ) {
        if ( $config->{databases}->{ $args{server} }->{ $ENV{FAP_DB_SWITCH} } ) {
            $db = $ENV{FAP_DB_SWITCH};
        } else {
            $db = ( $class->is_dev( $hostname, $args{mode} ) ) ? "devel" : "production";
        }
    } elsif ($args{switch}) {
	$db = $args{switch};
    } else {
        $db = ( Fap->is_development_environment( $args{mode}, $hostname ) ) ? "devel" : "production";
    }
    $self->{db}    = $config->{databases}->{ $args{server} }->{$db};
    $self->{cache} = $config->{memcached}->{$db};

    return bless $self, $class;
}
sub host          { return $_[0]->{db}->{host}; }
sub user          { return $_[0]->{db}->{user}; }
sub pass          { return $_[0]->{db}->{pass}; }
sub cache_servers { return $_[0]->{cache}; }

sub dsn {
    my $self = shift;
    my $dbn  = shift;

    return sprintf( $self->{db}->{dsn_mask}, $dbn, $self->host );
}

1;
__DATA__
