package LIMS2::Model::Profile::Plate::CreBacRecomGenePosition;
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
    marker_symbol
    bac_id
    design_id
    );

    return \@WELL_DATA_FIELDS;
}

extends qw( LIMS2::Model::Profile::Plate );

sub get_well_data {
    my ( $self, $well ) = @_;
    my $well_data = $self->SUPER::get_well_data( $well );

    my $process = $well->process;
    my $cre_bac_recom_process = $self->get_process_of_type( $process, 'bac_recom' );
    return $well_data unless $cre_bac_recom_process; 

    $well_data->{bac_id}        = $cre_bac_recom_process->bac_name;
    $well_data->{marker_symbol} = $cre_bac_recom_process->design->marker_symbol;
    $well_data->{design_id}     = $cre_bac_recom_process->design->design_id;

    return $well_data;
}

__PACKAGE__->meta->make_immutable;

1;
