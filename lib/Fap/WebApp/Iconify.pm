package Fap::WebApp::Iconify;

use strict;
use CGI;
use Apache2::RequestRec;
use Apache2::Const qw(OK REDIRECT);
use APR::Table;

sub handler {
	my ($r) = @_;

	my $self = CGI->new;
        my $icon = lc($self->param('icon'));
        $icon =~ s/\s+/_/g;
        my $path = "/images/icons/$icon";

        foreach my $ext ( qw/png jpg jpeg gif/ )
        {
                if(-f "$ENV{FON_DIR}/www/".$path . '.' . $ext)
                {
                        $path .= '.'.$ext;
                }
        }

        if(! -f  "$ENV{FON_DIR}/www/$path")
        {
                $path = '/images/icons/default.png';
        }
	my $headers = $r->headers_out;
	$headers->set('Location',$path);
	return Apache2::Const::REDIRECT();
}
1;

