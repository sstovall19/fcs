package Fap::StateMachine::Client;
use strict;
use Fap;
use IO::Socket;
use JSON::XS;
use Data::Dumper;
use Try::Tiny;
use Fap::StateMachine;

sub new {
	my ($class,%args) = @_;
	my $self =  bless {
		json=>JSON::XS->new->utf8->allow_nonref->shrink,
		conf=>Fap::StateMachine->load_conf
	},$class;
	foreach my $k (keys %args) {
		$self->{conf}->{$k} = $args{$k};
	}
	return $self;
}
sub ping {
        return shift->call("ping",{});
}
sub submit_transaction {
	my ($self,$family,$order) = @_;
	if ($order=~/\n/) {
		$order=~s/\n//;
	}
	return $self->call("submit_transaction",input=>$order,familyname=>$family);
}
sub clear_transaction {
	my ($self,$guid) = @_;

        return $self->call("clear_transaction",guid=>$guid);
}

sub submit_and_run_transaction {
	my ($self,$family,$order,$path) = @_;
        if ($order=~/\n/) {
                $order=~s/\n//;
        }
        return $self->call("submit_and_run_transaction",input=>$order,familyname=>$family,run_now=>1,path=>$path);
}
sub run_transaction {
	my ($self,$guid,$path) = @_;

	return $self->call("run_transaction",guid=>$guid,path=>$path);
}
sub run_transaction_monitored {
	my ($self,$guid,$path) = @_;
	
	return $self->call("run_transaction",guid=>$guid,monitor=>1,path=>$path);
}
sub run_transaction_again {
	my ($self,$guid,$path) = @_;

	return $self->call("run_transaction",guid=>$guid,restart_failed=>1,path=>$path);
}
sub restart_transaction {
	return shift->run_transaction(@_);
}
sub get_transaction_status {
	my ($self,$guid) = @_;

	return $self->call("get_transaction_status",guid=>$guid);
}

sub get_steps {
	my ($self,$family) = @_;

	return $self->call("get_steps",family=>$family);
}

sub call {
	my ($self,$action,%args) = @_;

	my $sock = IO::Socket::INET->new(
		PeerAddr=>$self->{conf}->{host},
		Type=>SOCK_STREAM,
		PeerPort=>$self->{conf}->{port},
	);
	my @ret;
	$self->{debug} = $args{monitor};
	my $line;
	my $decoded;
	if ($sock && $sock->connected) {
		$args{action} = $action;
		my $payload = $self->{json}->encode({%args})."\n";
		$sock->write($payload,length($payload));
		while ($line = $sock->getline) {
			
			try {
                		$decoded = $self->{json}->decode($line);#join("",@ret));
        		} catch {
				print STDERR "$_\n";
                		$decoded = {};
        		};
			if ($self->{debug}) {
				if ($decoded->{error}) {
					$decoded->{error}=~s/\\n/\n/g;
					print STDERR $decoded->{error};
				} else {
					print STDERR $line;
				}
				
			}
		}
	} else {
		$decoded={status=>0,msg=>"Unable to reach state machine!"};
	}
	return $decoded;
}
	
1;
