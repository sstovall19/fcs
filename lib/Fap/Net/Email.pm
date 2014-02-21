package Fap::Net::Email;
use strict;
use Fap();
use Mail::Sender();
use Fap::View::TT();
use Try::Tiny qw(try catch);
use HTML::FormatText;

sub send {
    my ( $class, %args ) = @_;

    $args{attachments} ||= [];
    my $mailer = new Mail::Sender( {
            bypass_outlook_bug => 1,
            headers            => $args{headers},

        } );
    try {
        my $args_hash = {
            smtp => $args{server} || 'localhost',
            from => $args{from},
            to   => $args{to},
            subject => $args{subject},
        };

        foreach my $opt (qw(bcc cc replyto headers)) {
            $args_hash->{$opt} = $class->collapse( $args{$opt} ) if ( defined $opt );
        }
        $mailer->OpenMultipart($args_hash);
        if ( $args{msg_html} ) {
	        
            $mailer->Body( {
                    ctype => 'text/html',
                    msg   => $args{msg_html},
                } );
		
        } elsif ( $args{msg} ) {
            $mailer->Body( {
                    ctype => 'text/plain',
                    msg   => $args{msg},
                } );
        }
        foreach my $file ( @{ $args{attachments} } ) {
            if ( !ref($file) ) {
                $mailer->Attach( { file => $file, } );
            } else {
                if ( !$file->{filename} ) {
                    $file->{filename} = substr( $file->{path}, rindex( $file->{path}, "/" ) + 1 );
                }
                $mailer->Attach( {
                        ctype       => $file->{type},
                        file        => $file->{path},
                        disposition => sprintf( qq(%s; filename="%s"), ( $file->{inline} ) ? "inline" : "attachment", $file->{filename} ),
                        content_id  => $file->{filename},
                    } );
            }
        }
        $mailer->Close();
    }
    catch {
        $mailer->Cancel();
        return 0;
    };
    return 1;
}

sub send_template {
    my ( $class, %args ) = @_;

    $args{tt_paths}||=[];
    my $tt = Fap::View::TT->new(paths=>$args{tt_paths});
    my $msg = $tt->process( $args{template}, $args{vars} );
    if   ( $args{type} eq "html" ) { $args{msg_html} = $msg; }
    else                           { $args{msg}      = $msg; }
    return $class->send(%args);
}

sub collapse {
    my ( $class, $obj ) = @_;

    return $obj if ( ref($obj) ne "ARRAY" );
    return join( ", ", @$obj );
}

1;
