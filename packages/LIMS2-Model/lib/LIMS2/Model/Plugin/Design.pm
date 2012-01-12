package LIMS2::Model::Plugin::Design;

use strict;
use warnings FATAL => 'all';

use Moose::Role;
use Hash::MoreUtils qw( slice slice_def );
use namespace::autoclean;

requires qw( schema check_params throw );

has _design_comment_category_ids => (
    isa         => 'HashRef',
    traits      => [ 'Hash' ],
    lazy_build  => 1,
    handles     => {
        desgin_comment_category_id_for => 'get'
    }
);

sub _build__design_comment_category_ids {
    my $self = shift;

    my %category_id_for = map { $_->design_comment_category_name => $_->design_comment_category_id }
        $self->schema->resultset( 'DesignCommentCategory' )->all;

    return \%category_id_for;
}

sub pspec_create_design {
    return {
        design_id               => { validate => 'integer' },
        design_type             => { validate => 'existing_design_type' },
        created_at              => { validate => 'date_time', post_filter => 'parse_date_time' },
        created_by              => { validate => 'existing_user', post_filter => 'user_id_for' },
        phase                   => { validate => 'phase' },
        validated_by_annotation => { validate => 'validated_by_annotation', default => 'not done' },
        design_name             => { validate => 'alphanumeric_string' },
        oligos                  => { optional => 1 },
        comments                => { optional => 1 },
        genotyping_primers      => { optional => 1 },
    };
}

sub pspec_create_design_comment {
    return {
        design_comment_category => { validate    => 'existing_design_comment_category',
                                     post_filter => 'design_comment_category_id_for',
                                     rename      => 'design_comment_category_id' },
        design_comment          => { optional => 1 },
        created_at              => { validate => 'date_time', post_filter => 'parse_date_time' },
        created_by              => { validate => 'existing_user', post_filter => 'user_id_for' },
        is_public               => { validate => 'boolean' }
    }
}

sub pspec_create_design_oligo {
    return {
        design_oligo_type => { validate => 'existing_design_oligo_type' },
        design_oligo_seq  => { validate => 'dna_seq' },
        loci              => { optional => 1 }
    }
}

sub pspec_create_design_oligo_locus {
    return {
        assembly   => { validate => 'existing_assembly' },
        chr_name   => { validate => 'existing_chromosome' },
        chr_start  => { validate => 'integer' },
        chr_end    => { validate => 'integer' },
        chr_strand => { validate => 'strand' },
    }
}

sub pspec_create_genotyping_primer {
    return {
        genotyping_primer_type => { validate => 'existing_genotyping_primer_type' },
        genotyping_primer_seq  => { validate => 'dna_seq' }
    }
}

sub create_design {
    my ( $self, $params ) = @_;

    my $validated_params = $self->check_params( $params, $self->pspec_create_design );

    my $design = $self->schema->resultset( 'Design' )->create(
        {
            slice_def( $validated_params,
                       qw( design_id design_name created_by created_at design_type
                           phase validated_by_annotation ) )
        }
    );

    for my $c ( @{ $design->{comments} || [] } ) {
        my $validated = $self->check_params( $c, $self->pspec_create_design_comment );
        $design->create_related( design_comments => $validated );  
    }

    for my $o ( @{ $design->{oligos} || [] } ) {
        my $validated = $self->check_params( $o, $self->pspec_create_design_oligo );
        my $loci = delete $validated->{loci};
        my $oligo = $design->create_related( design_oligos => $validated );
        for my $l ( @{ $loci || [] } ) {
            my $validated = $self->check_params( $l, $self->pspec_create_design_oligo_locus );
            $oligo->create_related( loci => $validated );
        }
    }

    for my $p ( @{ $design->{genotyping_primers} || [] } ) {
        my $validated = $self->check_params( $p, $self->pspec_create_genotyping_primer );
        $design->create_related( genotyping_primers => $validated );
    }

    return $design->as_hash;
}

sub pspec_delete_design {
    return {
        design_id => { validate => 'integer' },
        cascade   => { validate => 'boolean', optional => 1 }
    }
}

sub delete_design {
    my ( $self, $params ) = @_;

    my $validated_params = $self->check_params( $params, $self->pspec_delete_design );

    my %search = slice( $validated_params, 'design_id' );
    my $design = $self->schema->resultset( 'Design' )->find( \%search )
        or $self->throw(
            NotFound => {
                entity_class  => 'Design',
                search_params => \%search
            }
        );

    # XXX Check that design is not allocated to a project and, if it is, refuse to delete    

    if ( $validated_params->{cascade} ) {
        $design->design_comments_rs->delete;
        $design->design_oligos_rs->delete;
        $design->genotyping_primers_rs->delete;
    }

    $design->delete;

    return 1;
}

1;

__END__
