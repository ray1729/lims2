package LIMS2::Model::Profile::Plate::PCS;
use Moose;
use namespace::autoclean;
use Smart::Comments;
use Const::Fast;

const my @PCS_WELL_DATA => qw(
well_name
pipeline
cassette
backbone
design_id
design_type
design_well
assay_results
);

with qw( LIMS2::Model::Profile::Plate );

sub as_hash {
    my $self = shift;

    my $plate_data = $self->_get_plate_data;
    $plate_data->{wells} = [ map { $self->process_well_pcs_profile( $_ ) } @{ $self->wells } ];
    $plate_data->{well_data} =\@PCS_WELL_DATA;

    return $plate_data;
}

sub process_well_pcs_profile {
    my ( $self, $well ) = @_;
    my $well_data = $self->process_default_well( $well );
    # must deal with PCS re-arrays

    my $process = $well->process;
    my $int_recom_process = $self->get_process_of_type( $process, 'int_recom' );
    return $well_data unless $int_recom_process; 

    my $design_well = $int_recom_process->design_well;
    my $design = $design_well->process->process_create_di->design;
    $well_data->{design_id}   = $design->design_id;
    $well_data->{design_type} = $design->design_type;
    $well_data->{design_well} = $design_well->plate->plate_name . '_' . $design_well->well_name;
    $well_data->{cassette}    = $int_recom_process->cassette;
    $well_data->{backbone}    = $int_recom_process->backbone;

    my $assay_results;
    for my $assay_result ( $well->well_assay_results->all ) {
        $assay_result .= $assay_result->assay . ' - ' . $assay_result->result . "\n";
    }
    $well_data->{assay_results} = $assay_results;

    return $well_data;
}

sub get_process_of_type {
    my ( $self, $process, $type ) = @_;

    if ( $process->process_type->process_type eq $type ) {
        my $process_type = 'process_' . $type;
        return $process->$process_type;
    } 
    elsif ( $process->process_type->process_type eq 'rearray' ) {
        my @source_processes = map { $_->source_well->process }
            $process->process_rearray->process_rearray_source_wells_rs->search( 
                {}, { prefetch => { source_well => 'process' } } );

        if ( @source_processes == 1 ) {
            $self->get_process_of_type( shift @source_processes, $type );
        }
        else {
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
    }

    return;
}


__PACKAGE__->meta->make_immutable;

1;
