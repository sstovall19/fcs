
=head1 PACKAGE

Fap::ServerLicense

=head1 DESCRIPTION

Methods on server_license table. DBIx::Class way.

=head1 SYNOPSIS

=cut

package Fap::ServerLicense;

use strict;
use Fap::Model::Fcs;

=head2 new

Params:

  server_id	- server ID

Returns:

  An object of this class.

=cut

sub new {
    my ($class) = shift;
    my $server_id = shift;

    if ( !defined($server_id) || $server_id !~ /^\d+$/ ) {
        $@ = "new: invalid server_id argument";
        return undef;
    }

    my $self = {
        server_id => $server_id,
        dbh       => Fap::Model::Fcs->new() };
    bless $self, ref $class || $class;
    return $self;
}

=head2 update_server_license

=over 4

Update server_license

   Args: license_type, qty
Returns: auto incremented license id=Success | undef=Failure

=back

=cut

sub update_server_license {
    my $self         = shift;
    my $license_type = shift;
    my $qty          = shift;

    if ( !defined($qty) or !defined($license_type) ) {
        $@ = "update_server_license: missing arguments";
        return (undef);
    }

    # check first if the license being add is allowed on this server
    unless ( grep( /^$license_type$/, @{ $self->allowed_server_licenses } ) ) {
        $@ = "update_server_license: License is not allowed.";
        return undef;
    }

    my $rv = $self->{'dbh'}->table('ServerLicense')->create( {
            server_id       => $self->{'server_id'},
            license_type_id => $license_type,
            qty             => $qty
        } );

    return $rv->id;
}

=head2 remove_server_license

=over 4

Remove a server license

   Args: license_type, qty
Returns: 1=success undef=faulure

=back

=cut

sub remove_server_license {
    my $self         = shift;
    my $license_type = shift;
    my $qty          = shift;

    if ( !defined($license_type) ) {
        $@ = "remove_server_license: missing license_type argument";
        return undef;
    }

    if ( !defined($qty) || $qty !~ /^\d+$/ ) {
        $qty = 1;
    }

    # check if there are available licenses
    my $available = $self->count_server_license($license_type);
    if ( $available->{$license_type} < $qty ) {
        $@ = "remove_server_license: not enough available licenses to be removed";
        return undef;
    }

    return $self->update_server_license( $license_type, -1 * $qty );
}

sub allowed_server_licenses {
    my $self = shift;

    my $rs = $self->{'dbh'}->table('ServerBundle')->search(
		{
			"me.server_id" => $self->{'server_id'}
		},
		{
			prefetch => "bundle_license",
			'+columns' => ['bundle_license.license_type_id']
		}
	);
	
	my %license_type_ids;
	while (my $row = $rs->next) {
		my %data = $row->get_columns;
		if (defined($data{'license_type_id'})) {
			$license_type_ids{$data{'license_type_id'}} = 1;
		}
	}
	my @ids = keys %license_type_ids;
	return \@ids;
}

=head1 METHODS

=head2 get_all_server_licenses 

Get all server licenses based on the specified license type. 
if license type not specified, retrieve all server licenses on object's server id

   Args: [license_type]
Returns: arrayref of hashrefs of information

=cut

sub get_all_server_licenses {
    my $self         = shift;
    my $license_type = shift;

    my @licenses = @{ $self->allowed_server_licenses };
    push @licenses, '';

    my $and_array = [
        server_id       => $self->{'server_id'},
        license_type_id => { -in => \@licenses } ];

    if ( defined($license_type) ) {
        push @$and_array, license_type_id => $license_type;
    }

    my $cond = { -and     => $and_array };
    my $attr = { order_by => 'date_entered' };
    my $rs = $self->{'dbh'}->table('ServerLicense')->search( $cond, $attr );
	
	my @ret;
	while (my $row = $rs->next) {
		my %data = $row->get_columns;
		push @ret, \%data;
	}
	return @ret ? \@ret : [];;
}

=head2 count_server_license

Based on the entries in server_licenses table count the total number
of licenses available for all or specified license type

Args: [$license_type]
Returns: Hashref of $license_type => quantity

=cut

sub count_server_license {
    my $self         = shift;
    my $license_type = shift;

    # get all licenses first
    my $all_server_licenses = $self->get_all_server_licenses($license_type);

    my $server_licenses_count;
    foreach my $server_license_record ( @{$all_server_licenses} ) {
        $server_licenses_count->{ $server_license_record->{'license_type_id'} } += int( $server_license_record->{'qty'} );
    }

    return $server_licenses_count;
}

=head2 remove_server_licenses

This method is static. You don't need to instantiate the object to call it.
Remove licenses from server_license table by their ids

Args: license_ids - an arrayref of license ids
Returns: 1=Success undef=Error

=cut

sub remove_server_licenses {
    my $license_ids = shift;

    if ( !@{$license_ids} ) {
        $@ = "remove_server_license_by_ids: no license IDs specified";
        return undef;
    }

    my $dbh = Fap::Model::Fcs->new();
    $dbh->table("ServerLicense")->search( { server_license_id => { '-in' => $license_ids } } )->delete;

    return 1;
}

=head2 get_bundle_licenses

This method is static. You don't need to instantiate the object to call it.
Get rows from bundle_license table, optionally filtered by bundle_id

Args: [bundle_id] - bundle id
Returns: an arrayref of rows

=cut

sub get_bundle_licenses {
    my $bundle_id = shift;

    my $dbh = Fap::Model::Fcs->new();

    my $rs;
    if ($bundle_id) {
        $rs = $dbh->table("BundleLicense")->search( { bundle_id => $bundle_id } );
    } else {
        $rs = $dbh->table("BundleLicense")->search;
    }

	my @ret;
	while (my $row = $rs->next) {
		my %data = $row->get_columns;
		push @ret, \%data;
	}
	return \@ret;
}

1;
