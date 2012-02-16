package LIMS2::Model::Plugin::Gene;

use strict;
use warnings FATAL => 'all';

use Moose::Role;
use LIMS2::Model::Entity::Gene;
use namespace::autoclean;

requires qw( schema check_params throw );

sub pspec_get_genes_by_name {
    return {
        name => { validate => 'non_empty_string' }
    }
}

sub get_genes_by_name {
    my ( $self, $params ) = @_;

    my $validated_params = $self->check_params( $params, $self->pspec_get_genes_by_name );

    my $name = $validated_params->{name};
    
    my @genes;

    if ( $name =~ m/^ENSMUSG\d+$/ ) {
        @genes = ( $self->ensembl_gene_adaptor->fetch_by_stable_id( $name ) );
    }
    else {
        @genes = @{ $self->ensembl_gene_adaptor->fetch_all_by_external_name( $name ) };
    }

    return [ map LIMS2::Model::Entity::Gene->new( $_ ), @genes ];    
}

1;

__END__
