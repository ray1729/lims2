package LIMS2::Model::Profile::Plate::PCS;
use Moose;
use namespace::autoclean;
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
legacy_qc_results
assay_pending
assay_complete
accepted
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

    $well_data->{assay_results}     = $self->get_well_assay_results( $well ); 
    $well_data->{legacy_qc_results} = $self->get_legacy_qc_results( $well );

    return $well_data;
}

__PACKAGE__->meta->make_immutable;

1;
