package LIMS2::Model::Profile::Plate::Design;
use Moose;
use MooseX::ClassAttribute;
use namespace::autoclean;
use Const::Fast;

has assay_result_fields => (
    is         => 'ro',
    isa        => 'ArrayRef',
    lazy_build => 1
);

sub _build_assay_result_fields {
    my $self = shift;

    my @assay_results = $self->schema->resultset('AssayResult')->search( 
        {}, 
        { 
            columns  => [ 'assay' ],
            distinct => 1,
        }
    );

    return [ map{ $_->assay } @assay_results ];
}

# build from assay_result table
const my @ASSAY_RESULT_FIELDS => qw(
    pcr_d
    pcr_g
    pcr_u
    postcre
    rec_d
    rec_g
    rec_ns
    rec_result
    rec_u
    sequencing_qc
);

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
    design_id
    design_type
    legacy_qc_results
    assay_pending
    assay_complete
    accepted
    );

    return [ @WELL_DATA_FIELDS, @{ $self->assay_result_fields } ];
}

extends qw( LIMS2::Model::Profile::Plate );

sub get_well_data {
    my ( $self, $well ) = @_;
    my $well_data = $self->SUPER::get_well_data($well);

    my $process = $well->process;
    my $create_di_process = $self->get_process_of_type( $process, 'create_di' );
    return $well_data unless $create_di_process; 

    my $design                = $create_di_process->design;
    $well_data->{design_id}   = $design->design_id;
    $well_data->{design_type} = $design->design_type;

    $well_data->{legacy_qc_results} = $self->get_legacy_qc_results( $well );
    my $assay_results               = $self->get_well_assay_results( $well ); 
    map{ $well_data->{$_} = $assay_results->{$_} if exists $assay_results->{$_} } @ASSAY_RESULT_FIELDS;

    return $well_data;
};


__PACKAGE__->meta->make_immutable;

1;
