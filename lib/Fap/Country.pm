# Copyright 2012, Fonality Inc. ALL RIGHTS RESERVED

=head1 NAME

Fap::Country;

=head1 VERSION


=head1 SYNOPSIS

  use Fap::Country;

=head1 DESCRIPTION

Library object for working with Country related function

=cut

package Fap::Country;

use strict;
use Fap;
use Fap::Model::Fcs;


sub new {
    my ( $class, %args ) = @_;
    my $country_info = undef;
    
    if (!defined($args{fcs_schema})) 
    {
        $args{fcs_schema} = Fap::Model::Fcs->new();
    }
    
    if (defined($args{country_id}))
    {
        my $rec = $args{fcs_schema}->table('Country')->find(
            {"country_id" => $args{country_id}},
            {'prefetch' => {"provider_countries" => "provider"}}
        );
        $country_info = ($args{fcs_schema}->strip($rec));

    }
    if (not $country_info  && defined($args{name}))
    {
        my $rec = $args{fcs_schema}->table('Country')->find(
            {"name" => $args{name}},
            {'prefetch' => {"provider_countries" => "provider"}}
        );
        $country_info = ($args{fcs_schema}->strip($rec));

    }
    if (not $country_info  && defined($args{alpha_code}))
    {
        my $cnt = length($args{alpha_code});
        my $rec = $args{fcs_schema}->table('Country')->find(
            {"alpha_code_$cnt" => $args{alpha_code}},
            {'prefetch' => {"provider_countries" => "provider"}}
        );
        $country_info = ($args{fcs_schema}->strip($rec));

    }
    if(not defined($country_info))
    {
        return undef;
    }
    
    my $self = bless {
        fcs_schema   => $args{fcs_schema},
        country_info => $country_info
    }, $class;
    
    return $self;
}

sub get_voip_provider
{
    my $self = shift;
    
    my @provider = map {$_->{'provider'}->{'name'}} @{$self->{'country_info'}->{'provider_countries'}};
    
    return \@provider;
}

1;