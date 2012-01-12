package LIMS2::Model::Plugin::Plate;

use strict;
use warnings FATAL => 'all';

use Moose::Role;
use Hash::MoreUtils qw( slice_def );
use namespace::autoclean;

requires qw( schema check_params throw );

sub pspec_create_plate {
    return {
        plate_name => { validate => 'plate_name' },
        plate_type => { validate => 'existing_plate_type' },
        plate_desc => { validate => 'non_empty_string', optional => 1 },
        created_by => { validate => 'existing_user', post_filter => 'user_id_for' },
        created_at => { validate => 'date_time' },
        comments   => { optional => 1 },
        wells      => { optional => 1 }
    }
}

sub pspec_create_plate_comment {
    return {
        plate_comment => { validate => 'non_empty_string' },
        created_by    => { validate => 'existing_user', post_filter => 'user_id_for' },
        created_at    => { validate => 'date_time' }
    }
}

sub create_plate {
    my ( $self, $params ) = @_;

    my $validated_params = $self->check_params( $params, $self->pspec_create_plate );

    my $plate = $self->schema->resultset( 'Plate' )->create(
        { slice_def( $validated_params, qw( plate_name plate_type plate_desc created_by created_at ) ) }
    );

    for my $c ( @{ $validated_params->{comments} || [] } ) {
        my $validated_c = $self->check_params( $c, $self->pspec_create_plate_comment );
        $plate->create_related( plate_comments => $validated_c );
    }
    
    my $create_well  = sprintf( 'create_%s_well', $validated_params->{plate_type} );

    while ( my ( $well_name, $well_params ) = each %{ $validated_params->{wells} || {} } ) {
        $well_params->{plate_name} = $validated_params->{plate_name};
        $well_params->{well_name}  = $well_name;        
        $self->$create_well( $well_params );
    }

    # XXX Should this return profile-specific data?
    return $plate->as_hash;
}

1;

__END__
