#!/usr/bin/perl

use Test::More;
use Fap::Server;
use Data::Dumper;
my $server = Fap::Server->new(server_id=>18800);
my $server_details = $server->get();
print Dumper($server_details);
ok($server_details->{'deployment'} != undef, "Deployment data available for pbx server");
ok($server->is_hosted()==0, "Check if server is hosted");
$server = Fap::Server->new(server_id=>5559);
$server_details = $server->get();
ok($server_details != undef, "Product data for Connect host available");



done_testing();




