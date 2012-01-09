package LIMS2::Model::Plugin::Bac;

use strict;
use warnings FATAL => 'all';

use Moose::Role;
use namespace::autoclean;

requires qw( schema check_params throw );

sub create_bac_library {
    my ( $self, $params ) = @_;

    my $validated_params = $self->check_params( 'create_bac_library', $params );

    my $bac_library = $self->schema->resultset( 'BacLibrary' )->create( $validated_params );

    return $bac_library->as_hash;
}

sub list_bac_libraries {
    my ( $self ) = @_;

    [ map { $_->bac_library } $self->schema->resultset( 'BacLibrary' )->all ];
}

sub create_bac_clone {
    my ( $self, $params ) = @_;

    my $validated_params = $self->check_params( 'create_bac_clone', $params );

    my $loci = delete $validated_params->{loci} || [];
    
    my $bac_clone = $self->schema->resultset( 'BacClone' )->create( $validated_params );

    for my $locus ( @{$loci} ) {
        my $validated_locus = $self->check_params( 'create_bac_locus', $locus );
        $bac_clone->create_related( loci => $validated_locus );
    }

    return $bac_clone->as_hash;
}

sub delete_bac_clone {
    my ( $self, $params ) = @_;

    my $validated_params = $self->check_params( 'delete_bac_clone', $params );

    my $bac_clone = $self->schema->resultset( 'BacClone' )->find( $validated_params )
        or $self->throw(
            NotFound => {
                entity_class  => 'BacClone',
                search_params => $validated_params
            }
        );

    for my $locus ( $bac_clone->loci ) {
        $locus->delete;
    }

    $bac_clone->delete;

    return;
}

1;

__END__
