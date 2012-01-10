package LIMS2::Model::Plugin::Assembly;

use strict;
use warnings FATAL => 'all';

use Moose::Role;
use Hash::MoreUtils qw( slice );
use namespace::autoclean;

requires qw( schema check_params throw );

sub create_assembly {
    my ( $self, $params ) = @_;

    my $validated_params = $self->check_params( 'create_assembly', $params );

    my $assembly = $self->schema->resultset( 'Assembly' )->create( $validated_params );

    return $assembly->as_hash;
}

sub delete_assembly {
    my ( $self, $params ) = @_;

    my $validated_params = $self->check_params( 'delete_assembly', $params );

    my %search = slice( $validated_params, 'assembly' );
    my $assembly = $self->schema->resultset( 'Assembly' )->find( \%search )
        or $self->throw(
            NotFound => {
                entity_class  => 'Assembly',
                search_params => \%search
            }
        );

    if ( $validated_params->{casdade} ) {
        $assembly->bac_clone_loci_rs->delete;
        $assembly->design_oligo_loci_rs->delete;
    }

    $assembly->delete;

    return 1;
}   

sub list_assemblies {
    my ( $self ) = @_;

    return [ map { $_->assembly } $self->schema->resultset( 'Assembly' )->all ];
}

1;

__END__
