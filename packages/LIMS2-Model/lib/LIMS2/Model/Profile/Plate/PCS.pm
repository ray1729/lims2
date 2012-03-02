package LIMS2::Model::Profile::Plate::PCS;
use Moose;
use MooseX::ClassAttribute;
use namespace::autoclean;
use Const::Fast;

class_has 'well_data_fields' => (
    is         => 'ro',
    isa        => 'ArrayRef',
    lazy_build => 1,
);

sub _build_well_data_fields {
    my $self = shift;

    const my @WELL_DATA_FIELDS => qw(
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

    return \@WELL_DATA_FIELDS
}

extends qw( LIMS2::Model::Profile::Plate );

sub get_well_data {
    my ( $self, $well ) = @_;
    my $well_data = $self->SUPER::get_well_data($well);

    my $process = $well->process;
    my $int_recom_process = $self->get_process_of_type( $process, 'int_recom' );
    return $well_data unless $int_recom_process; 

    my $design_well = $int_recom_process->design_well;
    my $design = $design_well->process->process_create_di->design;
    $well_data->{design_id}   = $design->design_id;
    $well_data->{design_type} = $design->design_type;
    $well_data->{design_well} = "$design_well";
    $well_data->{cassette}    = $int_recom_process->cassette;
    $well_data->{backbone}    = $int_recom_process->backbone;

    $well_data->{assay_results}     = $self->get_well_assay_results( $well ); 
    $well_data->{legacy_qc_results} = $self->get_legacy_qc_results( $well );

    return $well_data;
};

__PACKAGE__->meta->make_immutable;

1;
