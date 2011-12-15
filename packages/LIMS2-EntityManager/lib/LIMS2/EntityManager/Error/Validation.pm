package LIMS2::EntityManager::Error::Validation;

use strict;
use warnings FATAL => 'all';

use Moose;
use namespace::autoclean;

extends qw( LIMS2::EntityManager::Error );

has '+message' => (
    default => 'Parameter validation failed'
);

has fields => (
    is      => 'ro',
    isa     => 'HashRef',
    traits  => [ 'Hash' ],
    handles => {
        add_field  => 'set',
        has_fields => 'count'
    }
);

around message => sub {
    my $orig = shift;
    my $self = shift;

    my $str = $self->$orig;

    while ( my ( $field, $error ) = each %{ $self->fields } ) {
        $str .= "\n  $field: $error";
    }

    return $str;
};

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;

__END__
