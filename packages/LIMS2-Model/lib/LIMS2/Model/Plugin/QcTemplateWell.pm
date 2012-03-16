package LIMS2::Model::Plugin::QcTemplateWell;

use strict;
use warnings FATAL => 'all';

use Moose::Role;
use Hash::MoreUtils qw( slice slice_def );
use Scalar::Util qw( blessed );
use namespace::autoclean;

requires qw( schema check_params throw _instantiate_well );

sub pspec_create_qc_template_well {
    return {
        qc_template_name      => { validate => 'plate_name' },
        qc_template_well_name => { validate => 'well_name' },
        parent_wells          => { optional => 1, default => [] },
        cassette              => { optional => 1 },
        backbone              => { optional => 1 },
    };
}

sub create_qc_template_well {
    my ( $self, $params, $qc_template ) = @_;

    my $validated_params = $self->check_params( $params, $self->pspec_create_qc_template_well );

    $self->log->debug( 'create_qc_template_well: ' 
                       . $validated_params->{qc_template_name} 
                       . '_' . $validated_params->{qc_template_well_name} );

    $qc_template ||= $self->_instantiate_qc_template( $validated_params );

    my $process = $self->_create_qc_template_well_process( $validated_params )
        or return;

    my $qc_template_well = $qc_template->create_related(
        qc_template_wells => {
            slice_def( $validated_params, qw( qc_template_well_name ) ),
            process_id => $process->process_id
        }
    );

    $self->log->debug( 'created qc_template_well with id: ' . $qc_template_well->qc_template_well_id );

    return $qc_template_well;
}

sub _create_qc_template_well_process {
    my ( $self, $validated_params ) = @_;

    #
    # TODO: deal with other parent plate types, eg PG, PGD, and VTP ( TETPCS0003_C , is this right? )
    #

    my @parent_wells = @{ $validated_params->{parent_wells} || [] };
    if ( @parent_wells == 0 ) {
        $self->log->warn( sprintf 'Skipping %s[%s] - no parent well', 
                            @{$validated_params}{qw( qc_template_name qc_template_well_name ) } );        
        return;
    }
    elsif ( @parent_wells > 1 ) {
        $self->throw(
            Validation => {
                params  => $validated_params,
                message => 'QC Template well must have exactly one parent well'
            }
        )
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
                message => 'Invalid parent plate type (parent of a qc template well must be a DESIGN or pcs well for now)'
            }
        );
    }

    return $process;
}

1;

__END__
