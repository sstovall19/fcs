package Fap::Billing::CreditCard;
use strict;
use Fap::External::NetSuite;
use Fap::Data::Countries;
use Business::MaxMind::CreditCardFraudDetection;
use Algorithm::LUHN;
use Fap::External::NetSuite;
use Data::Dumper;
use Fap;

sub validate {
	my ($class,%args)=@_;

	my $conf = Fap->load_conf("order/billing");

	my $ret = {status=>0,msg=>""};
	if (!Algorithm::LUHN::is_valid($args{cardnumber})) {
		$ret->{msg} = $conf->{messages}->{invalid_card};
		return $ret;
	}
	my $max = Business::MaxMind::CreditCardFraudDetection->new(secure=>1,timeout=>10);
	$max->input(
		i=>$args{ip},
		bin=>substr($args{cardnumber},0,6),
		city=>$args{city},
		postal=>$args{postal},
		region=>$args{state_prov},
		country=>Fap::Data::Countries->get_code2($args{country}),
		custPhone=>$args{phone},
		license_key=>'iGQQfKA6s9Ze'
	);
	$max->query();
	my $max_res = $max->output;
	if ($max_res->{prepaid} eq "Yes") {
		$ret->{msg} = $conf->{messages}->{prepaid_gift};
		return $ret;
	}

	$ret->{status} = 1;
	$ret->{max} = $max_res;
	return $ret;
}

sub add_card {
	my ($class,%args) = @_;

	my $ns = $args{ns}||Fap::External::NetSuite->new(mode=>"sandbox");
	my $db = $args{db}||Fap::Model::Fcs->new();
	my $card = {
		ccNumber=>$args{cardnumber},
		ccName=>$args{cardholder_name},
		ccDefault=>'T',
		ccExpireDate=>sprintf("%04d-%02d-01T00:00:00Z-8",$args{expiration_year},$args{expiration_month})
	};
	my $payment_method = $class->credit_card_type($args{cardnumber});
	if (!$payment_method) {
		return undef;
	}
	$card->{paymentMethod} = $payment_method;
	$ns->customer->update(internalId=>$args{netsuite_lead_id},creditCardsList=>[$card]);
	if ($ns->hasError) {
		Fap->trace_error($ns->errorMsg);
		return undef;
	}
	my $card_id;
        my $rec = $ns->customer->get($args{netsuite_lead_id});
        foreach my $nscard (@{$rec->{creditCardsList}}) {
                if ($nscard->{ccNumber} eq $card->{ccNumber}) {
                        $card_id = $nscard->{internalId};
                }
        }

	my $card = $db->table("EntityCreditCard")->find_or_create({
		netsuite_card_id=>$card_id,
		first_four=>substr($args{cardnumber},0,4),
		last_four=>substr($args{cardnumber},-4),
		cardholder_name=>$args{cardholder_name},
		expiration_month=>$args{expiration_month},
		expiration_year=>$args{expiration_year},
	});
	return $card;
		
}

sub charge_card {
	my ($class,%args) = @_;

	my $ns = $args{ns}||Fap::External::NetSuite->new(mode=>"sandbox");
	
	if (!$args{items}) {
		$args{items} = [{item=>3275,quantity=>1,amount=>$args{total},description=>$args{description}}];
	}
  	my $transaction_id = $ns->cashsale->create(
        	netsuite_card_id=>$args{card_id},
        	netsuite_lead_id=>$args{customer_id},
        	memo=>$args{memo},
        	items=>$args{items},
	);
	if ($ns->hasError) {
		return {success=>0,msg=>$ns->errorMsg,code=>$ns->errorCode,id=>0};
	} elsif ($transaction_id) {
		return {success=>1,id=>$transaction_id};
	} else {
		return {success=>0,id=>0,code=>'???',msg=>$@};
	}
}

	
	
sub credit_card_type {
	my ($class,$cardnumber) = @_;

	my $conf = Fap->load_conf("order/billing");
	foreach my $range (keys %{$conf->{ranges}}) {
		if ($cardnumber=~/^$conf->{ranges}->{$range}/) {
			return $conf->{netsuite_payment_ids}->{$range};
		}
	}
	return 0;
}

sub validate_luhn {
	my ($class,$cardnumber) = @_;
	
	my @p=split(//,$cardnumber);
	my $check_digit = pop(@p);
	my $total = 0;
	for (my $i=0;$i<scalar(@p);$i++) {
		$total+=($i%2||$i==0)?$p[$i]:$p[$i]*2;
	}
	if ($total%10==$check_digit) {
		return 1;
	}
	return 0;
}
		


1;
