package LIMS2::Task::YAMLDataLoader::LoadQcTemplates;

use strict;
use warnings FATAL => 'all';

use Moose;
use LIMS2::Util::YAMLIterator;
use namespace::autoclean;

extends 'LIMS2::Task::YAMLDataLoader';

override abstract => sub {
    'Load qc template plates and well data from YAML file';
};

override create => sub {
    my ( $self, $datum ) = @_;

    $self->model->create_qc_template( $datum );
};

override wanted => sub {
    my ( $self, $datum ) = @_;

    my $plate = $self->schema->resultset( 'QcTemplate' )->find( 
        { qc_template_name => $datum->{plate_name} } );    
    if ( $plate ) {
        $self->log->warn( "Skipping existing qc template plate $datum->{plate_name}" );
        return 0;
    }

    return 1;
};

override record_key => sub {
    my ( $self, $datum ) = @_;

    return $datum->{plate_name} || '<undef>';
};

__PACKAGE__->meta->make_immutable;

1;

__END__

    
