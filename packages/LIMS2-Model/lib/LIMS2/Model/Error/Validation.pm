package LIMS2::Model::Error::Validation;

use strict;
use warnings FATAL => 'all';

use Moose;
use namespace::autoclean;

extends qw( LIMS2::Model::Error );

has '+message' => (
    default => 'Parameter validation failed'
);

has results => (
    is       => 'ro',
    isa      => 'Data::FormValidator::Results',
    required => 1
);

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;

__END__
