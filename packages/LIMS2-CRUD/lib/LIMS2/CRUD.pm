package LIMS2::CRUD;

use strict;
use warnings FATAL => 'all';

use Moose;
use LIMS2::CRUD::Changeset;
use LIMS2::CRUD::Error::Authorization;
use LIMS2::CRUD::Error::Database;
use LIMS2::CRUD::Error::NotFound;
use LIMS2::CRUD::Error::Validation;
use LIMS2::CRUD::ParameterValidation;
use LIMS2::DBConnect;
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

    my $user_name = $self->username;    
    
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

after txn_do => sub { shift->clear_changeset };

for my $method ( __PACKAGE__->meta->get_method_list ) {
    if ( $method =~ m/^create_/ ) {
        around $method => sub {
            my $orig = shift;
            my $self = shift;
            $self->assert_edit_right;
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
            $self->assert_edit_role( 'edit' );
            my $res = $self->$orig( @_ );
            if ( ! $res->error ) {
                $self->add_changeset_entry( 'update', $res->uri, $res->entity );
            }
            return $res;
        }
    }
    elsif ( $method =~ m/^delete/ ) {
        around $method => sub {
            my $orig = shift;
            my $self = shift;
            $self->assert_has_role( 'edit' );
            my $res = $self->$orig( @_ );
            if ( ! $res->error ) {
                $self->add_changeset_entry( 'delete', $res->uri );
            }
            return $res;            
        }
    }
}

sub create_bac_clone {
    my ( $self, $clone_data ) = @_;

    validate_parameters( $clone_data, [ qw( bac_library bac_name ) ], [ { loci => 'bac_loci' } ] );

    my $bac_library = $self->schema->resultset( 'BacLibrary' )->find(
        {
            bac_library => $clone_data->{bac_library}
        }
    ) or LIMS2::CRUD::Error::Validation->throw(
        message => "BAC Library not found",
        fields  => { bac_library => 'is not a recognized BAC library name' }
    );
    
    my $bac_clone = $bac_library->create_related(
        'bac_clone' => {
            bac_name => $clone_data->{bac_name}
        }
    );

    for my $locus ( @{ $clone_data->{loci} } ) {
        $bac_clone->create_related( loci => $locus );
    }

    return $bac_clone->to_hash;
}

1;
