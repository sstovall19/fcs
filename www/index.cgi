#!/usr/bin/perl

use strict;
use FindBin qw ($Bin);
use lib "$Bin";
use lib '/usr/local/fonality/fcs/lib';
use lib '/usr/local/fonality/lib/perl5';
use lib '/usr/local/fonality/lib/perl5/site_perl/5.8.8/';
use lib '/usr/local/fonality/perl5/lib/perl5';

use Fap::WebApp::Intranet;

my $intranet = Fap::WebApp::Intranet->new({ PARAMS => { ALLOW_GUESTS => 1 }});

$intranet->run();
