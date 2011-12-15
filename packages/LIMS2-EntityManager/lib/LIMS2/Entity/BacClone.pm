package LIMS2::Entity::BacClone;

use strict;
use warnings FATAL => 'all';

use Moose;
use LIMS2::EntityManager::Error::Validation;
use LIMS2::EntityManager::Error::NotFound;
use namespace::autoclean;

extends qw( LIMS2::Entity );

has dbic_obj => (
    is      => 'ro',
    isa     => 'LIMS2::Schema::Result::BacClone',
    handles => [
        qw( bac_name bac_library bac_clone_id loci as_hash )
    ]
);

override audit_key_cols => sub {
    qw( bac_library bac_name );    
};

augment create => sub {
    my ( $class, $entity_manager, $params ) = @_; 

    $entity_manager->validate(
        $params,
        bac_library => {
            validate => 'bac_library',
            required => 1
        },
        bac_name => {
            validate => 'non_empty_str',
            required => 1
        },
        loci => {
            validate => 'bac_loci',
            required => 0
        }
    );
    
    my $dbic_obj = $entity_manager->schema->resultset( 'BacClone' )->create(
        {
            bac_library => $params->{bac_library},
            bac_name    => $params->{bac_name}
        }
    );

    my $self = $class->new( entity_manager => $entity_manager, dbic_obj => $dbic_obj );

    if ( exists $params->{loci} ) {
        for my $locus ( @{ $params->{loci} } ) {
            $dbic_obj->create_related( loci => $locus );
        }
    }

    return $self;
};

sub locus {
    my ( $self, $assembly ) = @_;

    $self->entity_manager->retrieve(
        BacCloneLocus => {
            bac_clone_id => $self->bac_clone_id,
            assembly     => $assembly
        }
    )->[0];
}    

sub add_locus {
    my ( $self, $params ) = @_;

    $self->entity_manager->create(
        BacCloneLocus => {
            bac_clone_id => $self->bac_clone_id,
            assembly     => $params->{assembly},
            chromosome   => $params->{chromosome},
            bac_start    => $params->{bac_start},
            bac_end      => $params->{bac_end}
        } );
}

sub delete_locus {
    my ( $self, $params ) = @_;

    $self->entity_manager->delete(
        BacCloneLocus => {
            bac_clone_id => $self->bac_clone_id,
            assembly     => $params->{assembly}
        }
    );
}

sub update_locus {
    my ( $self, $params ) = @_;

    my $locus = $self->entity_manager->retrieve(
        BacCloneLocus => {
            bac_clone_id => $self->bac_clone_id,
            assembly     => $params->{assembly}
        }
    )->[0];

    $locus->update( $params );
}

augment delete => sub {
    my ( $self ) = @_;

    $self->dbic_obj->search_related_rs( 'loci' )->delete;
    $self->dbic_obj->delete;

    return;
};

augment retrieve => sub {
    my ( $class, $entity_manager, $params ) = @_;

    my ( %search );
    
    if ( exists $params->{bac_library} and exists $params->{bac_name} ) {
        $search{'me.bac_library'} = $params->{bac_library};
        $search{'me.bac_name'}    = $params->{bac_name};
    }
    elsif( exists $params->{bac_library} and  exists $params->{chromosome} and exists $params->{bac_start} and exists $params->{bac_end} ) {
        $search{'me.bac_library'} = $params->{bac_library};        
        $search{'loci.assembly'}  = $params->{assembly} || $entity_manager->default_assembly;
        $search{'loci.bac_start'} = { '<=', $params->{bac_start} };
        $search{'loci.bac_end'}   = { '>=', $params->{bac_end} }; 
    }

    my $rs = $entity_manager->schema->resultset( 'BacClone' )->search_rs(
        \%search,
        {
            join     => 'loci',
            prefetch => 'loci'
        }
    );

    my @bac_clones = map { $class->new( dbic_obj => $_, entity_manager => $entity_manager ) } $rs->all;
    
    LIMS2::EntityManager::Error::NotFound->throw( "No matching BAC clones found" )
            unless @bac_clones;
    
    return \@bac_clones;
};

__PACKAGE__->meta->make_immutable;

1;

__END__
