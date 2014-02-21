#!/usr/bin/perl

# use as few modules as possible
use Sys::Hostname;
use F::Mail;
print "Content-type: text/html\r\n\r\n";

my ($from, $to);
$from = $to = 'error500@fonality.com';

use Data::Dumper;
foreach (keys %ENV)
{
	$ENV{$_} =~ s/<address>//gi;
	$ENV{$_} =~ s/\n/ /g;
}
my $msg;

$msg .= "Subject: 500 error from $ENV{HTTP_HOST}$ENV{REQUEST_URI} (" . hostname() . ")\n\n";
$msg .= 'Time: ' . localtime() . "\n";
$msg .= 'URL: http://' . $ENV{HTTP_HOST} . $ENV{REQUEST_URI} . "\n";
$msg .= 'Host: ' . hostname() . "\n";
$msg .= ($ENV{REDIRECT_ERROR_NOTES} || $ENV{ERROR_NOTES});
$msg .= "\n\n";
$msg .= Dumper(\%ENV);

# display error on web11
if (hostname =~ /web11/)
{
	$code = "<PRE>$msg</PRE>\n";
}
# email it otherwise
else
{
	F::Mail::send_email_to([{EMAIL => $to}], $from, $msg);
}

print << "EOF";
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<HTML><HEAD>
<TITLE>500 Internal Server Error</TITLE>
</HEAD><BODY>
<H1>Internal Server Error</H1>
The server encountered an internal error or
misconfiguration and was unable to complete
your request.<P>
Our server administrators have already been
notified of this error. Thank you.
<HR>
$code
</BODY></HTML>
EOF

