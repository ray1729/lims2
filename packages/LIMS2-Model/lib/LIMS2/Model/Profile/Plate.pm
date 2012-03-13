package LIMS2::Model::Profile::Plate;
use Moose;
use Hash::MoreUtils qw( slice slice_def );
use Scalar::Util qw( blessed );
use namespace::autoclean;

has plate => (
    is       => 'ro',
    isa      => 'LIMS2::Model::Schema::Result::Plate',
    required => 1,
);

has wells => (
    is         => 'ro',
    isa        => 'ArrayRef[LIMS2::Model::Schema::Result::Well]',
    lazy_build => 1,
);

has schema => (
    is       => 'ro',
    isa      => 'LIMS2::Model::Schema',
    required => 1,
);

sub _build_wells {
    my $self = shift;

    return [ sort { $a->well_name cmp $b->well_name } $self->plate->wells->all ];
}

sub as_hash {
    my $self = shift;

    my $plate_data           = $self->plate->as_hash;
    $plate_data->{wells}     = [ map { $self->get_well_data( $_ ) } @{ $self->wells } ];
    $plate_data->{well_data} = $self->well_data_fields;

    return $plate_data;
}

sub get_well_data {
    my ( $self, $well ) = @_;

    my $well_data          = $well->as_hash;
    my $process_pipeline   = $well->process->process_pipeline;
    $well_data->{pipeline} = $process_pipeline ? $process_pipeline->pipeline->pipeline_name : '';

    return $well_data;
}

sub get_well_assay_results {
    my ( $self, $well ) = @_;
    my %assay_results;
    for my $assay_result ( $well->well_assay_results->all ) {
        $assay_results{$assay_result->assay} = $assay_result->result;
    }
    return \%assay_results;
}

sub get_legacy_qc_results {
    my ( $self, $well ) = @_;
    my $legacy_qc_resultset = $well->well_legacy_qc_test_result;
    return unless $legacy_qc_resultset;

    my $legacy_qc_results;
    for my $qc_result ( $legacy_qc_resultset->all ) {
        $legacy_qc_results .= $qc_result->valid_primers . ' - ' . $qc_result->pass_level . "\n";
    }

    return $legacy_qc_results;
}

# move this function somewhere more sensible
sub get_process_of_type {
    my ( $self, $process, $type ) = @_;

    if ( $process->process_type->process_type eq $type ) {
        return $process->get_process;
    }

    if ( $process->process_type->process_type eq 'rearray' ) {
        my @source_processes = map { $_->source_well->process }
            $process->process_rearray->process_rearray_source_wells_rs->search(
                {}, { prefetch => { source_well => 'process' } } );

        my @source_params = map { synthetic_construct_params( $_ ) } @source_processes;
        my $params = shift @source_params;
        for my $other_params ( @source_params ) {
            if ( ! Compare( $params, $other_params ) ) {
                LIMS2::Model::Error::Database->throw(
                    'Rearray process ' . $process->process_id
                    . ' has source wells containing different constructs'
                );
            }
        }
        $self->get_process_of_type( shift @source_processes, $type );
    }

    return;
}

1;

__END__
