package LIMS2::Model::FormValidator::ProfileFactory;

use strict;
use warnings FATAL => 'all';

use Moose;
use Data::FormValidator::Constraints qw( :regexp_common );
use LIMS2::Model::FormValidator::Constraints;
use namespace::autoclean;

has schema => (
    is       => 'ro',
    isa      => 'LIMS2::Model::Schema',
    required => 1
);

sub profile_for {
    my ( $self, $what ) = @_;

    my $method = '_profile_' . $what;
    
    confess "No validation profile defined for $what"
        unless $self->can( $method );

    my $profile = $self->$method();

    # Make sure the 'trim' filter is set for every profile    
    $profile->{filters} ||= [];
    if ( ! grep { $_ eq 'trim' } @{ $profile->{filters} } ) {
        unshift @{ $profile->{filters} }, 'trim';
    }

    return $profile;
}

sub _profile_create_assembly {
    my $self = shift;

    return {
        required => [ qw( assembly ) ],
        constraint_methods => {
            assembly => qr/^\w+/
        }
    };
}

sub _profile_create_bac_library {
    my $self = shift;
    
    return {
        required => [ qw( bac_library ) ],
        constraint_methods => {
            bac_library => qr/^\w+$/
        }
    };
}

sub _profile_create_bac_clone {
    my $self = shift;

    return {
        required => [ qw( bac_library bac_name ) ],
        optional => [ qw( loci ) ],
        constraint_methods => {
            bac_library => existing_bac_library( $self->schema ),
            bac_name    => qr/^\w+$/
        }
    };
}

sub _profile_delete_bac_clone {
    my $self = shift;

    return $self->_profile_create_bac_clone;
}       

sub _profile_create_bac_locus {
    my $self = shift;

    return {
        required => [ qw( assembly chromosome bac_start bac_end ) ],
        constraint_methods => {
            assembly     => existing_assembly( $self->schema ),
            chromosome   => existing_chromosome( $self->schema ),
            bac_start    => FV_num_int,
            bac_end      => FV_num_int
        }
    };
}

__PACKAGE__->meta->make_immutable;

1;

__END__
