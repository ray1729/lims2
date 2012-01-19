package LIMS2::Model::Plugin::PcsWell;

use strict;
use warnings FATAL => 'all';

use Moose::Role;
use Hash::MoreUtils qw( slice_def );
use namespace::autoclean;

requires qw( schema check_params throw );

sub pspec_create_pcs_well {
    my $self = shift;

    my $pspec = $self->pspec_create_well;

    $pspec->{backbone}              = { validate => 'existing_intermediate_backbone' };
    $pspec->{cassette}              = { validate => 'existing_intermediate_cassette' };
    $pspec->{clone_name}            = { validate => 'non_empty_string', optional => 1 };
    $pspec->{legacy_qc_test_result} = { optional => 1 };
    $pspec->{qc_test_result}        = { optional => 1 };
    
    return $pspec;
}

sub create_pcs_well {
    my ( $self, $params, $plate ) = @_;

    $plate ||= $self->_instantiate_plate( $params );    
    
    my $validated_params = $self->check_params( $params, $self->pspec_create_pcs_well );   

    my $well = $self->_create_well( $validated_params, $plate );

    $well->create_related( well_backbone => { slice_def( $validated_params, 'backbone' ) } );

    $well->create_related( well_cassette => { slice_def( $validated_params, 'cassette' ) } );
    
    if ( $validated_params->{clone_name} ) {
        $well->create_related( well_clone_name => { slice_def( $validated_params, 'clone_name' ) } );
    }
    
    if ( my $legacy_qc = $validated_params->{legacy_qc_result} ) {
        $well->create_related( well_legacy_qc_test_result => $legacy_qc );
    }

    if ( my $qc = $validated_params->{qc_result} ) {
        $self->add_well_qc_result( $qc, $well );
    }

    return $well->as_hash;
}

1;

__END__
