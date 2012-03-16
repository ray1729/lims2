package LIMS2::Model::Plugin::ProcessRearray;

use strict;
use warnings FATAL => 'all';

use Moose::Role;
use namespace::autoclean;

requires qw( schema throw );

sub _instantiate_rearray_process {
    my ( $self, $params, $parent_well ) = @_;

    if ( blessed( $params ) and $params->isa( 'LIMS2::Model::Schema::Result::ProcessRearray' ) ) {
        return $params;
    }
     
    my @rearray_processes = map{ $_->process } $parent_well->process_rearray_source_wells;

    for my $rearray_process ( @rearray_processes ) {
        if ( $rearray_process->process_rearray_source_wells->count == 1 ) {
            $self->log->debug('Found matching rearray process');
            return $rearray_process
        }
    }
}

sub _create_rearray_process {
    my ( $self, $parent_well ) = @_;

    my $process = $self->schema->resultset( 'Process' )->create( { process_type => 'rearray' } );
    $self->log->debug( "Created rearray process with id " . $process->process_id );
    $process->create_related(
        process_rearray => {}
    )->create_related(
        process_rearray_source_wells => { source_well_id => $parent_well->well_id }
    );
    $self->log->debug( "Created auxiliary process_rearray data for process " . $process->process_id );

    return $process;
}

1;

__END__
