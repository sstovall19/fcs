#!/usr/bin/perl
# Start of documentation header 
 
=head1 NAME 
 
Fap::Collector::Validation
 
=head1 VERSION 
 
$Id: Validation.pm 1235 2013-01-31 21:27:28Z jweitz $ 
 
=head1 SYNOPSIS 
 
use Fap::Collector::Validation

print $self->valid->param('form_input_name');

my $v = $self->valid;
print $v->param('form_input_name');

 
=head1 DESCRIPTION 

This is a wrapper around Fap::Util::strip_nasties which simplifies validation of form input.  Use this rather than manually validating form input.

You can use this as a drop in replacement for $self->query->param() unless you're dealing with a file upload or something that should not be validated for some reason.  There is no way to override the validation of the data using this module. 

Only one instance will be created for each CGI Application instance which will be stored in $cgiapp->{'FONValidation'}.
 
=head1 EXAMPLES 
 
=head2 Get form data using a declared instance
 
=over 4 
 
my $v = $self->valid;
my $safe = $v->param('input_field');
 
=back 

=head2 Get form data without declaring an instance

=over 4

my $safe = $self->valid->param('input_field');

=back

=head1 CLASS METHODS

=over 4

Method usage.

=back

=cut 
package Fap::Collector::Validation;

use strict;
use vars qw($VERSION @EXPORT);
use base 'Fap::Collector';
use Fap::Util;

$VERSION = '1.00';

require Exporter;


@EXPORT = qw(
	valid
);

sub import
{
	goto &Exporter::import;
}

=head2 new

=over 4

	Constructor.  This should generally not be called directly.

=back

=cut
sub new {
	my $class  = shift;
	my $cgiapp = shift;
	my $self   = {};

	$self->{_query} = $cgiapp->query;
	bless $self, $class;
	Scalar::Util::weaken($self->{cgiapp});

	return $self;
}

=head2 valid

=over 4

	This is a helper function that returns a new or existing FONValidation instance.

	Args   : none
	Returns: FONValidation instance

=back

=cut
sub valid
{
	my $cgiapp = shift;
	$cgiapp->{'FONValidation'} ||= __PACKAGE__->new($cgiapp);
	return $cgiapp->{'FONValidation'};
}

=head2 param

=over 4

	Return validated form input data for given key.

	This method accepts all options available to Fap::Util::strip_nasties either as a hashref as the second argument or a list of options.

	See Fap::Util::strip_nasties for options and format


	Args   : $form_data_key, [ list or keyref of Fap::Util::strip_nasties options ]
	Returns: validated data

=back

=cut
sub param
{
	my $self = shift;
	my $key = shift;

	if(ref($_[0]) eq 'HASH')
	{
		my $params = shift;
		if(wantarray)
		{
			my @ret;
			foreach my $value ( $self->{_query}->param($key) )
			{
				$params->{'txt'} = $self->{_query}->param($key);
				push(@ret, Fap::Util::strip_nasties($params));
			}

			return @ret;
		}
		else
		{
			$params->{'txt'} = $self->{_query}->param($key);
			return Fap::Util::strip_nasties($params);		
		}
	}
	else
	{
		if(wantarray)
		{
			my @ret;
			foreach my $value ( $self->{_query}->param($key) )
			{
				push(@ret, Fap::Util::strip_nasties($value, @_));
			}
			return @ret;
		}
		else
		{
			# Assign the form input value to a variable instead of just using the param in strip_nasties or it will return the type as the result if empty
			my $res = $self->{_query}->param($key);
			return Fap::Util::strip_nasties($res, @_);
		}
	}
}
=head2 email

=over 4

	Validate the supplied email address

	Args   : $email_address
	Returns: true if valid or undef if not

=back

=cut
sub email
{
	my $self = shift;
	my $email = shift;

	if(!$email)
	{
		return undef;
	}

	if(Fap::Util::validate_email_address($email))
	{
		return 1;
	}

	return undef;
}

=head2 uri_param

=over 4

	Return validated API parameter from URI.

	This method accepts all options available to Fap::Util::strip_nasties either as a hashref as the second argument or a list of options.

	See Fap::Util::strip_nasties for options and format


	Args   : $URI_key, [ list or keyref of Fap::Util::strip_nasties options ]
	Returns: validated data
=back

=cut
sub uri_param
{
	my $self = shift;
	my $key = shift;

	if(ref($_[0]) eq 'HASH')
	{
		my $params = shift;
		if(wantarray)
		{
			my @ret;
			foreach my $value ( $self->rest_param($key) )
			{
				$params->{'txt'} = $self->rest_param($key);
				push(@ret, Fap::Util::strip_nasties($params));
			}

			return @ret;
		}
		else
		{
			$params->{'txt'} = $self->rest_param($key);
			return Fap::Util::strip_nasties($params);		
		}
	}
	else
	{
		if(wantarray)
		{
			my @ret;
			foreach my $value ( $self->rest_param($key) )
			{
				push(@ret, Fap::Util::strip_nasties($value, @_));
			}
			return @ret;
		}
		else
		{
			# Assign the form input value to a variable instead of just using the param in strip_nasties or it will return the type as the result if empty
			my $res = $self->rest_param($key);
			return Fap::Util::strip_nasties($res, @_);
		}
	}
}


1;
