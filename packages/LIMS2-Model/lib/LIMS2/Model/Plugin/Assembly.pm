package LIMS2::Model::Plugin::Assembly;

use strict;
use warnings FATAL => 'all';

use Moose::Role;
use namespace::autoclean;

requires qw( schema check_params throw );

sub create_assembly {
    my ( $self, $params ) = @_;

    my $validated_params = $self->check_params( 'create_assembly', $params );

    my $assembly = $self->schema->resultset( 'Assembly' )->create( $validated_params );

    return $assembly->as_hash;
}

sub list_assemblies {
    my ( $self ) = @_;

    return [ map { $_->assembly } $self->schema->resultset( 'Assembly' )->all ];
}

1;

__END__
