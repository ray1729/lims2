package LIMS2::CRUD::Error::Validation;

use strict;
use warnings FATAL => 'all';

use Moose;
use namespace::autoclean;

extends qw( LIMS2::CRUD::Error );

has '+message' => (
    default => 'Parameter validation failed'
);

has fields => (
    is      => 'ro',
    isa     => 'HashRef',
    traits  => [ 'Hash' ],
    handles => {
        add_field => 'set'
    }
);

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;

__END__
