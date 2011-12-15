package LIMS2::Entity::BacCloneLocus;

use strict;
use warnings FATAL => 'all';

use Moose;
use namespace::autoclean;

extends 'LIMS2::Entity';

has dbic_obj => (
    is      => 'ro',
    isa     => 'LIMS2::Schema::Result::BacCloneLocus',
    handles => [
        qw( assembly chromosome bac_start bac_end bac_clone as_hash )
    ]
);

sub audit_key {
    my $self = shift;

    [ $self->bac_clone->bac_library, $self->bac_clone->bac_name, $self->assembly ];
}

augment create => sub {
    my ( $class, $entity_manager, $params ) = @_;

    $entity_manager->validate(
        $params,
        bac_clone_id => {
            validate => 'integer',
            required => 1
        },
        assembly => {
            validate => 'assembly',
            required => 1
        },
        chromosome => {
            validate => 'chromosome',
            required => 1
        },
        bac_start => {
            validate => 'integer',
            required => 1
        },
        bac_end => {
            validate => 'integer',
            required => 1
        }
    );

    my $dbic_obj = $entity_manager->schema->resultset( 'BacCloneLocus' )->create( $params );

    return $class->new( entity_manager => $entity_manager, dbic_obj => $dbic_obj );
};

augment update => sub {
    my ( $self, $params ) = @_;

    $self->entity_manager->validate(
        $params,
        bac_clone_id => {
            validate => 'integer',
            required => 1
        },
        assembly => {
            validate => 'assembly',
            required => 1
        },
        chromosome => {
            validate => 'chromosome',
            required => 1
        },
        bac_start => {
            validate => 'integer',
            required => 1
        },
        bac_end => {
            validate => 'integer',
            required => 1
        }
    );

    $self->dbic_obj->update( $params );

    return $self;
};

augment delete => sub {
    my ( $self ) = @_;

    $self->dbic_obj->delete;

    return;
};

override retrieve => sub {
    my ( $class, $entity_manager, $params ) = @_;

    $entity_manager->validate(
        $params,
        bac_clone_id => {
            validate => 'integer',
            required => 1
        },
        assembly => {
            validate => 'assembly',
            required => 1
        }
    );

    my $dbic_obj = $entity_manager->schema->resultset( 'BacCloneLocus' )->find( $params )
        or LIMS2::EntityManaager::Error::NotFound->Throw( "No locus for $params->{bac_clone_id} on assembly $params->{assembly}" );

    return [ $class->new( entity_manager => $entity_manager, dbic_obj => $dbic_obj ) ];
};

__PACKAGE__->meta->make_immutable;

1;

__END__
