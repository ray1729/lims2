package LIMS2::Task::YAMLDataLoader::LoadDesigns;

use strict;
use warnings FATAL => 'all';

use Moose;
use LIMS2::Util::YAMLIterator;
use List::MoreUtils qw( all );
use namespace::autoclean;

extends 'LIMS2::Task::YAMLDataLoader';

override abstract => sub {
    'Load designs from YAML file';
};

override create => sub {
    my ( $self, $datum ) = @_;

    $self->model->create_design( $datum );
};

override record_key => sub {
    my ( $self, $datum ) = @_;

    return $datum->{design_id} || '<undef>';
};

override wanted => sub {
    my ( $self, $datum ) = @_;

    unless ( defined $datum->{phase} ) {
        $self->log->warn( "Skipping design $datum->{design_id} - no phase" );
        return 0;
    }

    for my $primer ( @{ $datum->{genotyping_primers} || [] } ) {
        unless ( defined $primer->{genotyping_primer_seq} ) {
            $self->log->warn( "Skipping design $datum->{design_id} - no seq for primer $primer->{genotyping_primer_type}" );
            return 0;
        }
    }

    return 1;
};

__PACKAGE__->meta->make_immutable;

1;

__END__
