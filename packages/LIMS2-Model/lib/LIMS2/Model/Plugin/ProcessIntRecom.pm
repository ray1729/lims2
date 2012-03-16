package LIMS2::Model::Plugin::ProcessIntRecom;

use strict;
use warnings FATAL => 'all';

use Moose::Role;
use namespace::autoclean;

requires qw( schema throw );

sub _instantiate_int_recom_process {
    my ( $self, $params, $design_well ) = @_;

    if ( blessed( $params ) and $params->isa( 'LIMS2::Model::Schema::Result::ProcessIntRecom' ) ) {
        return $params;
    }
    
    #
    # TODO: If design_well not passed in?
    #

    my @int_recom_processes = $design_well->process_int_recoms->search( 
        {
            cassette => $params->{cassette},
            backbone => $params->{backbone}
        } 
    );

    if ( @int_recom_processes == 1 ) {
        $self->log->debug('Found matching int_recom_process');
        return pop @int_recom_processes 
    }
}

# Internal function, returns LIMS2::Model::Schema::Result::ProcessIntRecom object
sub _create_int_recom_process {
    my ( $self, $validated_params, $parent_well ) = @_;

    #$self->throw('Unable to create int_recom process, parent well is not on design plate')
        #unless $parent_well->plate->plate_type eq'design';

    my $process = $self->schema->resultset( 'Process' )->create( { process_type => 'int_recom' } );
    $self->log->debug( "Created int_recom process with id " . $process->process_id );
    $process->create_related(
        process_int_recom => {
            design_well_id => $parent_well->well_id,
            cassette       => $validated_params->{cassette},
            backbone       => $validated_params->{backbone}
        }
    );
    $self->log->debug( "Created auxiliary process_int_recom data for process " . $process->process_id );

    return $process;
}

1;

__END__
