package LIMS2::Model::Profile::Plate::CreBacRecomVectorDesign;
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
    chromosome
    ensembl_gene_id
    bac_id
    bac_start
    bac_end
    bac_length
    mt4_design_comments
    design_id
    );

    return \@WELL_DATA_FIELDS;
}

extends qw( LIMS2::Model::Profile::Plate );

sub get_well_data {
    my ( $self, $well ) = @_;
    my $well_data = $self->SUPER::get_well_data($well);

    my $process = $well->process;
    my $cre_bac_recom_process = $self->get_process_of_type( $process, 'bac_recom' );
    return $well_data unless $cre_bac_recom_process; 

    my $cre_bac_process_data = $cre_bac_recom_process->as_hash;
    $well_data->{design_id}  = $cre_bac_process_data->{design_id}; 
    $well_data->{bac_id}     = $cre_bac_process_data->{bac_name};
    $well_data->{bac_start}  = $cre_bac_process_data->{chr_start}; 
    $well_data->{bac_end}    = $cre_bac_process_data->{chr_end}; 
    $well_data->{bac_length} = $well_data->{bac_end} - $well_data->{bac_start}; #end greater than start?

    my $design                    = $cre_bac_recom_process->design;
    $well_data->{marker_symbol}   = $design->marker_symbol;
    $well_data->{ensembl_gene_id} = $design->ensembl_gene_id;
    $well_data->{chromosome}      = $design->chr_name;
    my @mt4_design_comments = $design->design_comments->search(
        {
            'created_by.user_name' => 'mt4' 
        },
        {
            join => 'created_by',
        }
    );

    $well_data->{mt4_design_comments} = join('|', map { $_->design_comment } @mt4_design_comments ); 

    return $well_data;
};

__PACKAGE__->meta->make_immutable;

1;
