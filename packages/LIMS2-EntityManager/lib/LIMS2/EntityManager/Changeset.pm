package LIMS2::EntityManager::Changeset;

use strict;
use warnings FATAL => 'all';

use Moose;
use JSON qw( to_json );
use namespace::autoclean;

has user => (
    is       => 'ro',
    isa      => 'LIMS2::Schema::Result::User',
    required => 1
);

has _db_changeset => (
    is         => 'ro',
    isa        => 'LIMS2::Schema::Result::Changeset',
    lazy_build => 1
);

sub _build__db_changeset {
    my ( $self ) = @_;

    $self->user->create_related( 'changesets' => {} );
}

sub add_changeset_entry {
    my ( $self, $action, $class, $keys, $entity ) = @_;

    $entity ||= {};

    $class =~ s/^LIMS2::Entity:://;
    
    $self->_db_changeset->create_related(
        'changeset_entries' => {
            action => $action,
            class  => $class,
            keys   => to_json( $keys ),
            entity => to_json( $entity )
        }
    );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

       
