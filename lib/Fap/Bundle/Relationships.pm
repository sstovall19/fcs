package Fap::Bundle::Relationships;
use strict;
use Fap;
use Fap::Model::Fcs;

=head2 new

=over 4

Create a new instance of Bundle::Relationships object

Args: [fcs_schema]
Returns: $self

=back

=cut

sub new {
    my ( $class, %args ) = @_;

    if ( !defined( $args{'fcs_schema'} ) ) {
        $args{'fcs_schema'} = Fap::Model::Fcs->new();
    }

    my $self = bless { fcs_schema => $args{'fcs_schema'}, }, $class;

    return $self;
}

=head2 get_relationships

=over 4

	Retrieve a list of all bundle relationships or alternatively only those relationships associated with a given bundle_id

	Args   : [bundle_id]
	Returns: Array of bundle relationships

=back

=cut

sub get_relationships {
    my ( $self, $bundle_id ) = @_;

    my $params = {};

    if ($bundle_id) {
        $params = { 'bundle_id' => $bundle_id };
    }

    my @res =
      $self->{'fcs_schema'}->table('BundleRelationship')->search($params)
      ->all();

    return $self->{'fcs_schema'}->strip(@res);
}

=head2 insert_relationship

=over 4

	Insert a new bundle relationship row using key => value pairs of bundle_relationship table fields and values.

	The key => value list requires at least a bundle_id and one other table field.

	Args   : hash
	Returns: boolean true on success or undef on failure

	Example:

		my $br = Fap::Bundle::Relationships->new;
		$br->insert_relationship(bundle_id => 8, provides_bundle_id => 33, provides_bundle_id_multiplier => 1.00);

=back

=cut

sub insert_relationship {
    my ( $self, %params ) = @_;

    if ( $params{'bundle_id'} && keys %params > 1 ) {
        if ( defined $self->{'fcs_schema'}
            && $self->{'fcs_schema'}->table('BundleRelationship')
            ->find_or_create( \%params ) )
        {
            return 1;
        }
        else {
            Fap->trace_error("Could not insert bundle relationship");
            return undef;
        }
    }
    else {
        Fap->trace_error("bundle_id and at least one relationship is required");
    }

}

=head2 remove_relationship

=over 4

	Removes the bundle relationship identified by the given bundle_relationship_id.

	Args   : bundle_relationship_id
	Returns: boolean true on success or undef on failure

=back

=cut

sub remove_relationship {
    my ( $self, $bundle_relationship_id ) = @_;

    if ($bundle_relationship_id) {
        if ( defined $self->{'fcs_schema'}
            && $self->{'fcs_schema'}->table('BundleRelationship')
            ->search( { 'bundle_relationship_id' => $bundle_relationship_id } )
            ->delete() )
        {
            return 1;
        }
        else {
            Fap->trace_error( 'Could not remove bundle relationship' . $@ );
            return undef;
        }
    }
    else {
        Fap->trace_error('Bundle id is required');
        return undef;
    }
}

=head2 resolve_relationships

=over 4

	Given a set of key value pairs of bundles and quantities, this method will attempt to handle all of the relationships associated with the provided bundles.

	...
	...
	...

=back

=cut

sub resolve_relationships {

}

1;
