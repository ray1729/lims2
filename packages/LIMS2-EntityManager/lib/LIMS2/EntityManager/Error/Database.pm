package LIMS2::EntityManager::Error::Database;

use strict;
use warnings FATAL => 'all';

use Moose;
use namespace::autoclean;

extends qw( LIMS2::EntityManager::Error );

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;

__END__
