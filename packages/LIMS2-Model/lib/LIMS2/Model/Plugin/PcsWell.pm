package LIMS2::Model::Plugin::PcsWell;

use strict;
use warnings FATAL => 'all';

use Moose::Role;
use namespace::autoclean;

requires qw( schema check_params throw _instantiate_well );

sub pspec_create_pcs_well {
    my $self = shift;

    my $pspec = $self->pspec_create_well;

    $pspec->{backbone}              = { validate => 'existing_intermediate_backbone' };
    $pspec->{cassette}              = { validate => 'existing_intermediate_cassette' };
    $pspec->{clone_name}            = { validate => 'non_empty_string', optional => 1 };
    $pspec->{legacy_qc_test_result} = { optional => 1 };

    return $pspec;
}

sub create_pcs_well {
    my ( $self, $params, $plate ) = @_;

    $plate ||= $self->_instantiate_plate( $params );

    my $validated_params = $self->check_params( $params, $self->pspec_create_pcs_well );

    my $process = $self->_create_pcs_well_process( $validated_params )
        or return;

    my $well = $self->_create_well( $validated_params, $process, $plate );

    if ( my $legacy_qc = $validated_params->{legacy_qc_test_result} ) {
        $well->create_related( well_legacy_qc_test_result => $legacy_qc );
    }

    return $well;
}

sub _create_pcs_well_process {
    my ( $self, $validated_params ) = @_;

    my @parent_wells = @{ $validated_params->{parent_wells} || [] };
    if ( @parent_wells == 0 ) {
        $self->log->warn( sprintf 'Skipping %s[%s] - no parent well',
                          @{$validated_params}{qw( plate_name well_name ) } );
        return;
    }
    elsif ( @parent_wells > 1 ) {
        $self->throw(
            Validation => {
                params  => $validated_params,
                message => 'PCS well must have exactly one parent well'
            }
        );
    }

    my $pw = $self->_instantiate_well( $parent_wells[0] );

    my $process;

    if ( $pw->plate->plate_type eq 'design' ) {
        $process = $self->_instantiate_int_recom_process( $validated_params, $pw ) ;
        $process ||= $self->_create_int_recom_process( $validated_params, $pw );
    }
    elsif ( $pw->plate->plate_type eq 'pcs' ) {
        $process = $self->_instantiate_rearray_process( $validated_params, $pw ) ;
        $process ||= $self->_create_rearray_process( $pw );
    }
    else {
        $self->throw(
            Validation => {
                params  => $validated_params,
                message => 'Invalid parent plate type (parent of a PCS well must be a DESIGN or PCS well)'
            }
        );
    }

    return $process;
}

1;

__END__
