package CGI::Session::Serialize::messagepack;

# $Id$

use strict;
use Data::MessagePack;
require CGI::Session::ErrorHandler;
use base qw(CGI::Session::ErrorHandler);
sub freeze {
    my ($self, $data) = @_;
	return Data::MessagePack->pack($data);
}

=item thaw($class, $string)

Receives two arguments. First is the class name, second is the I<frozen> data string. Should return
thawed data structure on success, undef on failure. Error message should be set
using C<set_error()|CGI::Session::ErrorHandler/"set_error()">

=back

=cut

sub thaw {
    my ($self, $string) = @_;
    return Data::MessagePack->unpack($string);
}

=head1 LICENSING

For support and licensing see L<CGI::Session|CGI::Session>

=cut

1;
