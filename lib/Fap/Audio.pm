package Fap::Audio;
use strict;
use warnings;
use Fap;
use Fap::Model::Fcs;

=head2 new()

=over 4

Create a new Audio object instance.

Args: none.

Returns: Audio object instance.

=back

=cut

sub new {
    my ( $class, %args ) = @_;
    my $fcs_schema      = $args{fcs_schema}||Fap::Model::Fcs->new();
    my $self            = bless {
        fcs_schema       => $fcs_schema,
        conf             => Fap->load_conf("audio")
    }, $class;
    return $self;
}

=head2 add_audio_file()

=over 4

Add an audio file to the backend database so it is visible and managed
through the CP.

This method DOES NOT place the file on the customer server.

Args:    server_id        Customer Server ID.  Required.
         filename         Name of the file to add (do not include extension).  Required.
         filesize         File size in bytes.  Required.
         comment          Text comment to show in CP.  Optional.

Returns:
         1 if success, undefined if failure.  If failure, consult $@ for details.

Example:

         use Fap::Audio;
         my $audio = Fap::Audio->new();

         if (!$audio->add_audio_file(18152, 'Hello', 1234, 'Test file')) {
           print "Could not add file: $@";
         }

=back

=cut

sub add_audio_file {
    my $self = shift;
    my $server_id = shift;
    my $filename = shift;
    my $filesize = shift;
    my $comment = shift;

    if ( (!defined($server_id) || ($server_id !~ /^(\d+)$/)) ) {
        Fap->trace_error("The server_id is required.");
        return undef;
    } elsif (!defined($filename)) {
        Fap->trace_error("The filename is required.");
        return undef;
    } elsif ( (!defined($filesize)) || ($filesize !~ /^(\d+)$/) ){
        Fap->trace_error("The filesize (bytes) is required.");
        return undef;
    }

    if ($self->{fcs_schema}->table("Audio")->search( {'server_id' => $server_id, 'filename' => $filename })->first) {
        Fap->trace_error("Audio file $filename already exists.");
        return undef;
    }

    if (!defined($self->{'fcs_schema'}->table("Audio")->create( {
                                         server_id => $server_id,
                                         filename  => $filename,
                                         filesize  => $filesize,
                                         comment   => $comment
                                                      }))) {
        Fap->trace_error("Could not add audio file $filename:  Database error.");
        return undef;
    }
    return(1);
}

=head2 add_audio_group()

=over 4

Adds a group of audio files to the backend database so they are visible and managed
through the CP.  The group must be configured in the audio.conf file.

This method DOES NOT place the file on the customer server.

Args:    server_id        Customer Server ID.  Required.
         group            The group name to add.

Returns:
         1 if success, undefined if failure.  If failure, consult $@ for details.

Example: This will add all audio files in the "initial" group to server 18152.

         use Fap::Audio;
         my $audio = Fap::Audio->new();

         if (!$audio->add_audio_group(18152,'initial')) {
           print "Could not add group: $@";
         }

Configuration (audio.conf):

        ---
        audio:
          initial:
            hello:
              size: 107404
              comment: Hello...
            goodbye:
              size: 18764
              comment: Goodbye

=back

=cut

sub add_audio_group {
    my $self = shift;
    my $server_id = shift;
    my $group = shift;
    
    if ( (!defined($server_id) || ($server_id !~ /^(\d+)$/)) ) {
        Fap->trace_error("The server_id is required.");
        return undef;
    } elsif (!defined($group)) {
        Fap->trace_error("The audio group is required.");
        return undef;
    }

    if (!ref($self->{'conf'}->{'audio'}->{$group})) {
        Fap->trace_error("Unable to find audio group $group.");
        return undef;
    }

    foreach my $filename (keys %{$self->{'conf'}->{'audio'}->{$group}}) {
        my $chk = $self->add_audio_file($server_id, $filename, $self->{'conf'}->{'audio'}->{$group}->{$filename}->{'size'},$self->{'conf'}->{'audio'}->{$group}->{$filename}->{'comment'} );
	if (!$chk) {
		return undef;
	}
    }

    return 1;
}

=head2 purge_all_audio_in_server()

=over 4

Purge all audio files in the backend database.

This method DOES NOT purge the file on the customer server.

Args:    server_id        Customer Server ID.  Required.

Returns:
         1 if success, undefined if failure.  If failure, consult $@ for details.

Example:

         use Fap::Audio;
         my $audio = Fap::Audio->new();

         if (!$audio->purge_all_audio_in_server(18152)) {
           print "Could not purge files: $@";
         }

=back

=cut

sub purge_all_audio_in_server
{
    my $self = shift;
    my $server_id = shift;
    
    if ( (!defined($server_id) || ($server_id !~ /^(\d+)$/)) ) {
        Fap->trace_error("The server_id is required.");
        return undef;
    }
    
    $self->{fcs_schema}->table("Audio")->search( { 'server_id' => $server_id } )->delete;
    
    return 1;
}

1;
