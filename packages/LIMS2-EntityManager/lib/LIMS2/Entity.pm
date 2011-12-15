package LIMS2::Entity;

use strict;
use warnings FATAL => 'all';

use Moose;
use LIMS2::EntityManager::Error::Implementation;
use Scalar::Util qw( blessed );
use namespace::autoclean;

has entity_manager => (
    is       => 'ro',
    isa      => 'LIMS2::EntityManager',
    handles  => [ qw( schema ) ],
    required => 1
);

sub create {
    my ( $class_or_obj, $entity_manager, $params ) = @_;
    my $class = blessed( $class_or_obj ) || $class_or_obj;
    $entity_manager->assert_in_txn;
    $entity_manager->assert_has_role( 'edit' );
    my $obj = inner();
    $entity_manager->add_changeset_entry( 'create', $class, $obj->audit_key, {} );
    return $obj;
}

sub retrieve {
    my ( $class_or_obj, $entity_manager ) = @_;
    my $class = blessed( $class_or_obj ) || $class_or_obj;
    $entity_manager->assert_has_role( 'read' );
    inner();
}

sub update {
    my $self = shift;
    my $class = blessed $self
        or LIMS2::EntityManager::Error::Implementation->throw( "update() cannot be called as a class method" );
    $self->entity_manager->assert_in_txn;
    $self->entity_manager->assert_has_role( 'edit' );
    $self->entity_manager->add_changeset_entry( 'update', $class, $self->audit_key, $self->as_hash );
    inner();
}

sub delete {
    my $self = shift;
    my $class = blessed $self
        or LIMS2::EntityManager::Error::Implementation->throw( "delete() cannot be called as a class method" );
    $self->entity_manager->assert_in_txn;
    $self->entity_manager->assert_has_role( 'edit' );
    $self->entity_manager->add_changeset_entry( 'delete', $class, $self->audit_key, $self->as_hash );
    inner();
}

sub audit_key_cols {
    my $class_or_obj = shift;
    my $class = blessed( $class_or_obj ) || $class_or_obj;    
    LIMS2::EntityManager::Error::Implementation->throw( "$class does not implement audit_key_cols()" );
}   

sub audit_key {
    my $self = shift;

    my %k;
    for my $col ( $self->audit_key_cols ) {
        $k{$col} = $self->$col;
    }

    return \%k;
}

__PACKAGE__->meta->make_immutable;

1;

__END__
