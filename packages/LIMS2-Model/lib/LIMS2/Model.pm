package LIMS2::Model;

use strict;
use warnings FATAL => 'all';

use Moose;
use Data::FormValidator;
require LIMS2::Model::DBConnect;
require LIMS2::Model::FormValidator::ProfileFactory;
require LIMS2::Model::Error::Validation;
require LIMS2::Model::Error::NotFound;
use Module::Pluggable::Object;
use namespace::autoclean;

# XXX TODO: authorization checks?

# This assumes we're using Catalyst::Model::Factory::PerRequest and
# setting the audit_user when the LIMS2::Model object is
# instantiated. If necessary, we could make audit_user rw and allow
# the model object to be reused.

has audit_user => (
    is      => 'ro',
    isa     => 'Str',
    trigger => \&_audit_user_set
);

sub _audit_user_set {
    my ( $self, $user, $old_user ) = @_;

    $self->schema->storage->dbh_do(
        sub {
            my ( $storage, $dbh ) = @_;
            $dbh->do( 'SET SESSION ROLE ' . $dbh->quote_identifier( $user ) );
        }
    );           
}

has schema => (
    is         => 'ro',
    isa        => 'LIMS2::Model::Schema',
    lazy_build => 1,
    handles    => [ 'txn_do', 'txn_rollback' ]
);

sub _build_schema {
    my $self = shift;

    return LIMS2::Model::DBConnect->connect( 'LIMS2_DB' );
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

sub throw {
    my ( $self, $error_class, $args ) = @_;

    if ( $error_class !~ /::/ ) {
        $error_class = 'LIMS2::Model::Error::' . $error_class;
    }

    $error_class->throw( $args );
}

sub check_params {
    my ( $self, $profile_name, $params ) = @_;

    my $results = Data::FormValidator->check( $params, $self->profile_for( $profile_name ) );
    
    if ( ! $results->success ) {
        $self->throw( Validation => { results => $results } );
    }

    return scalar $results->valid;
}

sub plugins {
    my $class = shift;

    Module::Pluggable::Object->new( search_path => [ $class . '::Plugin' ] )->plugins;
}
    
with ( __PACKAGE__->plugins );

1;
