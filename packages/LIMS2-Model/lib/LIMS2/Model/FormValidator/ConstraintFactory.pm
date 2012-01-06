package LIMS2::Model::FormValidator::ConstraintFactory;

use strict;
use warnings FATAL => 'all';

use Moose;
use Const::Fast;
use LIMS2::Model::Error::Implementation;
use namespace::autoclean;

has schema => (
    is       => 'ro',
    isa      => 'LIMS2::Model::Schema',
    required => 1
);

has cache => (
    is       => 'ro',
    isa      => 'HashRef',
    init_arg => undef,
    traits   => [ 'Hash' ],
    default  => sub { {} },
    handles  => {
        cache_set    => 'set',
        cache_get    => 'get',
        cache_exists => 'exists'
    }
);

{
    const my %CONSTRAINT_FOR => (
        existing_assembly    => { result_set_name => 'Assembly',   column_name => 'assembly' },
        existing_bac_library => { result_set_name => 'BacLibrary', column_name => 'bac_library' },
        existing_chromosome  => { result_set_name => 'Chromosome', column_name => 'chromosome' },
    );

    sub constraint_for {
        my ( $self, $what ) = @_;

        unless ( $self->cache_exists( $what ) ) {
            unless ( exists $CONSTRAINT_FOR{ $what } ) {
                LIMS2::Model::Error::Implementation->throw( "Constraint '$what' not configured" );
            }
            my $result_set_name = $CONSTRAINT_FOR{ $what }{result_set_name};
            my $column_name     = $CONSTRAINT_FOR{ $what }{column_name};
            my %is_valid = map { $_->$column_name => 1 } $self->schema->resultset( $result_set_name )->all;
            $self->cache_set( $what => sub {
                                  my $dfv = shift;
                                  $dfv->name_this( $what );
                                  return $is_valid{ $dfv->get_current_constraint_value() } || 0;
                              }
                          );
        }

        return $self->cache_get( $what );        
    }
}

__PACKAGE__->meta->make_immutable;

1;

__END__
