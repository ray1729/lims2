package LIMS2::Model;

use strict;
use warnings FATAL => 'all';

use Moose;
require LIMS2::Model::DBConnect;
require LIMS2::Model::FormValidator;
require LIMS2::Model::Error::Validation;
require LIMS2::Model::Error::NotFound;
require DateTime::Format::ISO8601;
require Module::Pluggable::Object;
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

has form_validator => (
    is         => 'ro',
    isa        => 'LIMS2::Model::FormValidator',
    lazy_build => 1,
    handles    => [ 'check_params' ]
);

sub _build_form_validator {
    my $self = shift;

    return LIMS2::Model::FormValidator->new( model => $self );
}

sub throw {
    my ( $self, $error_class, $args ) = @_;

    if ( $error_class !~ /::/ ) {
        $error_class = 'LIMS2::Model::Error::' . $error_class;
    }

    $error_class->throw( $args );
}

sub parse_date_time {
    my ( $self, $date_time ) = @_;

    DateTime::Format::ISO8601->parse_datetime( $date_time );
}

sub plugins {
    my $class = shift;

    Module::Pluggable::Object->new( search_path => [ $class . '::Plugin' ] )->plugins;
}
    
with ( __PACKAGE__->plugins );

1;
