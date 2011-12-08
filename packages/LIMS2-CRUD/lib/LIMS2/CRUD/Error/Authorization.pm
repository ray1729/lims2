package LIMS2::CRUD::Error::Authorization;

use strict;
use warnings FATAL => 'all';

use Moose;
use namespace::autoclean;

extends qw( LIMS2::CRUD::Error );

has '+message' => (
    default => 'You are not authorized to perform this operation'
);

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;

__END__
