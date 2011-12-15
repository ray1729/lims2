package LIMS2::Entity::BacLibrary;

use strict;
use warnings FATAL => 'all';

use Moose;
use LIMS2::EntityManager::Error::Validation;
use LIMS2::EntityManager::Error::NotFound;
use namespace::autoclean;

extends qw( LIMS2::Entity );

has dbic_obj => (
    is      => 'ro',
    isa     => 'LIMS2::Schema::Result::BacLibrary',
    handles => [
        qw( bac_library as_hash )
    ]
);

override audit_key_cols => sub {
    qw( bac_library );    
};

augment create => sub {
    my ( $class, $entity_manager, $params ) = @_; 

    $entity_manager->validate(
        $params,
        bac_library => {
            validate => 'non_empty_str',
            required => 1
        }
    );
    
    my $dbic_obj = $entity_manager->schema->resultset( 'BacLibrary' )->create( $params );

    $class->new( entity_manager => $entity_manager, dbic_obj => $dbic_obj );
};

augment delete => sub {
    my ( $self ) = @_;

    $self->dbic_obj->delete;

    return;
};

augment retrieve => sub {
    my ( $class, $entity_manager, $params ) = @_;

    $entity_manager->validate(
        $params,
        bac_library => {
            validate => 'bac_library',
            required => 1
        }
    );
    
    my $rs = $entity_manager->schema->resultset( 'BacLibrary' )->search_rs( $params );

    my @bac_libraries = map { $class->new( dbic_obj => $_, entity_manager => $entity_manager ) } $rs->all;
    
    LIMS2::EntityManager::Error::NotFound->throw( "BAC library $params->{bac_library} not found" )
            unless @bac_libraries;
    
    return \@bac_libraries;
};

__PACKAGE__->meta->make_immutable;

1;

__END__
