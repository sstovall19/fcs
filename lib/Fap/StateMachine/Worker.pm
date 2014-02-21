package Fap::StateMachine::Worker;
use strict;
use Fap;
use IPC::Open3;
use IPC::Run3;

sub new {
	my ($class,%args) = @_;

	my $self = bless {
		%args
	},$class;
	if (!$self->{conf}) {
		$self->{conf} = Fap->load_conf("statemachine");
	}
	return $self;
}
sub run {
	my ($self,@args) = @_;

	my ($return,$stdin,$stdout,$stderr);
	my $run3_input;
	my $exectype;
	my $path = $self->{path}||Fap->path_to("");
	my $executable=$self->{executable}||$path."/".substr($self->{step}->{objectlocation},index($self->{step}->{objectlocation},"BU"));
	$self->{executable}||=$executable;
	my $arguments = $self->{arguments}||$self->{step}->{objectargs};
	if (!-f $executable) {
		$self->{status} = "FAILURE";
		$self->{error} = "$executable not found!";
		return $self;
	}
	$ENV{CONF_TARGET} = "$path/res/conf";
	push(@args ,"-j $self->{transaction_submit_id}");
	if ($executable=~/.jar$/i) {
		$exectype="java";
		$run3_input=[
			"$self->{config}->{java_home}/bin/java",
			"-cp",
			Fap->build_java_classpath_short($executable),
			$arguments,
			@args,

		];
	} else {
		if ($arguments) {
			$run3_input=[
				"/usr/bin/perl",
				"-I$path/lib",
				$executable,
				$arguments,
				@args,
			];
		} else {
			$run3_input=[
				"/usr/bin/perl",
				"-I$path/lib",
				$executable,
				@args,
			];
		}
	}
	if ($self->{server}) {
		$self->{server}->log(sprintf("Executing unit %s",join(" ",@$run3_input)));
	}
	$self->{run3args} = $run3_input;
	my $input=$self->{input};
	run3($run3_input,\$input,\$stdout,\$stderr);
	my $return = ($? >> 8);
	$self->{return_code} = $return;
	$return=1 if ( ($stderr=~/^open3:/) || ($return == 255) );
	$self->{status} = $self->{config}->{return_codes}->{$return}||"FAILURE";
	$self->{output} = $stdout;
	$self->{error} = $stderr;
	return $self;
}
sub rollback {
	my $self = shift;

	return $self if ($self->{step}->{sequence_name} eq "Z");
	$self->run("-r",@_);
	$self->{status} =  $self->{config}->{rollback_return_codes}->{$self->{return_code}};
	return $self;
}

sub test {
	my $self = shift;
	$self->run("-t",@_);
}



1;

