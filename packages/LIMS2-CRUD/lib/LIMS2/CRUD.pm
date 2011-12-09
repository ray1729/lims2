package LIMS2::CRUD;

use strict;
use warnings FATAL => 'all';

use Moose;
use LIMS2::CRUD::Changeset;
use LIMS2::CRUD::Error::Authorization;
use LIMS2::CRUD::Error::Database;
use LIMS2::CRUD::Error::NotFound;
use LIMS2::CRUD::Error::Validation;
use LIMS2::CRUD::Response;
use LIMS2::CRUD::ValidationFactory;
use LIMS2::DBConnect;
use LIMS2::URI qw( uri_for );
use Try::Tiny;
use Scalar::Util qw( blessed );
use namespace::autoclean;

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
        LIMS2::CRUD::Error::Authorization->throw( 'User name or object must be provided' );
    }    
    
    my $user = $self->schema->resultset( 'User' )->find(
        { user_name => $user_name },
        { prefetch  => { user_roles => 'role' } }
    );

    if ( ! $user ) {
        LIMS2::CRUD::Error::Authorization->throw( "User $user_name not found" );
    }

    return $user;    
}

sub assert_has_role {
    my ( $self, $right ) = @_;
    
    if ( ! $self->user->has_role( $right ) ) {
        LIMS2::CRUD::Error::Authorization->throw;
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
        LIMS2::CRUD::Error->throw( 'Updates can only be run inside a transaction' );
    }
}

has changeset => (
    is         => 'ro',
    isa        => 'LIMS2::CRUD::Changeset',
    init_arg   => undef,
    lazy_build => 1,
    handles    => [ 'add_changeset_entry' ]
);

sub _build_changeset {
    return LIMS2::CRUD::Changeset->new( user => shift->user );
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
        LIMS2::CRUD::Error->throw( $_ );
    }
    finally {
        $self->end_txn;
    };
};

has validation_factory => (
    is         => 'ro',
    isa        => 'LIMS2::CRUD::ValidationFactory',
    init_arg   => undef,
    lazy_build => 1,
    handles    => [ 'validate' ]
);

sub _build_validation_factory {
    my $self = shift;

    LIMS2::CRUD::ValidationFactory->new( schema => $self->schema );    
}
    
for my $method ( __PACKAGE__->meta->get_method_list ) {
    if ( $method =~ m/^create_/ ) {
        around $method => sub {
            my $orig = shift;
            my $self = shift;
            $self->assert_has_role( 'edit' );
            $self->assert_in_txn;            
            my $res = $self->$orig( @_ );
            $self->add_changeset_entry( 'create', $res->uri, $res->entity );
            return $res;
        }
    }
    elsif ( $method =~ m/^read/ ) {
        around $method = sub {
            my $orig = shift;
            my $self = shift;
            $self->assert_has_role( 'read' );
            $self->$orig(@_);
        }
    }    
    elsif ( $method =~ m/^update_/ ) {
        around $method => sub {
            my $orig = shift;
            my $self = shift;
            $self->assert_has_role( 'edit' );
            $self->assert_in_txn;            
            my $res = $self->$orig( @_ );
            $self->add_changeset_entry( 'update', $res->uri, $res->entity );
            return $res;
        }
    }
    elsif ( $method =~ m/^delete/ ) {
        around $method => sub {
            my $orig = shift;
            my $self = shift;
            $self->assert_has_role( 'edit' );
            $self->assert_in_txn;            
            my $res = $self->$orig( @_ );
            $self->add_changeset_entry( 'delete', $res->uri );
            return $res;            
        }
    }
}

sub create_bac_clone {
    my ( $self, $clone_data ) = @_;
    
    $self->validate( $clone_data,                               
                     required => [ qw( bac_library bac_name ) ],
                     optional => [ { loci => 'bac_loci' } ]
                 );

    my $bac_clone = $self->schema->resultset( 'BacClone' )->create(
        {
            bac_library => $clone_data->{bac_library},
            bac_name    => $clone_data->{bac_name}
        }
    );

    if ( exists $clone_data->{loci} ) {        
        for my $locus ( @{ $clone_data->{loci} } ) {
            $self->create_bac_clone_locus( { bac_library => $clone_data->{bac_library},
                                             bac_name    => $clone_data->{bac_name},
                                             locus       => $locus } );            
        }
    }
    
    return LIMS2::CRUD::Response->new( bac_clone => $bac_clone->as_hash );
}

sub _retrieve_bac_clone {
    my ( $self, $bac_library, $bac_name ) = @_;

    my $bac_clone = $self->schema->resultset( 'BacClone' )->find(
        {
            bac_library => $bac_library,
            bac_name    => $bac_name
        }
    ) or LIMS2::CRUD::Error::NotFound->throw( "BAC clone $bac_library/$bac_name not found" );

    return $bac_clone;
}

sub read_bac_clone {
    my ( $self, $clone_data ) = @_;

    $self->validate( $clone_data, required => [ qw( bac_library bac_name ) ] );

    my $bac_clone = $self->_retrieve_bac_clone( @{$clone_data}{ qw( bac_library bac_name ) } );

    return LIMS2::CRUD::Response->new( bac_clone => $bac_clone->as_hash );    
}

sub delete_bac_clone {
    my ( $self, $clone_data ) = @_;

    $self->validate( $clone_data, required => [ qw( bac_library bac_name ) ] );

    my $bac_clone = $self->_retrieve_bac_clone( @{$clone_data}{ qw( bac_library bac_name ) } );

    my $orig = $bac_clone->as_hash;
    
    $bac_clone->loci_rs->delete;
    $bac_clone->delete;

    return LIMS2::CRUD::Response->new( bac_clone => $orig );
}

sub create_bac_clone_locus {
    my ( $self, $clone_data ) = @_;

    $self->validate( $clone_data,
                     required => [ qw( bac_library bac_name ), { locus => 'bac_locus' } ] );

    my $bac_clone = $self->_retrieve_bac_clone( @{$clone_data}{ qw( bac_library bac_name ) } );
    
    my $locus = $bac_clone->create_related( loci => $clone_data->{locus} );

    return LIMS2::CRUD::Response->new( bac_clone_locus => $locus->as_hash_full );
}

sub _retrieve_bac_clone_locus {
    my ( $self, $bac_library, $bac_name, $assembly ) = @_;

    my $locus = $self->schema->resultset( 'BacCloneLocus' )->find(
        {
            'bac_clone.bac_library' => $bac_library,
            'bac_clone.bac_name'    => $bac_name,
            'me.assembly'           => $assembly
        },
        {
            join => 'bac_clone'
        }
    ) or LIMS2::CRUD::Error::NotFound->throw(
        "Locus for BAC clone $bac_library/$bac_name on assembly $assembly not found"
    );

    return $locus;
}

sub update_bac_clone_locus {
    my ( $self, $clone_data ) = @_;

    $self->validate( $clone_data,
                     required => [ qw( bac_library bac_name assembly chromosome bac_start bac_end ) ] );

    my $locus = $self->_retrieve_bac_clone_locus( @{$clone_data}{ qw( bac_library bac_name assembly ) } );

    $locus->update( $clone_data->{locus} );

    return LIMS2::CRUD::Response->new( bac_clone_locus => $locus->as_hash_full );
}

sub delete_bac_clone_locus {
    my ( $self, $clone_data ) = @_;

    $self->validate( $clone_data,
                     required => [ qw( bac_library bac_name assembly ) ],
                     optional => [ qw( chromosome bac_start bac_end ) ] );

    my $locus = $self->_retrieve_bac_clone_locus( @{$clone_data}{ qw( bac_library bac_name assembly ) } );

    my $orig = $locus->as_hash_full;
    
    $locus->delete;

    return LIMS2::CRUD::Response->new( bac_clone_locus => $orig );
}

1;
