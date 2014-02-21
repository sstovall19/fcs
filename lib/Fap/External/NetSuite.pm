package Fap::External::NetSuite;

use strict;
use Fap::External::NetSuite::Client();
use Fap::External::NetSuite::Types();
use Fap::ConfLoader();
use Data::Dumper qw(Dumper);

sub new {
    my $class = shift;
    my %args  = @_;

    my $self = {};
    bless( $self, $class );
    my $config = Fap::ConfLoader->load("netsuite")->{ $args{role} || "default" }->{ ( $args{mode} eq "sandbox" ) ? "devel" : "production" };
    my $self = {
        ns => Fap::External::NetSuite::Client->new( {
                EMAIL    => $config->{user},
                ROLE     => $config->{role},
                ACCOUNT  => $config->{account},
                SANDBOX  => ( $args{mode} eq "sandbox" ) ? 1 : 0,
                DEBUG    => $args{debug} + 1,
                PASSWORD => $config->{pass},
            }
        ),
        subengine => {},

    };
    bless( $self, $class );
    $self->{error_state} = "";
    if ( $self->{'guaranteed_login'} ) {
        while ( !$self->{'ns'}->loginResults ) {
            delete( $self->{'ns'}->{'ERROR_RESULTS'} );
            $self->{'ns'}->login;
        }
    } else {
        $self->{ns}->login;
    }
    return $self;
}

sub set_error {
    my $self = shift;

    $self->{error_state} = $self->{ns}->{ERROR_DETAILS};
    return undef;
}

sub create_opportunity {
    my ( $self, %args ) = @_;

    my $res = $self->{ns}->add( "opportunity", {%args} );
    return $res;
}

sub update_opportunity {
    my ( $self, %args ) = @_;
    my $res = $self->{ns}->update( "opportuniy", {%args}, 1 );
    return $res;
}

sub delete_opportunity {
    my ( $self, $id ) = @_;

    my $res = $self->{ns}->delete( "opportunity", $id );
    return $res;
}

##############################################################
# DATA STRUCTURE FUNCTIONS                                   #
##############################################################

sub customerRef {
    return shift->recordRef( type => "customer", id => shift, @_ );
}

sub employeeRef {
    return shift->recordRef( type => "employee", id => shift, @_ );
}

sub recordRef {
    my ( $self, %args ) = @_;

    return {
        internalId => $args{id},
        type       => $args{type},
        ( $args{extra} ) ? %{ $args{extra} } : (),
    };
}

# custom fields

sub customField {
    return shift->_customField( "StringCustomFieldRef", @_ );
}

sub customMultiselect {
    return shift->_customField( "MultiSelectCustomFieldRef", @_ );
}

sub customSelect {
    return shift->_customField( "SelectCustomFieldRef", @_ );
}

sub customBool {
    return shift->_customField( "BooleanCustomFieldRef", shift, (shift) ? 'true' : 'false' );
}

sub customInt {
    return shift->_customField( "LongCustomFieldRef", shift, int(shift) );
}

sub customFloat {
    return shift->_customField( "DoubleCustomFieldRef", shift, sprintf( "%0.2f", shift ) );
}

sub _customField {
    my ( $self, $type, $name, $value ) = @_;

    my $ret = {
        internalId => $name,
        type       => "core:$type",
    };
    if ( $type eq "SelectCustomFieldRef" ) {
        $ret->{value} = { internalId => $value };
    } elsif ( $type eq "MultiSelectCustomFieldRef" ) {
        if ( ref($value) eq "ARRAY" ) {
            $ret->{value} = [ map { { internalId => $_ } } @$value ];
        } else {
            $ret->{value} = [ { internalId => $value } ];
        }
    } else {
	$ret = {name=>"customField",internalId=>$name,type=>"core:$type",value=>$value};
        #$ret->{value} = $value;
    }
    return $ret;
}

##############################################################
# UTILITY FUNCTIONS                                          #
##############################################################

sub map_args {
    my ( $self, %hash ) = @_;
}

sub parse_name {
    my ( $self, $name ) = @_;

    my @np = split( /\s/, $name );
    my $n = {
        first  => shift(@np),
        last   => pop(@np),
        middle => join( " ", @np ) };
    return $n;
}

sub hasError  { return $_[0]->{ns}->hasError(); }
sub errorMsg  { return $_[0]->{ns}->errorMsg(); }
sub errorCode { return $_[0]->{ns}->errorCode(); }

sub dumpError() {
    my $self = shift;
    print STDERR sprintf( "%s: %s\n", $self->errorCode(), $self->errorMsg() );
}

sub customField {
    my $self = shift;
    return $self->{ns}->customField(@_);
}

sub hastype {
    my ( $self, $name, $class ) = @_;

    if ( !$self->{subengine}->{$name} ) {
        $self->{subengine}->{$name} = $class->new( $self->{ns} );
    }
    return $self->{subengine}->{$name};
}
sub base         { return shift->{ns}; }
sub customer     { return shift->hastype( "customer", "Fap::External::NetSuite::Types::Customer" ); }
sub customrecord { return shift->hastype( "customrecord", "Fap::External::NetSuite::Types::CustomRecord" ); }
sub opportunity  { return shift->hastype( "opportunity", "Fap::External::NetSuite::Types::Opportunity" ); }
sub item         { return shift->hastype( "item", "Fap::External::NetSuite::Types::Item" ); }
sub contact         { return shift->hastype( "contact", "Fap::External::NetSuite::Types::Contact" ); }
sub cashsale         { return shift->hastype( "cashsale", "Fap::External::NetSuite::Types::CashSale" ); }
sub salesorder         { return shift->hastype( "salesorder", "Fap::External::NetSuite::Types::SalesOrder" ); }


1;
