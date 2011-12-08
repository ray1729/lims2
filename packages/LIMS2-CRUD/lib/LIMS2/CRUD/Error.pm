package LIMS2::CRUD::Error;

use strict;
use warnings FATAL => 'all';

use Moose;
use namespace::autoclean;

extends qw( Throwable::Error );

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;

__END__
