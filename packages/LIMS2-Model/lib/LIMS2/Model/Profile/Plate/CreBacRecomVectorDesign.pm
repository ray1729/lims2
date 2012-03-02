package LIMS2::Model::Profile::Plate::CreBacRecomVectorDesign;
use Moose;
use namespace::autoclean;
use Const::Fast;

const my @CREBACRECOM_WELL_DATA => qw(
well_name
marker_symbol
chromosome
ensembl_gene_id
design_id
bac_id
bac_start
bac_end
bac_length
U5_primer_name
U5
D3_primer_name
D3
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

    my $cre_bac_process_data = $cre_bac_recom_process->as_hash;
    $well_data->{design_id} = $cre_bac_process_data->{design_id}; 
    $well_data->{bac_id} = $cre_bac_process_data->{bac_name};
    $well_data->{bac_start} = $cre_bac_process_data->{chr_start}; 
    $well_data->{bac_end} = $cre_bac_process_data->{chr_end}; 
    $well_data->{bac_length} = $well_data->{bac_end} - $well_data->{bac_start};

    my $design = $cre_bac_recom_process->design;
    $well_data->{marker_symbol} = $design->marker_symbol;
    $well_data->{ensembl_gene_id} = $design->ensembl_gene_id;
    $well_data->{chromosome} = $design->chr_name;
    my $design_comments    = [ map { $_->as_hash } $design->design_comments ];
    my $oligos = $design->design_oligos->search_rs( { design_oligo_type => { 'IN' => [ qw( U5 D3 ) ] } } );
    my $oligo_data = { map { $_->design_oligo_type => $_->as_hash } $oligos->all };

    $well_data->{U5} = $oligo_data->{U5}{design_oligo_seq}; # need to revcomp this??
    $well_data->{D3} = $oligo_data->{D3}{design_oligo_seq};
    $well_data->{U5_primer_name} = $design->marker_symbol . '_' . $well_data->{design_id} . '_U5';
    $well_data->{D3_primer_name} = $design->marker_symbol . '_' . $well_data->{design_id} . '_D3';

    return $well_data;
}

__PACKAGE__->meta->make_immutable;

1;
