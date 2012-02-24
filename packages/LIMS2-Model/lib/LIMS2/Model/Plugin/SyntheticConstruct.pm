package LIMS2::Model::Plugin::SyntheticConstruct;

use strict;
use warnings FATAL => 'all';

use Moose::Role;
use LIMS2::Model::Helpers::SyntheticConstruct;
use namespace::autoclean;

requires qw( schema check_params throw );

sub pspec_retrieve_synthetic_construct {
    return {
        plate_name => { validate => 'existing_plate_name' },
        well_name  => { validate => 'well_name' }
    }
}

sub retrieve_synthetic_construct {
    my ( $self, $params ) = @_;

    my $validated_params = $self->check_params( $params, $self->pspec_retrieve_synthetic_construct );

    my $well = $self->retrieve( Well => $validated_params,
                                {
                                    join     => 'plate',
                                    prefetch => { 'process' => [ 'process_type', 'process_synthetic_construct' ] }
                                }
                            );

    my $process = $well->process;
    
    if ( $process->process_synthetic_construct ) {
        return $process->process_synthetic_construct->synthetic_construct;
    }

    my $eng_seq_params = LIMS2::Model::Helpers::SyntheticConstruct::synthetic_construct_params( $process );

    my $eng_seq_method = delete $eng_seq_params->{method};

    my $bio_seq = $self->eng_seq_builder->$eng_seq_method( %{$eng_seq_params} );

    my $synthetic_construct = $self->schema->resultset( 'SyntheticConstruct' )->create(
        {
            synthetic_construct_genbank => LIMS2::Model::Helpers::SyntheticConstruct::bio_seq_to_genbank( $bio_seq )
        }
    );

    $process->create_related(
        process_synthetic_construct => { synthetic_construct_id => $synthetic_construct->synthetic_construct_id }
    );

    return $synthetic_construct;
}

1;

__END__
