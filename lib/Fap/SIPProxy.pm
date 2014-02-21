=head1 NAME

Fap::SIPProxy;

=head1 SYNOPSIS

  use Fap::SIPProxy;

=head1 DESCRIPTION

Library functions for interfacing with the OpenSIPs Database.

=head1 FUNCTIONS

API functions available in this library

=cut

package Fap::SIPProxy;

use strict;
use Fap;
use Fap::Model::Opensips;
use Digest::MD5 qw(md5_hex);


=head2 new

=over 4

Create a new instance of SIPProxy object

Args: sip_host => <devel|tyo1|syd1>
Returns: $self

=back

=cut

sub new 
{
    my $subname = 'Fap::SIPProxy::new';
    my ( $class, %args ) = @_;
    
    if(!defined($args{'sip_host'}))
    {
        Fap->trace_error( 'Err: No SIP host was provided.' );
        return undef;
    }
    
    my $host = Fap->load_conf("database/main");
    
    unless(grep(/^$args{'sip_host'}$/, keys %{$host->{'databases'}->{'opensips'}}))    
    {
        Fap->trace_error( 'Err: Supplied SIP host is not recognised.' );
        return undef;
    }
    
    my $self    = bless {
        _schema => Fap::Model::Opensips->new( server => "opensips", switch=> $args{'sip_host'} )
    }, $class;

    return $self;
}


=head2 add_subscriber

=over 4

Creates a new entry on the subscriber table of the OpenSIPS database

Args: $username, $password
Returns: 1 for success, undef for error/fail

=back

=cut

sub add_subscriber
{
    my ($self, $username, $password) = @_;

    my $domain = "sip.fonality.com";
    my $data = {
        id       => undef,
        username => $username,
        domain   => $domain,
        password => $password,
        ha1      => $self->_ha1($username, $domain, $password),
        ha1b     => $self->_ha1b($username, $domain, $password)
    };
    
    my $chk = $self->{'_schema'}->table('Subscriber')->update_or_create($data, {key => 'account_idx'});
    if( !defined($chk) )
    {
        Fap->trace_error( 'Err: Unable to update subscriber records in OpenSIPS' );
        return undef;
    }    
    
    $data = {
        id       => undef,
        username => $username,
        domain   => $domain,
        grp      => 'pstn'
    };
    
    $chk = $self->{'_schema'}->table('Grp')->update_or_create($data, ,{key => 'account_group_idx'});
    if( !defined($chk) )
    {
        Fap->trace_error( 'Err: Unable to update grp records in OpenSIPS' );
        return undef;
    }    

    return 1;
}


=head2 delete_subscriber

=over 4

Deletes an entry on the subscriber table of the OpenSIPS database

Args: $username
Returns: 1 for success, undef for error/fail

=back

=cut

sub delete_subscriber
{
    my ($self, $username) = @_;
    
    my $rs = $self->{'_schema'}->table('Subscriber')->search({username => $username});
    if( !defined($rs) )
    {
        Fap->trace_error( 'Err: Unable to delete records in Subscriber table of OpenSIPS' );
        return undef;
    }
    $rs->delete;
    
    $rs = $self->{'_schema'}->table('Grp')->search({username => $username});
    if( !defined($rs) )
    {
        Fap->trace_error( 'Err: Unable to delete records in Grp table of OpenSIPS' );
        return undef;
    }
    $rs->delete;
    
    return 1;
}


=head2 _ha1

=over 4

Create an md5 hex string based on username, domain, and password

Args: $user, $domain, $pass
Returns: md5 hex string

=back

=cut

sub _ha1
{
    my ($self, $user, $domain, $pass) = @_;
    
    return md5_hex("$user:$domain:$pass");
}


=head2 _ha1b

=over 4

Create an md5 hex string based on username, domain, and password

Args: $user, $domain, $pass
Returns: md5 hex string

=back

=cut

sub _ha1b
{
    my ($self, $user, $domain, $pass) = @_;
    
    return md5_hex("$user\@$domain:$domain:$pass");
}

1;
