#!/usr/bin/perl

use strict;
use lib '/home/jweitz/lib';
use lib '/home/jweitz/lib/perl5/site_perl/5.8.8/';
use CGI;
my $self = CGI->new;

        my $icon = lc($self->param('icon'));
	$icon =~ s/\s+/_/g;
	print STDERR $icon, "\n";
        my $width = $self->param('w', 'numbers') || $self->param('width', 'numbers');
        my $height = $self->param('h', 'numbers') || $self->param('height', 'numbers') || $width;

        $width ||= 25;
        $height ||= 25;

        my $path = "images/icons/$icon";

        foreach my $ext ( qw/png jpg jpeg gif/ )
        {
                if(-f $path . '.' . $ext)
                {
                        $path .= '.'.$ext;
                }
        }

        if(! -f $path)
        {
                $path = 'images/icons/default.png';
        }


  	print     $self->redirect(-uri => $path);
