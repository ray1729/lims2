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

sub create_design {
    my ( $self, $params ) = @_;

    my $validated_params = $self->check_params( 'create_design', $params );

    my $design = $self->schema->resultset( 'Design' )->create(
        {
            slice_def( $validated_params,
                       qw( design_id design_name created_by created_at design_type
                           phase validated_by_annotation ) )
        }
    );

    for my $c ( @{ $design->{comments} || [] } ) {
        my $validated = $self->check_params( 'create_design_comment', $c );
        $design->create_related( design_comments => $validated );  
    }

    for my $o ( @{ $design->{oligos} || [] } ) {
        my $validated = $self->check_params( 'create_design_oligo', $o );
        my $loci = delete $validated->{loci};
        my $oligo = $design->create_related( design_oligos => $validated );
        for my $l ( @{ $loci || [] } ) {
            my $validated = $self->check_params( 'create_design_oligo_locus', $l );
            $oligo->create_related( loci => $validated );
        }
    }

    for my $p ( @{ $design->{genotyping_primers} || [] } ) {
        my $validated = $self->check_params( 'create_genotyping_primer', $p );
        $design->create_related( genotyping_primers => $validated );
    }

    return $design->as_hash;
}

sub delete_design {
    my ( $self, $params ) = @_;

    my $validated_params = $self->check_params( 'delete_design', $params );

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
