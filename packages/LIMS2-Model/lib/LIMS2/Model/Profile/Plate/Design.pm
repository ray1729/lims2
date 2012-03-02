package LIMS2::Model::Profile::Plate::Design;
use Moose;
use namespace::autoclean;
use Const::Fast;

const my @DESIGN_WELL_DATA => qw(
well_name
pipeline
design_id
design_type
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
    $plate_data->{wells} = [ map { $self->process_well_design_profile( $_ ) } @{ $self->wells } ];
    $plate_data->{well_data} =\@DESIGN_WELL_DATA;

    return $plate_data;
}

sub process_well_design_profile {
    my ( $self, $well ) = @_;
    my $well_data = $self->process_default_well( $well );

    my $process = $well->process;
    my $create_di_process = $self->get_process_of_type( $process, 'create_di' );
    return $well_data unless $create_di_process; 

    my $design                = $create_di_process->design;
    $well_data->{design_id}   = $design->design_id;
    $well_data->{design_type} = $design->design_type;

    $well_data->{assay_results}     = $self->get_well_assay_results( $well ); 
    $well_data->{legacy_qc_results} = $self->get_legacy_qc_results( $well );

    return $well_data;
}


__PACKAGE__->meta->make_immutable;

1;
