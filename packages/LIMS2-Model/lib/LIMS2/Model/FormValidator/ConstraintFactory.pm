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
        existing_assembly                => { result_set_name => 'Assembly',
                                              column_name     => 'assembly'
                                          },
        existing_bac_library             => { result_set_name => 'BacLibrary',
                                              column_name     => 'bac_library'
                                          },
        existing_chromosome              => { result_set_name => 'Chromosome',
                                              column_name     => 'chromosome'
                                          },
        existing_design_type             => { result_set_name => 'DesignType',
                                              column_name     => 'design_type'
                                          },
        existing_design_comment_category => { result_set_name => 'DesignCommentCategory',
                                              column_name     => 'design_comment_category'
                                          },
        existing_design_oligo_type       => { result_set_name => 'DesignOligoType',
                                              column_name     => 'design_oligo_type'
                                          },
        existing_genotyping_primer_type  => { result_set_name => 'GenotypingPrimerType',
                                              column_name     => 'genotyping_primer_type'
                                          },
        existing_user                    => { result_set_name => 'User',
                                              column_name     => 'user_name'
                                          },
        existing_role                    => { result_set_name => 'Role',
                                              column_name     => 'role_name'
                                          }
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
                                  my $val = $dfv->get_current_constraint_value();                                 
                                  return $is_valid{ $val } || 0;
                              }
                          );
        }

        return $self->cache_get( $what );        
    }
}

__PACKAGE__->meta->make_immutable;

1;

__END__
