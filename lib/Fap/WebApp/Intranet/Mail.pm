#!/usr/bin/perl
# Start of documentation header 
 
=head1 NAME 
 
CGI::Application::Plugin::FONMail
 
=head1 VERSION 
 
$Id: Mail.pm 1692 2013-02-18 23:11:57Z jweitz $ 
 
=head1 SYNOPSIS 
 
use CGI::Application::Plugin::FONMail

=head1 DESCRIPTION 

	Use this to send html emails with or without attachments.

	You can build the HTML content using a template if desired.

	Only one instance will be created for each CGI Application instance which will be stored in $cgiapp->{'FONMail'}.
 
=head1 EXAMPLES 
 
=over 4 
 
	See examples in send_html_email
=back 

=head1 CLASS METHODS

=over 4

Method usage.

=back

=cut 
package Fap::WebApp::Intranet::Mail;

use strict;
use vars qw($VERSION @EXPORT);
use base 'Fap::WebApp::Intranet';
use Scalar::Util ();
use Mail::Sender;

$VERSION = '1.00';

require Exporter;

@EXPORT = qw(
	mail
	send_html_email
);

sub import
{
	goto &Exporter::import;
}

=head2 new

=over 4

	Creates a new new instance.

	This should generally not be used directly.  To retrieve a new instance, simply call mail instead.

=back

=cut
sub new {
	my $class  = shift;
	my $cgiapp = shift;
	my %params = @_;
	my $self   = {};

	bless $self, $class;
	$self->{cgiapp} = $cgiapp;
	Scalar::Util::weaken($self->{cgiapp});

	return $self;
}

=head2 mail

=over 4

	Create and return a new mail instance.

	Note, You can run methods directly without keeping the instance around by calling the method name like so:

		$self->mail->method_name(@arguments);

	Args   : none
	Returns: mail instance

	Examples:

		my $mail = $self->mail;
		$mail->send_html_email(%params);

=back

=cut
sub mail
{
	my $cgiapp = shift;

	$cgiapp->{FONMail} ||= __PACKAGE__->new($cgiapp);
	return $cgiapp->{FONMail};
}

=head2 send_html_email

=over 4

	Send an html email with optional attachments

	You can use a template by passing a template file name to produce the html content.

	Attachments should be in the following format:

		$attachment = { 
			cid => [ 1 ], # Display inline
			description => 'Attachment Description', 
			ctype => 'content/type', 
			file_name => 'filename.ext', 
			file_path => 'path/to/filename.ext' 
		};

		You can also send multiple attachments by passing an arrayref of attachment hashes.

	Required arguments:

		from	=> $from_address
		to	=> $to_address
		subject	=> $email_subject

	
		and one of:
			msg	=> $html_content
			template=> $template_file_path

	Optional arguments:

		attachments	=> $hash_or_array_ref_of_attachments
		bcc		=> $blind_cc_address
		smtp		=> $stmp_host
		vars		=> $template_variables_hashref


	Examples:

		my $template_file = 'tt/email/template.tt';
		my $template_vars = { 'name' => 'Jeff', 'thing' => 'stuff' };

		my $res = $self->mail->send_html_email(
			to	=> 'jweitz@fonality.com',
			from	=> 'noreply@fonality.com',
			bcc	=> 'admin@fonality.com',
			template	=> $template_file,
			vars	=> $template_vars,
			subject	=> 'Email Subject'
		);

		if($res)
		{
			print "Email sent";
		}
		else
		{
			die("Email sending failed: $@");
		}


		my $attachments = {
			cid => 1,
			description => 'Some Report Image', 
			ctype => 'image/png', 
			file_name => 'report.png', 
			file_path => '/var/images/report.png'
		};

		my $res = $self->mail->send_html_email(
			to		=> 'jweitz@fonality.com',
			from		=> 'noreply@fonality.com',
			template	=> $template_file,
			vars		=> $template_vars,
			subject		=> 'Your Attachment',
			attachments	=> $attachments
		);

		if($res)
		{
			print "Sent attachment";
		}
		else
		{
			die "Could not send attachment: $@";
		}

=back

=cut		
sub send_html_email
{
	my $self = shift;
        my %params = @_;

	my $template;

	# Make sure we have required params
	foreach (qw(to from subject))
	{
		if(!defined($params{$_}))
		{
			$@ = "Required parameter $_ not defined";
			return undef;
		}
	}

	if(!defined($params{'msg'}) && !defined($params{'template'}))
	{
		$@ = "Either a message or template file is required";
		return undef;
	}

	# Process a tempalte if one was provided
	if( $params{'template'} )
	{
		# Does this template file exist?
		if(-e $params{'template'})
		{
			$self->write_log(level => 'INFO', log => "Found email template $params{'template'}");
		}
		else
		{
			$@ = "Requested template does not exist";
			return undef;
		}

		# Make sure that CGI::App::Plugin::Template has been loaded
		if($self->can('tt_process'))
		{
			$template = $self->tt_process( $params{'template'}, $params{'vars'} );
			$params{'msg'} = $$template;
		}
		else
		{
			$@ = "Template Toolkit Plugin not loaded";
			return undef;
		}
        }

	# Convert msg to html email friendly format
	my $plaintext_msg = $params{'msg'};
        $plaintext_msg =~ s/\Q<br>\E/\n/g;
        $plaintext_msg =~ s/\&.{0,2}quo\;/\'/g;
        $plaintext_msg =~ s/\Q&nbsp;\E/ /g;
        $plaintext_msg =~ s/\Q&copy;\E/chr(169)/eg;

	# Define SMTP server address ( default localhost )
        my $smtp = $params{smtp} || '127.0.0.1';

	# New mail sender instance
        my $sender = new Mail::Sender
        {
                smtp    => $smtp,
                from    => $params{'from'},
                subject => $params{'subject'},
                bypass_outlook_bug => 1,
                bcc     => $params{'bcc'},
        };

        $sender->OpenMultipart({to => $params{'to'}, multipart => 'alternative', encoding => 'Quoted-printable'});
        $sender->Part({ctype => 'text/plain; charset=ISO-8859-1; format=flowed', disposition => "", encoding => 'Quoted-printable'});
        $sender->SendEnc($plaintext_msg);
        $sender->Part(ctype => 'multipart/related');
        $sender->Part({ctype => 'text/html; charset=ISO-8859-1', disposition => "", encoding => 'Quoted-printable'});
        $sender->SendEnc($params{'msg'});

	# We want attachments to be an array
	if($params{'attachments'} && ref($params{'attachments'}) ne 'ARRAY')
	{
		$params{'attachments'} = [ $params{'attachments'} ];
	}

        if (ref($params{'attachments'}) eq 'ARRAY')
        {
		# Handle inline attachments
                foreach my $attachments (@{$params{'attachments'}})
                {
                        # If no Content ID is given, then they probably don't want this displayed inline, skip it for now
                        next if (!exists($attachments->{'cid'}));

                        $sender->Attach(
                                {
                                        description => $attachments->{'description'},
                                        ctype => $attachments->{'ctype'},
                                        encoding => 'base64',
                                        disposition => "inline; filename=\"$attachments->{'file_name'}\";\r\nContent-ID: <$attachments->{'cid'}>",
                                        file => $attachments->{'file_path'}
                                }
                        );
                }

		# Add attachments to the email
                foreach my $attachments (@{$params{'attachments'}})
                {
                        # If there is a Content ID, then we've already attached this above, skip it
                        $sender->Attach(
                                {
                                        description => $attachments->{'description'},
                                        ctype => $attachments->{'ctype'},
                                        encoding => 'base64',
                                        disposition => "attachment; filename=\"$attachments->{'file_name'}\"",
                                        file => $attachments->{'file_path'}
                                }
                        );
                }
        }

        $sender->EndPart('multipart/related');
        $sender->EndPart('multipart/alternative');

        # Send away!
        if (ref($sender->Close))
        {
                return 1;
        }
        else
        {
                $@ .= "Could not send mail: $Mail::Sender::Error\n";
                return undef;
        }
}

1;

