#!/usr/bin/perl
use Fap::Order;
use Fap::Provider;
use Test::More;
use Fap::StateMachine::Unit;
use Data::Dumper;
#my $order = Fap::Order->new(order_id=>52914);
#print Dumper($order->{details});
#my $provider = Fap::Provider->new(provider=>"inphonex_TEST", server_id=>"15037");
#my $new_vn = $provider->order_virtual_number();
#is($new_vn, $provider->{server_info}->{virtual_number}, "Premise box will not purchase new vn but rather use the main virtual number");

my $provider = Fap::Provider->new(provider_type=>"inphonex", is_test=>"1");
=head
my $vn = $provider->_get_available_virtual_number(500113);
print "virtual number is $vn\n";
print "error is " . $@;
#print "server info is " . Dumper($provider->{_server_info}->{details}) . "\n";
print "state id is " . Dumper($provider->{_inphonex_obj}->{StateId}) . "\n";
=cut
$provider->purchase_dids(500113,[213,215],'did_number');

