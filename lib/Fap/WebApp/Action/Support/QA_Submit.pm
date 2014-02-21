#!/usr/bin/perl

use strict;

sub process_QA_Submit
{
	my $self = shift;

	my $url = $self->config('support.QA_SUBMIT_URL') || 'http://ticket.fonality.com/Ticket/Create.html?Queue=66';

	return $self->redirect($url);
}

sub Support_QA_Submit_init_permissions
{
	my $perm = { GLOBAL => 1 };

	return $perm;
}

1;

