package LIMS2::Model::Plugin::Design;

use strict;
use warnings FATAL => 'all';

use Moose::Role;
use Hash::MoreUtils qw( slice_def );
use namespace::autoclean;

requires qw( schema check_params throw );

sub create_design {
    my ( $self, $params ) = @_;

    my $validated_params = $self->check_params( 'create_design', $params );

    my $design = $self->schema->resultset( 'Design' )->create(
        {
            slice_def( $validated_params, qw( design_id design_name created_user created_at design_type phase validated_by_annotation ) )
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

1;

__END__
