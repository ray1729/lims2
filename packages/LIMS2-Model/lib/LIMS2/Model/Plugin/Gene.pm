package LIMS2::Model::Plugin::Gene;

use strict;
use warnings FATAL => 'all';

use Moose::Role;
use namespace::autoclean;

requires qw( schema check_params throw );

sub _ensembl_gene_obj_to_hash {
    my ( $self, $gene ) = @_;

    return {
        ensembl_gene_id => $gene->stable_id,
        external_name   => $gene->external_name
    };
}

sub pspec_get_genes_by_name {
    return {
        name => { validate => 'non_empty_string' },
        raw  => { validate => 'boolean', optional => 1, default => 0 }
    }
}

sub get_genes_by_name {
    my ( $self, $params ) = @_;

    my $validated_params = $self->check_params( $params, $self->pspec_get_genes_by_name );

    my $name = $validated_params->{name};
    
    my $genes;

    if ( $name =~ m/^ENSMUSG\d+$/ ) {
        $genes = [ $self->ensembl_gene_adaptor->fetch_by_stable_id( $name ) ];
    }
    else {
        $genes = $self->ensembl_gene_adaptor->fetch_all_by_external_name( $name );
    }

    if ( $validated_params->{raw} ) {
        return $genes;
    }
    else {
        return [ map $self->_ensembl_gene_obj_to_hash($_), @{$genes} ];
    }
}

1;

__END__
