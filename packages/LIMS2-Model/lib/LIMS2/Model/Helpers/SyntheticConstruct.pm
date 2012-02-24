package LIMS2::Model::Helpers::SyntheticConstruct;

use strict;
use warnings FATAL => 'all';

use Sub::Exporter -setup => {
    exports => [ qw( synthetic_construct_params
                     bio_seq_to_genbank
                     genbank_to_bio_seq
               ) ]
};

use LIMS2::Model::Constants qw( $DEFAULT_ASSEMBLY );
use LIMS2::Model::Error::Database;
use LIMS2::Model::Error::Implementation;
use LIMS2::Util::EnsEMBL;
use Bio::SeqIO;
use IO::String;
use Data::Compare qw( Compare );

sub bio_seq_to_genbank {
    my $bio_seq = shift;

    my $genbank;
    my $seq_io = Bio::SeqIO->new( -fh => IO::String->new( $genbank ), -format => 'genbank' );
    $seq_io->write_seq( $bio_seq );

    return $genbank;
}

sub genbank_to_bio_seq {
    my $genbank = shift;

    my $seq_io = Bio::SeqIO->new( -fh => IO::String->new( $genbank ), -format => 'genbank' );
    return $seq_io->next_seq;
}

sub synthetic_construct_params {
    my $process = shift;

    my $process_type = $process->process_type->process_type;

    if ( $process_type eq 'rearray' ) {
        _process_rearray_params( $process->process_rearray );
    }
    elsif ( $process_type eq 'bac_recom' ) {
        _process_bac_recom_params( $process->process_cre_bac_recom );
    }
    elsif ( $process_type eq 'int_recom' ) {
        _process_int_recom_params( $process->process_int_recom );
    }
    else {
        LIMS2::Model::Error::Implementation->throw( 
            "Don't know how to construct synthetic vector for process "
                . $process->process_type->process_description
        );
    }
}

sub _process_rearray_params {
    my $process_rearray = shift;    
    
    my @source_processes = map { $_->source_well->process }
        $process_rearray->process_rearray_source_wells_rs->search( {}, { prefetch => { source_well => 'process' } } );
    my @source_params = map { synthetic_construct_params( $_ ) } @source_processes;

    my $params = shift @source_params;

    # Usually there will only be one source well, but in the case
    # of a pooled re-array, there may be more than one. We have to
    # make sure that all the source wells contain the same
    # construct        
    for my $other_params ( @source_params ) {
        if ( ! Compare( $params, $other_params ) ) {
            LIMS2::Model::Error::Database->throw(
                'Rearray process ' . $process_rearray->process_id . ' has source wells containing different constructs'
            );                
        }
    }
    
    return $params;
}


sub _process_bac_recom_params {
    my $bac_recom_process = shift;

    my $design     = $bac_recom_process->design;
    my $bac_clone  = $bac_recom_process->bac_clone;
    my $bac_locus  = $bac_clone->search_related( loci => { assembly => $DEFAULT_ASSEMBLY } )->first;

    unless ( $bac_locus ) {
        LIMS2::Model::Error::Database->throw(
            sprintf 'No locus for bac %s/%s on assembly %s',
            $bac_clone->bac_library, $bac_clone->bac_name, $DEFAULT_ASSEMBLY
        );
    }

    my $gene = LIMS2::Util::EnsEMBL->new->gene_adaptor->fetch_by_transcript_stable_id( $design->target_transcript );

    my $display_id = join '_', ( $gene ? $gene->external_name : () ),
        $bac_clone->bac_name, $design->design_id;

    my %params = (
        method      => 'insertion_vector_seq',
        display_id  => $display_id,
        chromosome  => $design->chr_name,
        strand      => $design->chr_strand,
        transcript  => $design->target_transcript,
        insertion   => { type => 'final-cassette', name => $bac_recom_process->cassette },
        backbone    => { type => 'final-backbone', name => $bac_recom_process->backbone },
    );
    
    if ( $design->chr_strand == 1 ) {
        $params{five_arm_start}  = $bac_locus->chr_start;
        $params{five_arm_end}    = $design->locus_for( 'U5' )->chr_end;
        $params{three_arm_start} = $design->locus_for( 'D3' )->chr_start;
        $params{three_arm_end}   = $bac_locus->chr_end;
    }
    else {
        $params{five_arm_start}  = $design->locus_for( 'U5' )->chr_start;
        $params{five_arm_end}    = $bac_locus->chr_end;
        $params{three_arm_start} = $bac_locus->chr_start;
        $params{three_arm_end}   = $design->locus_for( 'D3' )->chr_end;
    }
    
    return \%params;
}


sub _process_int_recom_params {
    my $int_recom_process = shift;

    my $design      = $int_recom_process->design_well->process->process_create_di->design;
    my $design_type = $design->design_type;
    my $cassette    = $int_recom_process->cassette;
    my $backbone    = $int_recom_process->backbone;
    my $display_id  = sprintf( 'int_vec_%d#%s#%s', $design->design_id, $cassette, $backbone );
    $display_id =~ s/\s+/_/g;

    my %params = (
        chromosome      => $design->chr_name,
        strand          => $design->chr_strand,
        backbone        => { type => 'intermediate-backbone', name => $backbone },
        five_arm_start  => $design->five_arm_start,
        five_arm_end    => $design->five_arm_end,
        three_arm_start => $design->three_arm_start,
        three_arm_end   => $design->three_arm_end,
        transcript      => $design->target_transcript,
    );
    
    if ( $design_type eq 'conditional' or $design_type eq 'artificial-intron' ) {
        $params{method}              = 'conditional_vector_seq';
        $params{u_insertion}         = { type => 'intermediate-cassette', name => $cassette };
        $params{d_insertion}         = { type => 'LoxP', name => 'LoxP' };
        $params{target_region_start} = $design->target_region_start;
        $params{target_region_end}   = $design->target_region_end;            
    }
    elsif ( $design_type eq 'deletion' ) {
        $params{method}    = 'deletion_vector_seq';
        $params{insertion} = { type => 'intermediate-cassette', name => $cassette };
    }
    elsif ( $design_type eq 'insertion' ) {
        $params{method}    = 'insertion_vector_seq';
        $params{insertion} = { type => 'intermediate-cassette', name => $cassette };
    }
    else {
        LIMS2::Model::Error::Implementation->throw(
            "Don't know how to create an intermediate vector for design type $design_type"
        );
    }

    return \%params;
}

1;

__END__
