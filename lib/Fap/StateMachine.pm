package Fap::StateMachine;
use base qw(Net::Server::Fork);
use strict;
use Fap;
use Fap::Model::Fcs;
use Fap::Model::Cache;
use Fap::StateMachine::Actions;
use JSON::XS;
use Data::UUID;
use Try::Tiny;

sub process_request {
        my $self = shift;

	my $input = $self->deserialize($self->client->getline);
	if (!$input) {
		$self->quit({status=>0,msg=>"Malformed JSON"});
	}
	my $action = $input->{action};
	if ($self->{conf}->{deferred}->{$action} && !$input->{monitor}) {
		$self->respond({status=>1,message=>"Running Deferred"});
		$self->{deferred}=1;
		$self->{input} = $input;
	} else {
		$self->execute($input);
	}
}

sub execute {
	my ($self,$input) = @_;

	my $function = $input->{action};
	$self->log("Executing $function");
	if ($self->{handler}->can($function)) {
		my $ret = $self->{handler}->$function($input);
		if (defined $ret) {
			$self->respond($ret);
		}
	} else {
		$self->quit({status=>0,message=>"'$function' is not a valid task."});
	}
}
sub respond {
	my ($self,$response) = @_;

	if (!$self->{deferred}) {
		print $self->serialize($response)."\n";
	} else {
		$self->log($self->serialize($response)."\n");
	}
}
sub quit {
	my $self = shift;
	$self->respond(@_);
}
sub post_client_connection_hook {
        my $self = shift;

	if ($self->{deferred}) {
		$self->execute($self->{input},0);
	}
}


sub post_configure_hook {
        my $self = shift;

        $self->{db} = Fap::Model::Fcs->new();
	$self->{json} =  JSON::XS->new->utf8->allow_nonref->shrink;
	$self->{cache} = Fap::Model::Cache->new();
	$self->{conf} = $self->load_conf();
	$self->{handler}  = Fap::StateMachine::Actions->new($self);
	$self->{units} = [];
	chmod(0666,$self->{conf}->{pidfile});
        chmod(0666,$self->{conf}->{logfile});
	$self->load_families();
}

sub pre_loop_hook {
	my $self = shift;

}

sub pre_server_close_hook {
	my $self = shift;

	#unlink($self->{conf}->{logfile});
}

sub load_families {
	my($self) = @_;

        my $hash={};
        foreach my $f ($self->db->table("TransactionStep")->search({},{order_by=>['sequence_name']})->all) {
                if (!$hash->{$f->familyname}) {
                        $hash->{$f->familyname} = {sequence=>{},steps=>[]};
                }
                my $it = scalar(@{$hash->{$f->familyname}->{steps}});
		my $stripped = $f->strip;
                push(@{$hash->{$f->familyname}->{steps}},$f->strip);
                $hash->{$f->familyname}->{sequence}->{$f->sequence_name} = $it;
        }
        $self->{families} = $hash;
}

sub db { return shift->{db}; }
sub conf {
	my ($self,$key) = @_;
	if ($key) {
		return $self->{conf}->{$key};
	}
	return $self->{conf};
}
sub client {
	return shift->{server}->{client};
}
sub serialize {
	my ($self,$object) = @_;

	return $self->{json}->encode($object);
}
sub deserialize {
	my ($self,$json) = @_;
	
	try {
		return $self->{json}->decode($json);
	} catch {
		return undef;
	};
}
sub log {
	my ($self,$ll,$msg) = @_;

	if (!$msg) {
		$msg=$ll;
		$ll = 1;
	}

	my $df = localtime(time);
	$self->SUPER::log($ll,sprintf("[%s%s] %s ",$df,($self->{guid})?" - $self->{guid}":"",$msg));
}
sub load_conf {
        my $conf;
        if ($ENV{FCS_TEST}) {
                $conf = Fap->load_conf("statemachine_test");
        } else {
                $conf = Fap->load_conf("statemachine");
        }
        return $conf;
}

1;
