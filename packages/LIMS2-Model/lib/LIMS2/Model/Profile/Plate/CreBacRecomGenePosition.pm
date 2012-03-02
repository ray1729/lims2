package LIMS2::Model::Profile::Plate::CreBacRecomGenePosition;
use Moose;
use namespace::autoclean;
use Const::Fast;

const my @CREBACRECOM_WELL_DATA => qw(
well_name
marker_symbol
bac_id
design_id
);

with qw( LIMS2::Model::Profile::Plate );

sub as_hash {
    my $self = shift;

    my $plate_data = $self->_get_plate_data;
    $plate_data->{wells} = [ map { $self->process_well_crebacrecom_profile( $_ ) } @{ $self->wells } ];
    $plate_data->{well_data} =\@CREBACRECOM_WELL_DATA;

    return $plate_data;
}

sub process_well_crebacrecom_profile {
    my ( $self, $well ) = @_;
    my $well_data = $self->process_default_well( $well );

    my $process = $well->process;
    my $cre_bac_recom_process = $self->get_process_of_type( $process, 'bac_recom' );
    return $well_data unless $cre_bac_recom_process; 

    $well_data->{bac_id}        = $cre_bac_recom_process->bac_name;
    $well_data->{marker_symbol} = $cre_bac_recom_process->design->marker_symbol;
    $well_data->{design_id}     = $$cre_bac_recom_process->design->design_id;

    return $well_data;
}

__PACKAGE__->meta->make_immutable;

1;
