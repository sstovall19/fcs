package Fap::External::NetSuite::Types::Base;
use strict;
use Data::Dumper;

sub new {
    my ( $class, $nsobj ) = @_;

    return bless { ns => $nsobj, }, $class;
}
sub ns { return $_[0]->{ns}; }

sub get {
    my ( $self, $id ) = @_;
    return $self->ns->get( $self->type, $id );
}

sub delete {
    my ( $self, $id ) = @_;
    return $self->ns->delete( $self->type, $id );
}

sub search {
    my $self = shift;
    my %args = @_;

    my $meta = {};
    my $oth  = {};
    foreach my $pk ( keys %args ) {
        if ( $pk =~ /^pageSize|onlyBodyFields$/ ) {
            $meta->{$pk} = $args{$pk};
            delete $args{$pk};

            #} elsif ($pk=~/recordType/) {
            #$oth->{$pk} = $args{$pk};
            #delete $args{$pk};
        }
    }

    $meta->{pageSize} ||= 10;
    my @crit;
    foreach my $sc ( keys %args ) {
        if ( $sc eq "recordRef" ) {
            push( @crit, $args{$sc} );
        } else {
            my $ss = $args{$sc};
            if ( ref($ss) eq '' ) {
                $ss = { value => $ss };
                if ( $ss->{value} !~ /^true|false$/i ) { $ss->{o} = "is"; }
            }

            #if (ref($ss) eq "HASH" && scalar(keys %$ss)==1) { ($ss) = map {{o=>$_,value=>$ss->{$_}}} keys %$ss; }
            my $h = { name => $sc };
            if ( $ss->{o} ) { $h->{attr} = { operator => $ss->{o} }; }
            if ( $ss->{o} eq "anyOf" ) {
		if (ref( $ss->{value} ) ne "ARRAY" ) {
                	$h->{value} = {value=>[ $ss->{value} ]};
		} else {
			$h->{value} = $ss->{value};
		}
            } else {
                $h->{value} = $ss->{value};
            }
            push( @crit, $h );
        }
    }
    return $self->ns->search( $oth->{recordType} || $self->type, ( scalar(@crit) ) ? { basic => [@crit] } : {}, $meta );
}

1;
