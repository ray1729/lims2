package LIMS2::EntityManager::Response;

use strict;
use warnings FATAL => 'all';

use Moose;
use MooseX::Types::URI qw( Uri );
use LIMS2::URI qw( uri_for );
use namespace::autoclean;

has entity_type => (
    is       => 'ro',
    isa      => 'Str',
    required => 1
);

has entity => (
    is       => 'ro',
    isa      => 'HashRef',
    required => 1
);

has uri => (
    is         => 'ro',
    isa        => Uri,
    lazy_build => 1
);

sub _build_uri {
    my $self = shift;

    uri_for( $self->entity_type, $self->entity );
}

override BUILDARGS => sub {
    my $self = shift;

    my ( $entity_type, $entity ) = @_;

    return +{
        entity_type => $entity_type,
        entity      => $entity
    };
};

__PACKAGE__->meta->make_immutable;

1;

__END__

        
