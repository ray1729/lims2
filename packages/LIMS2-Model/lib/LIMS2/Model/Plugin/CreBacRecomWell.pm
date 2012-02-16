package LIMS2::Model::Plugin::CreBacRecomWell;

use strict;
use warnings FATAL => 'all';

use Moose::Role;
use Hash::MoreUtils qw( slice_def );
use Const::Fast;
use namespace::autoclean;

requires qw( schema check_params throw );

const my $CRE_BAC_DESIGN_TYPE => 'cre-bac';

sub pspec_create_cre_bac_recom_process {
    return {
        design_id   => { validate => 'integer' },
        bac_library => { validate => 'cre_bac_recom_bac_library' },
        bac_name    => { validate => 'cre_bac_recom_bac_name' },
        cassette    => { validate => 'cre_bac_recom_cassette' },
        backbone    => { validate => 'cre_bac_recom_backbone' }
    }
}

sub create_cre_bac_recom_process {
    my ( $self, $params ) = @_;

    my $validated_params = $self->check_params( $params, $self->pspec_create_cre_bac_recom_process );

    my $design = $self->retrieve_design( { design_id => $validated_params->{design_id} } );
    if ( $design->design_type ne $CRE_BAC_DESIGN_TYPE ) {
        $self->throw(
            Validation => {
                message => "Design $validated_params->{design_id} is not of type '$CRE_BAC_DESIGN_TYPE'",
                params  => $validated_params
            }
        );
    }
        
    my $process = $self->schema->resultset( 'Process' )->create( { process_type => 'bac_recom' } );

    $process->create_related( process_cre_bac_recom => $validated_params );

    return $process;
}

sub pspec_create_cre_bac_recom_well {
    my $self = shift;

    return {
        %{ $self->pspec_create_well },
        %{ $self->pspec_create_cre_bac_recom_process }
    };
}

sub create_cre_bac_recom_well {
    my ( $self, $params, $plate ) = @_;

    $plate ||= $self->_instantiate_plate( $params );
    
    my $validated_params = $self->check_params( $params, $self->pspec_create_cre_bac_recom_well );

    my $process = $self->create_cre_bac_recom_process( { slice_def $validated_params, qw( design_id bac_library bac_name cassette backbone ) } );
    
    my $well = $self->_create_well( $validated_params, $process, $plate );

    return $well;
}

1;

__END__
