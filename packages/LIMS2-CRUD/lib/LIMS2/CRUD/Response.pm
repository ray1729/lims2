package LIMS2::CRUD::Response;

use strict;
use warnings FATAL => 'all';

use Moose;
use MooseX::Types::URI qw( Uri );
use namespace::autoclean;

has uri => (
    is       => 'ro',
    isa      => Uri,
    required => 1,
    coerce   => 1
);

has entity => (
    is       => 'ro',
    isa      => 'HashRef',
    required => 1
);

__PACKAGE__->meta->make_immutable;

1;

__END__

        
