package LIMS2::CRUD::Changeset;

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

has _rank => (
    is         => 'ro',
    isa        => 'Num',
    traits     => [ 'Counter' ],
    default    => 0,
    handles    => {
        next_rank => 'inc'
    }
);

sub _build__db_changeset {
    my ( $self ) = @_;

    $self->user->create_related( 'changesets' => {} );
}

sub add_changeset_entry {
    my ( $self, $action, $uri, $entity ) = @_;

    $entity ||= {};

    $self->_db_changeset->create_related(
        'changeset_entries' => {
            rank   => $self->next_rank,
            action => $action,
            uri    => $uri,
            entity => to_json( $entity )
        }
    );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

       
