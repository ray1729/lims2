package LIMS2::Model::Plugin::DesignWell;

use strict;
use warnings FATAL => 'all';

use Moose::Role;
use Hash::MoreUtils qw( slice_def );
use namespace::autoclean;

requires qw( schema check_params throw );

sub pspec_create_design_well {
    my $self = shift;

    my $pspec = $self->pspec_create_well;

    $pspec->{design_id}              = { validate => 'integer' };
    $pspec->{bac_clones}             = { optional => 1 };
    $pspec->{recombineering_results} = { optional => 1 };
    
    return $pspec;
}

sub pspec_create_design_well_bac {
    return {
        bac_plate   => { validate => 'bac_plate' },
        bac_library => { validate => 'existing_bac_library' },
        bac_name    => { validate => 'bac_name' }
    };    
}

sub create_design_well {
    my ( $self, $params, $plate ) = @_;

    $plate ||= $self->_instantiate_plate( $params );
    
    my $validated_params = $self->check_params( $params, $self->pspec_create_design_well );   

    my $well = $self->_create_well( $validated_params, $plate );

    $well->create_related( design_well_design => { design_id => $validated_params->{design_id} } );

    for my $b ( @{ $validated_params->{bac_clones} || [] } ) {
        my $validated_b = $self->check_params( $b, $self->pspec_create_design_well_bac );
        $well->create_related( design_well_bacs => $validated_b );
    }

    return $well->as_hash;
}

1;

__END__
