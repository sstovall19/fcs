#!/usr/bin/perl

use strict;

sub process_Searchable_Apps
{
	my $self = shift;

	my @app_list;

	my $apps = $self->get_searchable_applications();

	return $self->json_process({ results => $apps });
}

sub Core_Searchable_Apps_init_permissions
{
	return { GLOBAL => 1 };
}

1;
