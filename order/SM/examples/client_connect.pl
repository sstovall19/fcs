#!/usr/bin/perl

use strict;
use warnings;

use SM::Exception qw( isException );
use SM::SMClient;
use Data::Dumper;
use Try::Tiny;

my $client;
my $response;
my $msg;

try {
    $client = new SM::SMClient;
    $response = $client->connect(familyname => 'QUOTE');
}
catch {
    $msg = isException($_) ? $_->detail : $_;
    print "$msg\n\n";
    exit; 
};

print "Result of ping....\n";
print Dumper($response);


$response = $client->sendRequest( 
    command => 'restart_transaction', 
    parameters => 
    {
        guid => '46417830-4432-3531-4634-304631323131',
        debug => 1,
    }
);

print "Restart transaction status...\n";
print Dumper($response);



$response = $client->sendRequest(
    command => 'rollback_current',
    parameters =>
    {
        debug => 1,
    }
);

print "Current transaction rollback status...\n";
print Dumper($response);


__END__
