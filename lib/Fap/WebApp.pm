package Fap::WebApp;
use strict;
use CGI::Application;
use Time::HiRes;
use base qw(CGI::Application);

my %LOADED={};

sub handler : method {
    my ($class, $r) = @_;
	my $t = Time::HiRes::time();
        	my $self = $class->new();
        $self->run();

	$r->content_type({$self->header_props}->{'-type'}||"text/html");
	print STDERR "$ENV{REQUEST_URI} Total Time: ".(Time::HiRes::time()-$t)."\n";
        $r->print ($self->{output});
	
        return Apache2::Const::OK();
}




1;
