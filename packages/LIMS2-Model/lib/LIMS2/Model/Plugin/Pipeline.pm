package LIMS2::Model::Plugin::Pipeline;

use strict;
use warnings FATAL => 'all';

use Moose::Role;
use namespace::autoclean;

requires qw( schema check_params throw );

has pipelines => (
    is         => 'ro',
    isa        => 'HashRef',
    traits     => [ 'Hash' ],
    lazy_build => 1,
    handles    => {
        pipeline_id_for => 'get'
    }
);

sub _build_pipelines {
    my $self = shift;

    +{ map { $_->pipeline_name => $_->pipeline_id } $self->schema->resultset( 'Pipeline' )->all };
}

1;

__END__
