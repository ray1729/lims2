package LIMS2::Model;

use strict;
use warnings FATAL => 'all';

use Moose;
use Data::FormValidator;
require LIMS2::Model::DBConnect;
require LIMS2::Model::FormValidator::ProfileFactory;
require LIMS2::Model::Error::Validation;
require LIMS2::Model::Error::NotFound;
use namespace::autoclean;

# This assumes we're using Catalyst::Model::Factory::PerRequest and
# setting the audit_user when the LIMS2::Model object is
# instantiated. If necessary, we could make audit_user rw and add a
# trigger to call clear_schema() when the audit_user is changed.

# XXX TODO: authorization checks?

has audit_user => (
    is  => 'ro',
    isa => 'Str',
);

has schema => (
    is         => 'ro',
    isa        => 'LIMS2::Model::Schema',
    lazy_build => 1,
    handles    => [ 'txn_do', 'txn_rollback' ]
);

sub _build_schema {
    my $self = shift;

    my $schema = LIMS2::Model::DBConnect->connect( 'LIMS2_DB' );

    if ( $self->audit_user ) {
        $schema->storage->dbh_do(
            sub {
                my ( $storage, $dbh ) = @_;
                $dbh->do( 'SET SESSION ROLE ' . $dbh->quote_identifier( $self->audit_user ) );
            }
        );        
    }

    return $schema;
}

has profile_factory => (
    is         => 'ro',
    isa        => 'LIMS2::Model::FormValidator::ProfileFactory',
    lazy_build => 1,
    handles    => [ 'profile_for' ]
);

sub _build_profile_factory {
    my $self = shift;

    LIMS2::Model::FormValidator::ProfileFactory->new( schema => $self->schema );
}

sub check_params {
    my ( $self, $profile_name, $params ) = @_;

    my $results = Data::FormValidator->check( $params, $self->profile_for( $profile_name ) );
    
    if ( ! $results->success ) {        
        LIMS2::Model::Error::Validation->throw( results => $results );
    }

    return scalar $results->valid;
}

sub create_assembly {
    my ( $self, $params ) = @_;

    my $validated_params = $self->check_params( 'create_assembly', $params );

    my $assembly = $self->schema->resultset( 'Assembly' )->create( $validated_params );

    return $assembly->as_hash;
}

sub list_assemblies {
    my ( $self ) = @_;

    return [ map { $_->assembly } $self->schema->resultset( 'Assembly' )->all ];
}

sub create_bac_library {
    my ( $self, $params ) = @_;

    my $validated_params = $self->check_params( 'create_bac_library', $params );

    my $bac_library = $self->schema->resultset( 'BacLibrary' )->create( $validated_params );

    return $bac_library->as_hash;
}

sub list_bac_libraries {
    my ( $self ) = @_;

    [ map { $_->bac_library } $self->schema->resultset( 'BacLibrary' )->all ];
}

sub create_bac_clone {
    my ( $self, $params ) = @_;

    my $validated_params = $self->check_params( 'create_bac_clone', $params );

    my $loci = delete $validated_params->{loci} || [];
    
    my $bac_clone = $self->schema->resultset( 'BacClone' )->create( $validated_params );

    for my $locus ( @{$loci} ) {
        my $validated_locus = $self->check_params( 'create_bac_locus', $locus );
        $bac_clone->create_related( loci => $validated_locus );
    }

    return $bac_clone->as_hash;
}

sub delete_bac_clone {
    my ( $self, $params ) = @_;

    my $validated_params = $self->check_params( 'delete_bac_clone', $params );

    my $bac_clone = $self->schema->resultset( 'BacClone' )->find( $validated_params )
        or LIMS2::Model::Error::NotFound->throw(
            entity_class  => 'BacClone',
            search_params => $validated_params
        );

    for my $locus ( $bac_clone->loci ) {
        $locus->delete;
    }

    $bac_clone->delete;

    return;
}

1;
