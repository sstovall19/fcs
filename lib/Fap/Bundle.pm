package Fap::Bundle;
use strict;
use Fap::Model::Fcs;

=head2 new

=over 4

Create a new instance of Bundle object

Args: [fcs_schema,] bundle_id
Returns: $self on success, undef if bundle_id doesn't exist

=back

=cut

sub new {
    my $subname = 'Fap::Bundle::new';
    my ( $class, %args ) = @_;

    if ( !defined( $args{fcs_schema} ) ) {
        $args{fcs_schema} = Fap::Model::Fcs->new();
    }

    my $self = bless {
        fcs_schema => $args{fcs_schema},
        bundle_id  => $args{bundle_id},
    }, $class;

    if ( !( $self->{details} = $self->_get_bundle()) ) {
        return undef;
    }
    return $self;
}

=head2 has_feature

=over 4

Determines if the bundle has a particular feature

Args: feature name
Returns: boolean 
=back

=cut

sub has_feature_with_name {
    my $self    = shift;
    my $feature = shift;
    my $has_feature =
      $self->{'fcs_schema'}->table("bundle")
      ->count( { 'feature.name' => $feature, 'me.bundle_id' => $self->{'bundle_id'} }, { join => { 'bundle_features' => 'feature' } } );
    if ($has_feature) {
        return 1;
    } else {
        return 0;
    }

}

=head2 _get_bundle

Retrieves bundle details from the database.

Returns: hashref of info on success, undef on error

=cut

sub _get_bundle {
    my $self = shift;

    my $rs = $self->{'fcs_schema'}->table("Bundle")->single( { bundle_id => $self->{'bundle_id'} } );

    if ( !defined($rs) ) {
        Fap->trace_error( 'could not retrieve phone bundle with bundle id ' . $self->{'bundle_id'} );
        return undef;
    }

    my %data = $rs->get_columns;
    $self->{'bundle'} = \%data;
}

=head2 is_phone_bundle

Checks if the bundle is a phone bundle.

Returns: 1 if yes, 0 otherwise

=cut

sub is_phone_bundle {
    my $self = shift;
    return $self->{'bundle'}->{'category_id'} == $self->{'fcs_schema'}->options("BundleCategory")->{'phone'} ? 1 : 0;
}

=head2 is_reprovisioned_phone_bundle

Checks if the bundle is a reprovisioned phone bundle.

Returns: 1 if yes, 0 otherwise

=cut

sub is_reprovisioned_phone_bundle {
    my $self = shift;

    return $self->{'bundle'}->{'category_id'} == $self->{'fcs_schema'}->options("BundleCategory")->{'phone_reprovisioned'} ? 1 : 0;
}


=head2 is_user_license_bundle

Checks if the bundle is a (basic) user license bundle.

Args: is_basic
Returns: 1 if yes, 0 otherwise

=cut

sub is_user_license_bundle {
	my $self = shift;
	my $is_basic = shift;
	
	my $cond = { bundle_id => $self->{'bundle_id'} };
	
	my $user_license_category_id;
	my $rs = $self->{'fcs_schema'}->table("BundleCategory")->find({'name' => 'user_license'});
	if ($rs) {
		$user_license_category_id = $rs->get_column('bundle_category_id');
	}

	my $ret = $self->{'bundle'}->{'category_id'} == $user_license_category_id ? 1 : 0;

	if ($ret && $is_basic) {
		$cond->{'is_basic'} = 1;
		$rs = $self->{'fcs_schema'}->table("BundleLicense")->single($cond);
		$ret = defined($rs) ? 1: 0;
	}
	
	return $ret;
}

=head2 get_license_name

Gets a license name (i.e. 'fcs') associated with the bundle

Returns: license name, undef on error

=cut

sub get_license_name {
	my $self = shift;
	
	my $rs = $self->{'fcs_schema'}->table("BundleLicense")->search(
		{ bundle_id => $self->{'bundle_id'} },
		{ prefetch => 'license_type', select => [ qw/bundle_license_id name/ ] }
	);
	
	my @rows;
	while (my $row = $rs->next) {
		my %data = $row->get_columns;
		push @rows, \%data;
	}
	
	return @rows ? $rows[0]->{'name'} : undef;
}

=head2 get_phone_info

Gets phone info in the form { type => 'polycom', description => 'Polycom IP331' }

Args: none
Returns: hashref on success, undef on error

=cut

sub get_phone_info {
    my $self = shift;

    if ( !$self->is_phone_bundle() ) {
        Fap->trace_error('is not a phone bundle');
        return undef;
    }

    my ( $type, $model ) = split( '_', $self->{'bundle'}->{'name'} );
    $model = uc $model;
    $type  = ucfirst $type;
    my $description = $self->{'bundle'}->{'name'} eq 'eyebeam_softphone' ? 'Fonality Softphone' : "$type $model";
    return { type => $type, description => $description,
		manufacturer => $self->{'bundle'}->{'manufacturer'}, model => $self->{'bundle'}->{'model'} };
}

##############STATIC METHODS#########################

=head2 get_bundle_with_name

Retrieve bundle details given the bundle_name

Args: [fcs_schema,] bundle_name
Returns: hash of details if found, undef if not or an error occured

=cut

sub get_bundle_with_name {
    my $fcs_schema = shift;
    if ( !defined($fcs_schema) ) {
        Fap->trace_error('at least bundle_name parameter is required');
        return undef;
    }

    my $bundle_name;
    if ( ref($fcs_schema) eq 'Fap::Model::Fcs' ) {
        $bundle_name = shift;
        if ( !defined($bundle_name) ) {
            Fap->trace_error('bundle_name parameter is required');
            return undef;
        }
    } else {
        $bundle_name = $fcs_schema;
        $fcs_schema  = Fap::Model::Fcs->new();
    }

    my $row = $fcs_schema->table('bundle')->single( { 'lower(name)' => $bundle_name } );
    return ($row) ? { $row->get_inflated_columns() } : undef;
}

1;
