package LIMS2::Task::YAMLDataLoader::LoadPlates;

use strict;
use warnings FATAL => 'all';

use Moose;
use LIMS2::Util::YAMLIterator;
use namespace::autoclean;

extends 'LIMS2::Task::YAMLDataLoader';

override abstract => sub {
    'Load plate and well data from YAML file';
};

override create => sub {
    my ( $self, $datum ) = @_;

    $self->model->create_plate( $datum );
};

override wanted => sub {
    my ( $self, $datum ) = @_;

    my $plate = $self->schema->resultset( 'Plate' )->find( { plate_name => $datum->{plate_name} } );    
    if ( $plate ) {
        $self->log->warn( "Skipping existing plate $datum->{plate_name}" );
        return 0;
    }

    return 1;
};

__PACKAGE__->meta->make_immutable;

1;

__END__

    
