#!/usr/bin/perl
# This just displays the template Core/Main.tt

use strict;

sub process_Main
{
	my $self = shift;
	return $self->tt_process('Core/Main.tt');
}

sub Core_Main_init_permissions
{
	my $perm = {
		GLOBAL => 1,
		GUEST => 1,
		DESC => "Update main page content",
		LEVELS => 'rw',
		VERSION => 4
	};

	return $perm;
}

1;
