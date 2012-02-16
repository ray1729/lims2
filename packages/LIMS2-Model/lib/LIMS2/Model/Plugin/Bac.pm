package LIMS2::Model::Plugin::Bac;

use strict;
use warnings FATAL => 'all';

use Moose::Role;
use namespace::autoclean;

requires qw( schema check_params throw );

sub pspec_create_bac_library {
    return {
        bac_library => { validate => 'bac_library' }
    };
}

sub create_bac_library {
    my ( $self, $params ) = @_;

    my $validated_params = $self->check_params( $params, $self->pspec_create_bac_library );

    return $self->schema->resultset( 'BacLibrary' )->create( $validated_params );
}

sub list_bac_libraries {
    my ( $self ) = @_;

    [ map { $_->bac_library } $self->schema->resultset( 'BacLibrary' )->all ];
}

sub pspec_delete_bac_library {
    return {
        bac_library => { validate => 'existing_bac_library' }
    };
}

sub delete_bac_library {
    my ( $self, $params ) = @_;

    my $validated_params = $self->check_params( $params, $self->pspec_delete_bac_library );

    my %search = slice( $validated_params, 'bac_library' );
    my $bac_library = $self->schema->resultset( 'BacLibrary' )->find( \%search )
        or $self->throw(
            NotFound => {
                entity_class  => 'BacLibrary',
                search_params => \%search
            }
        );

    if ( $validated_params->{cascade} ) {
        my $bac_rs = $bac_library->search_related_rs( 'bac_clones' => {} );
        while ( my $bac = $bac_rs->next ) {
            $bac->loci_rs->delete;
            $bac->delete;
        }
    }

    $bac_library->delete;

    return 1;
}

sub pspec_create_bac_clone {
    return {
        bac_library => { validate => 'existing_bac_library' },
        bac_name    => { validate => 'bac_name' },
        loci        => { optional => 1 }
    };
}

sub pspec_create_bac_clone_locus {
    return {
        assembly  => { validate => 'existing_assembly' },
        chr_name  => { validate => 'existing_chromosome' },
        chr_start => { validate => 'integer' },
        chr_end   => { validate => 'integer' }
    };
}

sub create_bac_clone {
    my ( $self, $params ) = @_;

    my $validated_params = $self->check_params( $params, $self->pspec_create_bac_clone );

    my $loci = delete $validated_params->{loci} || [];
    
    my $bac_clone = $self->schema->resultset( 'BacClone' )->create( $validated_params );

    for my $locus ( @{$loci} ) {
        my $validated_locus = $self->check_params( $locus, $self->pspec_create_bac_clone_locus );
        $bac_clone->create_related( loci => $validated_locus );
    }

    return $bac_clone;
}

sub pspec_delete_bac_clone {
    return {
        bac_library => { validate => 'existing_bac_library' },
        bac_name    => { validate => 'bac_name' }
    };
}

sub delete_bac_clone {
    my ( $self, $params ) = @_;

    my $validated_params = $self->check_params( $params, $self->pspec_delete_bac_clone );

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

    return 1;
}

1;

__END__
