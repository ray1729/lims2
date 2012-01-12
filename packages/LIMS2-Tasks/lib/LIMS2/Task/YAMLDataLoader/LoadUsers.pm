package LIMS2::Task::YAMLDataLoader::LoadUsers;

use strict;
use warnings FATAL => 'all';

use Moose;
use LIMS2::Util::YAMLIterator;
use namespace::autoclean;

extends 'LIMS2::Task::YAMLDataLoader';

override abstract => sub {
    'Load users from YAML file';
};

override create => sub {
    my ( $self, $datum ) = @_;

    $self->model->create_user( $datum );
};

__PACKAGE__->meta->make_immutable;

1;

__END__

    
