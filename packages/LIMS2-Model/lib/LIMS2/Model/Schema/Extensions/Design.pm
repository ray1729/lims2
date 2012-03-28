package LIMS2::Model::Schema::Extensions::Design;

use strict;
use warnings FATAL => 'all';

use Moose::Role;
use LIMS2::Model::Constants qw( $DEFAULT_ASSEMBLY );
use LIMS2::Model::Error::Database;
use LIMS2::Util::EnsEMBL;
use namespace::autoclean;

has chr_name => (
    is         => 'ro',
    isa        => 'Str',
    init_arg   => undef,
    lazy_build => 1
);

has chr_strand => (
    is         => 'ro',
    isa        => 'Int',
    init_arg   => undef,
    lazy_build => 1
);

has [
    qw(
          five_arm_start
          five_arm_end
          three_arm_start
          three_arm_end
          target_region_start
          target_region_end
  )
] => (
    is         => 'ro',
    isa        => 'Int',
    init_arg   => undef,
    lazy_build => 1,
);

has synthetic_vector_params => (
    is         => 'ro',
    isa        => 'HashRef',
    init_arg   => undef,
    lazy_build => 1
);

has gene => (
    is         => 'ro',
    isa        => 'Bio::EnsEMBL::Gene',
    lazy_build => 1,
);

sub _build_gene {
    my $self = shift;

    my $gene = LIMS2::Util::EnsEMBL->new->gene_adaptor->fetch_by_transcript_stable_id(
        $self->target_transcript );
}

has marker_symbol => (
    is => 'ro',
    isa => 'Str',
    lazy_build => 1,
);

sub _build_marker_symbol {
    my $self = shift;

    return $self->gene->external_name;
}

has ensembl_gene_id => (
    is    => 'ro',
    isa     => 'Str',
    lazy_build => 1,
);

sub _build_ensembl_gene_id{
    my $self = shift;
    return $self->gene->stable_id;
}


sub has_oligo {
    my ( $self, $oligo_type ) = @_;

    $self->search_related_rs( design_oligos => { design_oligo_type => $oligo_type } )->count > 0;
}

sub locus_for {
    my ( $self, $oligo_type ) = @_;

    my $locus = $self->search_related(
        design_oligos => {
            'me.design_oligo_type' => $oligo_type
        }
    )->search_related(
        loci => { assembly => $DEFAULT_ASSEMBLY }
    )->first;

    unless ( $locus ) {
        LIMS2::Model::Error::Database->throw( sprintf 'Design %d has no %s oligo with locus on assembly %s',
                                              $self->design_id, $oligo_type, $DEFAULT_ASSEMBLY );
    }

    return $locus;
};

sub as_hash {
    my $self = shift;

    return {
        design_id          => $self->design_id,
        design_name        => $self->design_name,
        design_type        => $self->design_type,
        phase              => $self->phase,
        created_by         => $self->created_by->user_name,
        created_at         => $self->created_at->iso8601,
        comments           => [ map { $_->as_hash } $self->design_comments ],
        oligos             => [ map { $_->as_hash } $self->design_oligos ],
        genotyping_primers => [ map { $_->as_hash } $self->genotyping_primers ],
    };
}

sub _build_chr_name {
    my $self = shift;

    my @loci = $self->design_oligos_rs->search_related(
        loci => { assembly => $DEFAULT_ASSEMBLY },
        {
            columns  => 'chr_name',
            distinct => 1
        }
    );

    if ( @loci == 1 ) {
        return $loci[0]->chr_name;
    }
    elsif ( @loci == 0 ) {
        LIMS2::Model::Error::Database->throw( sprintf 'Design %d has no oligos with locus on assembly %s',
                                              $self->design_id, $DEFAULT_ASSEMBLY );
    }
    else {
        LIMS2::Model::Error::Database->throw( sprintf 'Design %d oligos have inconsistent chromosome name',
                                              $self->design_id );
    }
}

sub _build_chr_strand {
    my $self = shift;


    my @loci = $self->design_oligos_rs->search_related(
        loci => { assembly => $DEFAULT_ASSEMBLY },
        {
            columns  => 'chr_strand',
            distinct => 1
        }
    );

    if ( @loci == 1 ) {
        return $loci[0]->chr_strand;
    }
    elsif ( @loci == 0 ) {
        LIMS2::Model::Error::Database->throw( sprintf 'Design %d has no oligos with locus on assembly %s',
                                              $self->design_id, $DEFAULT_ASSEMBLY );
    }
    else {
        LIMS2::Model::Error::Database->throw( sprintf 'Design %d oligos have inconsistent strand',
                                              $self->design_id );
    }
}

sub _build_five_arm_start {
    my $self = shift;

    if ( $self->chr_strand == 1 ) {
        $self->locus_for( 'G5' )->chr_start;
    }
    else {
        $self->locus_for( 'U5' )->chr_start;
    }
}

sub _build_five_arm_end {
    my $self = shift;

    if ( $self->chr_strand == 1 ) {
        $self->locus_for( 'U5' )->chr_end;
    }
    else {
        $self->locus_for( 'G5' )->chr_end;
    }
}

sub _build_three_arm_start {
    my $self = shift;

    if ( $self->chr_strand == 1 ) {
        $self->locus_for( 'D3' )->chr_start;
    }
    else {
        $self->locus_for( 'G3' )->chr_start;
    }

}

sub _build_three_arm_end {
    my $self = shift;

    if ( $self->chr_strand == 1 ) {
        $self->locus_for( 'G3' )->chr_end;
    }
    else {
        $self->locus_for( 'D3' )->chr_end;
    }
}

sub _build_target_region_start {
    my $self = shift;

    if ( $self->chr_strand == 1 ) {
        $self->locus_for( 'U3' )->chr_start;
    }
    else {
        $self->locus_for( 'D5' )->chr_start;
    }
}

sub _build_target_region_end {
    my $self = shift;

    if ( $self->chr_strand == 1 ) {
        $self->locus_for( 'D5' )->chr_end;
    }
    else {
        $self->locus_for( 'U3' )->chr_end;
    }
}

1;

__END__
