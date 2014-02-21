package Fap::StateMachine::Actions;
use strict;
use JSON::XS;
use Data::Dumper;
use Fap::StateMachine::Worker;

sub new {
	my ($self,$server) = @_;

	return bless {server=>$server};
}

sub submit_and_run_transaction {
	my ($self,$input) = @_;

	$input->{run_now} = 1;
	$self->submit_transaction($input);
}

	

sub submit_transaction {
	my ($self,$input) = @_;

	my $guid=$input->{guid}||$self->{server}->{guid};
	if (!$self->{server}->{families}->{$input->{familyname}}) {
		return {status=>0,message=>"No such family '$input->{familyname}'"};
	}
	my $record = $self->{server}->{db}->table("TransactionSubmit")->create({
		familyname=>$input->{familyname},
		input=>$input->{input},
		status=>'NEW',
		created=>\'now()',
	});
	$guid = $record->transaction_submit_id;
	if ($input->{monitor} || $input->{run_now}) {
		return $self->run_transaction({guid=>$guid,sub=>$record});
	} else {
		return {status=>1,guid=>$guid};
	}
}

sub run_transaction {
	my ($self,$input) = @_;

	my $transaction = $input->{sub};
	my $path = $input->{path};
	my $db =  $self->{server}->{db};
	if (!$transaction) {
		$transaction = $db->table("TransactionSubmit")->find({transaction_submit_id=>$input->{guid}});
	}
	if (!$transaction) {
		return {status=>0,message=>"Transaction not found!"};
	}
	if ($transaction->status eq "FAILURE") {
		if (!$input->{restart_failed}) {
			return {status=>1,message=>"Transaction completed with status ".$transaction->status};
		}
	}
	if ($transaction->status eq "SUCCESS") {
		return {status=>1,message=>"Transaction completed with status ".$transaction->status};
	}
	if ($transaction->status eq "RUNNING") {
		return {status=>1,message=>"Transaction Running."};
	}
		
	my $trans_steps = $self->{server}->{families}->{$transaction->familyname};
	my $index=0;
	my $sequence=[];
	my $unit_input;
	my $last_status;
	my $last_run;
	if ($input->{restart_failed}) {
		$db->table("TransactionJob")->search({transaction_submit_id=>$input->{guid}})->delete;
	} else {
		$last_run =  $db->table("TransactionJob")->search({transaction_submit_id=>$input->{guid},sequence_name=>{"!="=>"Z"}},{order_by=>{-desc=>"sequence_name"}})->first;
	}
	if ($last_run) {
		if ($last_run->status=~/^HALTED|NEW|RESTART|FAILURE$/) {
			$index = $trans_steps->{sequence}->{$last_run->sequence_name};
			$unit_input = $last_run->input;
		} elsif ($last_run->status eq 'SUCCESS') {
			$index = $trans_steps->{sequence}->{$last_run->sequence_success};
			$unit_input = $last_run->output;
		}
	} else {
		$unit_input = $transaction->input;
	}
	my $continue=1;
	$transaction->status("RUNNING");
	$transaction->update();
	while ($continue) {
		my $step = $trans_steps->{steps}->[$index];
		my $job;
		if (!$last_run) {
			$job = $db->table("TransactionJob")->create({
				transaction_submit_id=>$transaction->transaction_submit_id,
				transaction_step_id=>$step->{transaction_step_id},
				sequence_name=>$step->{sequence_name},
				input=>$unit_input,
				output=>'',
				error=>'',
				status=>'RUNNING',
			});
		} else {
			$job = $last_run;
			undef $last_run;
		}
		my $worker = Fap::StateMachine::Worker->new(
			input=>$unit_input,
			step=>$step,
			job=>$job,
			config=>$self->{server}->{conf},
			server=>$self->{server},
			transaction_submit_id=>$transaction->transaction_submit_id,
			path=>$path,
		);
		my $start = time();
		push(@$sequence,$worker);
		my $iterations=0;
		my $retry_unit = 1;
		while ($retry_unit && $iterations<$step->{iterations}) {
			$worker->run();
			$job->set_columns({
				status=>$worker->{status},
				output=>$worker->{output},
				error=>$worker->{error},
				iterations=>$worker->{iterations},
				updated=>\'now()',
				execution_time=>time()-$start,
			});
			$job->update();
		 	my $resp = {sequence=>$job->sequence_name,guid=>$input->{guid},objectname=>$step->{objectname},status=>$job->status};
			if ($job->status=~/^FAILURE|SUCCESS$/ && $transaction->status ne "FAILURE") {
				$transaction->status($job->status);
			} elsif ($job->status eq "TIMEOUT") {
				$iterations++;
				if ($iterations>$job->iterations) {
					$transaction->status("FAILURE");
					$index = -1;
					$retry_unit=0;
				}
			} elsif ($job->status eq "HALTED") {
				$transaction->status("HALTED");
				$retry_unit=0;
			}
			if ($job->status eq "SUCCESS" && $worker->{output}) {
				$index = $trans_steps->{sequence}->{$step->{sequence_success}}||-1;
				$unit_input = $worker->{output};
				$retry_unit=0;
			} elsif ($job->status eq "FAILURE") {
				$transaction->status("FAILURE");
				$unit_input = JSON::XS->new->encode({
					error_message=>sprintf("%s\n%s",$worker->{executable},$worker->{error}),
					error_module=>ucfirst(lc($transaction->familyname))
				});
				$index = $trans_steps->{sequence}->{$step->{sequence_failure}}||-1;
				$resp->{error} = $worker->{error};
				$retry_unit=0;
			} elsif ($job->status eq "HALTED") {
				$index=-1;
				$retry_unit=0;
			}
			$self->respond($resp);
			$continue=0 if ($index<1);
		}
	}
	$transaction->update();
	if ($transaction->status eq "FAILURE") {
		foreach my $worker (reverse(@$sequence)) {
			if ($worker->{job}->status ne "TIMEOUT") {
				$worker->rollback();
				$worker->{job}->set_columns({
					status=>$worker->{status},
					rollback_output=>$worker->{output},
					rollback_error=>$worker->{error},
				});
				$worker->{job}->update();
			}
		}
	} else {
		$transaction->input("");
		$transaction->update();
	}
	return {guid=>$input->{guid},status=>$transaction->status};
}

sub clear_transaction {
	my ($self,$input) = @_;

	my $transaction = $self->{server}->{db}->table("TransactionSubmit")->find({transaction_submit_id=>$input->{guid}});
	if ($transaction) {
		$transaction->delete();
	} else {
		return {status=>0,message=>"Transaction Not Found."};
	}
	return {status=>1,message=>"Transaction Cleared."};
}
sub rollback {
	my ($self,$input) = @_;
}

	


sub ping {
	my ($self,$input) = @_;

	return {status=>1};
}


sub get_transaction_status {
	my ($self,$input) = @_;

	my $sub = $input->{sub}||$self->{server}->{db}->table("TransactionSubmit")->single({transaction_submit_id=>$input->{guid}});
	my $last_run =  $self->{server}->{db}->table("TransactionJob")->search({transaction_submit_id=>$input->{guid},"me.sequence_name"=>{"!="=>"Z"},status=>{"!="=>"RUNNING"}},{order_by=>{-desc=>"me.sequence_name"},prefetch=>"transaction_step"})->first;

	my $ret = {
		status=>$sub->status,
		familyname=>$sub->familyname,
		guid=>$sub->transaction_submit_id,
	};
	if ($last_run) {
		my $f = $self->{server}->{families}->{$last_run->transaction_step->familyname};
		my $all_count = scalar(@{$f->{steps}})-(grep {$_->{sequence_name} eq "Z"} @{$f->{steps}});
		my $passed = 0;
		foreach (@{$f->{steps}}) {
			if ($_->{sequence_name} ne "Z") {
				if ($_->{sequence_name} eq $last_run->sequence_name) {
					if ($last_run->status eq "SUCCESS") {
						$passed++;
					}
					last;
				} else {
					$passed++;
				}
			} 
		}
		$ret = {
			status=>$sub->status,
                	familyname=>$sub->familyname,
                	guid=>$sub->transaction_submit_id,
			sequence_name=>$last_run->sequence_name,
			description=>$f->{steps}->[$f->{sequence}->{$last_run->sequence_name}]->{objectname},
			status=>$sub->status,
			input=>$self->{server}->deserialize($last_run->input),
			output=>$self->{server}->deserialize($last_run->output),
			error=>$last_run->error,
			steps=>$all_count,
			steps_passed=>$passed,
		};
	}
	return $ret;
}

sub transaction_search {
	my ($self,$input) = @_;

	my @recs = $self->{server}->{db}->table("TransactionSubmit")->search({status=>$input->{status}},{order_by=>{-desc=>'id'}})->all;
	my $ret = [];
	foreach my $transaction ($self->{server}->{db}->table("TransactionSubmit")->search({status=>$input->{status}},{order_by=>{-desc=>'id'}})->all) {
		push(@$ret,$self->transaction_status({guid=>$transaction->transaction_submit_id,sub=>$transaction}));
	}
	return $ret;
}
			

sub get_steps {
        my($self,$input) = @_;


        return {status=>1,data=>$self->{server}->{families}->{$input->{family}}};
}

sub count_to {
        my($self,$input) = @_;

        for (my $i = 0;$i<$input->{target};$i++) {
                $self->respond({action=>"count_to","step"=>$i+1});
                sleep(1);
        }
}

sub respond {
	my $self = shift;
	
	return $self->{server}->respond(@_);
}
1;
