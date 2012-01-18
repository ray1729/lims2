package LIMS2::Model::Error::NotFound;

use strict;
use warnings FATAL => 'all';

use Moose;
use namespace::autoclean;

extends qw( LIMS2::Model::Error );

has '+message' => (
    default => 'Entity not found'
);

has entity_class => (
    is       => 'ro',
    isa      => 'Str',
    required => 1
);

has search_params => (
    is        => 'ro',
    isa       => 'HashRef',
    required  => 1
);

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;

__END__
