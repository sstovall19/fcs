#!/usr/bin/perl

use strict;
use warnings;

use SM::Config qw(
    SM_DSN
    SM_USER
    SM_PASS
);
use SM::DB;
use Getopt::Std;

my %OPTS;
getopts('i:o:',\%OPTS);

my $id = undef;
my $outFile = undef;

if ( !defined $OPTS{i} ) {
    print "You must supply an id with the -i parameter.\n";
    exit(0);
}

$id = $OPTS{i};
$outFile = $OPTS{o} if defined $OPTS{o};

our $DB = SM::DB->new(dsn => SM_DSN, user => SM_USER, pass => SM_PASS);

my $obj = $DB->table('TransactionSubmit')->search( id => $id )->first;

if ( defined $outFile ) {
    open (OUT,">>$outFile") or die "Can't open output file for writing: $!\n";
    print OUT $obj->input;
    close OUT;
}
else {
    print $obj->input;
}

__END__
