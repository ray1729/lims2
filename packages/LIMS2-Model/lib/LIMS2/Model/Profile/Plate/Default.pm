package LIMS2::Model::Profile::Plate::Default;
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

    return $well_data;
}

__PACKAGE__->meta->make_immutable;

1;
