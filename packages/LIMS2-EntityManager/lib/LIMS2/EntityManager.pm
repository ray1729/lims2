package LIMS2::EntityManager;

use strict;
use warnings FATAL => 'all';

use Moose;
use MooseX::ClassAttribute;
use LIMS2::EntityManager::Changeset;
use LIMS2::EntityManager::Error::Authorization;
use LIMS2::EntityManager::Error::Implementation;
use LIMS2::EntityManager::Error::Database;
use LIMS2::EntityManager::ValidationFactory;
use LIMS2::DBConnect;
use Try::Tiny;
use Scalar::Util qw( blessed );
use JSON qw( from_json );
use namespace::autoclean;

class_has default_assembly => (
    is      => 'ro',
    isa     => 'Str',
    default => 'NCBIM37'
);

has schema => (
    is         => 'ro',
    isa        => 'LIMS2::Schema',
    lazy_build => 1,
    handles    => [ 'txn_do' ]
);

sub _build_schema {
    LIMS2::DBConnect->connect( 'LIMS2_DB' );
}

has user_name => (
    is        => 'ro',
    isa       => 'Str',
);

has user => (
    is         => 'ro',
    isa        => 'LIMS2::Schema::Result::User',
    lazy_build => 1
);

sub _build_user {
    my $self = shift;

    my $user_name = $self->user_name;    
    
    if ( ! defined $user_name ) {
        LIMS2::EntityManager::Error::Authorization->throw( 'User name or object must be provided' );
    }    
    
    my $user = $self->schema->resultset( 'User' )->find(
        { user_name => $user_name },
        { prefetch  => { user_roles => 'role' } }
    );

    if ( ! $user ) {
        LIMS2::EntityManager::Error::Authorization->throw( "User $user_name not found" );
    }

    return $user;    
}

sub assert_has_role {
    my ( $self, $right ) = @_;
    
    if ( ! $self->user->has_role( $right ) ) {
        LIMS2::EntityManager::Error::Authorization->throw;
    }
}

has in_txn => (
    is       => 'ro',
    isa      => 'Bool',
    traits   => [ 'Bool' ],
    init_arg => undef,
    default  => 0,
    handles  => {
        start_txn => 'set',
        end_txn   => 'unset'
    }
);

sub assert_in_txn {
    my ( $self ) = @_;

    if ( ! $self->in_txn ) {
        LIMS2::EntityManager::Error::Implementation->throw( 'Updates can only be run inside a transaction' );
    }
}

has changeset => (
    is         => 'ro',
    isa        => 'LIMS2::EntityManager::Changeset',
    init_arg   => undef,
    lazy_build => 1,
    handles    => [ 'add_changeset_entry' ]
);

sub _build_changeset {
    return LIMS2::EntityManager::Changeset->new( user => shift->user );
}

around txn_do => sub {
    my $orig = shift;
    my $self = shift;
    my $coderef = shift;
    
    $self->clear_changeset;
    $self->start_txn;
    try {
        $self->$orig( sub { $coderef->() }, @_ );
    }
    catch {
        if ( blessed( $_ ) ) {
            if ( $_->can( 'rethrow' ) ) {                
                $_->rethrow;
            }
            if ( $_->can( 'throw' ) ) {
                $_->throw;
            }
        }
        LIMS2::EntityManager::Error::Database->throw( $_ );
    }
    finally {
        $self->end_txn;
    };
};

has validation_factory => (
    is         => 'ro',
    isa        => 'LIMS2::EntityManager::ValidationFactory',
    init_arg   => undef,
    lazy_build => 1,
    handles    => [ 'validate' ]
);

sub _build_validation_factory {
    my $self = shift;

    LIMS2::EntityManager::ValidationFactory->new( schema => $self->schema );    
}

sub entity_class {
    my ( $self, $what ) = @_;

    my $entity_class = 'LIMS2::Entity::' . $what;

    ( my $pm_path = $entity_class . '.pm' ) =~ s{::}{/}g;

    unless ( exists $INC{$pm_path} ) {
        eval "require $entity_class"
            or LIMS2::EntityManager::Error::Implementation->throw( "Load $entity_class: $@" );
    }

    return $entity_class;
}

sub create {
    my ( $self, $what, $data ) = @_;

    $self->entity_class( $what )->create( $self, $data );
}

sub retrieve {
    my ( $self, $what, $data ) = @_;
    $self->entity_class( $what )->retrieve( $self, $data );
}

sub update {
    my ( $self, $what, $data ) = @_;
    my $obj = $self->entity_class( $what )->retrieve( $self, $data )->[0];
    $obj->update( $data );
}

sub delete {
    my ( $self, $what, $data ) = @_;
    my $obj = $self->entity_class( $what )->retrieve( $self, $data )->[0];
    $obj->delete;
}

sub reverse_changeset {
    my ( $self, $changeset_id, @entry_ids ) = @_;

    my $rs = $self->schema->resultset( 'ChangesetEntry' )->search_rs(
        {
            changeset_id => $changeset_id
        },
        {
            order_by => { -desc => 'changeset_entry_id' }
        }
    );

    if ( @entry_ids ) {
        $rs = $rs->search_rs( { changeset_entry_id => \@entry_ids } );
    }

    while ( my $entry = $rs->next ) {
        my $action = $entry->action;
        my $class  = $self->entity_class( $entry->class );
        my $keys   = from_json( $entry->keys );
        my $entity = from_json( $entry->entity );

        my %params = zip( $class->audit_keys, @{$keys} );
        
        if ( $action eq 'create' ) {
            my $obj = $class->retrieve( $self, \%params )->[0];
            $obj->delete;
        }
        elsif ( $action eq 'update' ) {
            my $obj = $class->retrieve( \%params )->[0];
            $obj->update( $entity );
        }
        elsif ( $action eq 'delete' ) {
            $class->create( $self, $entity );
        }
    }
}

__PACKAGE__->meta->make_immutable;

1;

__END__
