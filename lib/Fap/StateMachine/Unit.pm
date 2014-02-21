
=head1 NAME

SM::Client

=head1 DESCRIPTION

Helper class for Perl business units.

=head1 SYNOPSIS

#!/usr/bin/perl

use strict;

use SM::Client;

my $client = SM::Client->new()->run();

sub execute {
        my ($package,$client,$input) = @_;

        #
        # DOES SOME STUFF
        #
		if ($something_went_wrong) {
			$client->displayfailure("Something went wrong!");
		}

        $input->{output} = {newvalue=>4};
        return $input;
}

sub rollback {
        my ($package,$client,$input) = @_;

        #
        # ALSO DOES SOME STUFF
        #
	
        $input->{output} = {something=>"whee"};
        return $input;
}

=head1 METHODS
=cut


package Fap::StateMachine::Unit;

use strict;
use warnings;
use Fap;

use JSON::XS;
use Try::Tiny;
use File::Slurp;
use Getopt::Std;
use Sys::Hostname;
use Data::Dumper;

# Submission status codes.
use constant SUBMIT_STATUS_NEW     => 'NEW';
use constant SUBMIT_STATUS_FAILURE => 'FAILURE';
use constant SUBMIT_STATUS_SUCCESS => 'SUCCESS';
use constant SUBMIT_STATUS_RUNNING => 'RUNNING';

# BU return codes.
use constant BU_CODE_SUCCESS      => 0;
use constant BU_CODE_FAILURE      => 1;
use constant BU_CODE_SUCCESS_JAVA => 0;
use constant BU_CODE_FAILURE_JAVA => 1;
use constant BU_CODE_TIMEOUT	  => 98;
use constant BU_CODE_HALT         => 99;    # Something random that can't be confused with a return code from Perl or Java.
use constant BU_CODE_RESTART      => 88;    # Ditto.


sub new {
    my ($class) = shift;
    my $self = { _name => "" };
    my %args  = @_;

    my %opt;
    getopts( "rdetj:" => \%opt );
    bless $self, ref $class || $class;
    $self->{options} = \%opt;
    $self->{transaction_submit_id}    = $self->{options}->{j};

    my $input;
    if (defined($args{input}))
    {
      $input = $args{input};
    } else {
      $input = read_file( \*STDIN );
    }
    $self->{input} = $self->deserialize($input);
    return $self;
}

sub transaction_id {
	return shift->{transaction_id};
}

sub run {
    my $self = shift;

    $SIG{ALRM} = sub {
	$self->timedout();
    };

    my $timeout = 180;
    if (defined main->can("max_execution_time")) {
	$timeout = main->max_execution_time;
    }
    my $output;
    my $function;
    if ( $self->options->{r} ) {
        $function = "rollback";
    } else {
	 $function = "execute";
    }
    if ( !defined main->can($function) ) {
        $self->displayfailure("Unit $0: '$function' undefined");
    } else {
	alarm($timeout);
	my $ret;
	$ret = main->$function( $self, $self->input);
	unless ($ret) {
		$self->displayfailure("WUT".$@);
	}
	$self->displaysuccess($ret);
    }
}

sub timedout {
	my ($self) = @_;

	$self->displayfailure("Request Timed Out",BU_CODE_TIMEOUT);

}

sub serialize {
    my ( $self, $data ) = @_;

    try {
        return JSON::XS->new->utf8->pretty->allow_nonref->encode($data);
    }
    catch {
        $self->displayfailure("Unable to serialize: $_");
    };
}

sub deserialize {
    my ( $self, $data ) = @_;

    try {
        return JSON::XS->new->utf8->pretty->allow_nonref->decode($data);
    }
    catch {
        $self->displayfailure("Unable to deserialize: $_");
    };
}

sub display {
    my ( $self, $handle, $data ) = @_;
    print $handle $self->serialize($data);
}

sub displaysuccess {
    my ($self)     = shift;
    my ($data)     = shift;
    my ($exitCode) = shift||0;
    $self->display( \*STDOUT, $data );
    exit($exitCode);
}

=head2 displaysuccessRestart($output)

=over 4

Places the transaction into the 'PAUSE' state.

Tells the SM to pick up that the transaction is ready to be reprocessed
at the sequence after it's last completed job.

=back

=cut

sub displaysuccessRestart {
    my ($self) = shift;
    return $self->displaysuccess( @_, BU_CODE_RESTART );
}

=head2 displaysuccessHalt($output)

=over 4

Places the transaction into the 'HALT' state.

Tells the SM to stop processing a transaction indefinitely.

=back

=cut

sub displaysuccessHalt {
    my ($self) = shift;
    return $self->displaysuccess( @_, BU_CODE_HALT );
}

sub displayfailure {
    my ( $self, $data,$code ) = @_;
    $self->display( \*STDERR, $data );
    exit($code||BU_CODE_FAILURE);
}

sub name {
    my $self = shift;
    my $opt  = shift;
    $self->{_name} = $opt if defined $opt;
    return $self->{_name} || undef;
}

sub options { return shift->{options}; }
sub input   { return shift->{input}; }

1;

__DATA__
