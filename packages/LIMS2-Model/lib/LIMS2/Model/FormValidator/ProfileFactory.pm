package LIMS2::Model::FormValidator::ProfileFactory;

use strict;
use warnings FATAL => 'all';

use Moose;
use Data::FormValidator::Constraints qw( :regexp_common );
use LIMS2::Model::FormValidator::Constraints qw( FV_strand
                                                 FV_phase
                                                 FV_date_time
                                                 FV_validated_by_annotation
                                                 FV_boolean
                                                 FV_dna_seq
                                                 FV_user_name
                                           );
require LIMS2::Model::FormValidator::ConstraintFactory;
use namespace::autoclean;

has schema => (
    is       => 'ro',
    isa      => 'LIMS2::Model::Schema',
    required => 1
);

has constraint_factory => (
    is         => 'ro',
    isa        => 'LIMS2::Model::FormValidator::ConstraintFactory',
    lazy_build => 1,
    handles    => [ 'constraint_for' ]
);

sub _build_constraint_factory {
    my $self = shift;

    return LIMS2::Model::FormValidator::ConstraintFactory->new( schema => $self->schema );
}

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

sub _profile_create_user {
    my $self = shift;

    return {
        required => [ qw( user_name ) ],
        optional => [ qw( roles ) ],
        constraint_methods => {
            user_name => FV_user_name,
            roles     => $self->constraint_for( 'existing_role' )
        }
    };
}

sub _profile_delete_user {
    my $self = shift;

    return {
        required => [ qw( user_name ) ],
        constraint_methods => {
            user_name => FV_user_name
        }
    }
}

sub _profile_create_assembly {
    my $self = shift;

    return {
        required => [ qw( assembly ) ],
        constraint_methods => {
            assembly => qr/^\w+$/
        }
    };
}

sub _profile_delete_assembly {
    my $self = shift;

    return {
        required => [ qw( assembly ) ],
        optional => [ qw( cascade ) ],
        constraint_methods => {
            assembly => qr/^\w+$/,
            cascade  => FV_boolean
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

sub _profile_delete_bac_library {
    my $self = shift;

    return {
        required => [ qw( bac_library ) ],
        optional => [ qw( cascade ) ],
        constraint_methods => {
            bac_library => $self->constraint_for( 'existing_bac_library' ),
            cascade     => FV_boolean
        }
    };    
}

sub _profile_create_bac_clone {
    my $self = shift;

    return {
        required => [ qw( bac_library bac_name ) ],
        optional => [ qw( loci ) ],
        constraint_methods => {
            bac_library => $self->constraint_for( 'existing_bac_library' ),
            bac_name    => qr/^[\w()-]+$/,
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
        required => [ qw( assembly chr_name chr_start chr_end ) ],
        constraint_methods => {
            assembly   => $self->constraint_for( 'existing_assembly' ),
            chr_name   => $self->constraint_for( 'existing_chromosome' ),
            chr_start  => FV_num_int,
            chr_end    => FV_num_int
        }
    };
}

sub _profile_create_design {
    my $self = shift;

    return {
        required => [ qw(
                            design_id
                            design_type
                            created_at
                            created_by
                            oligos
                            phase
                            validated_by_annotation
                    ) ],
        optional => [ qw(
                            design_name
                            comments
                            genotyping_primers
                    ) ],
        constraint_methods => {
            design_id               => FV_num_int,
            design_type             => $self->constraint_for( 'existing_design_type' ),
            created_at              => FV_date_time,
            created_by              => $self->constraint_for( 'existing_user' ),
            phase                   => FV_phase,
            validated_by_annotation => FV_validated_by_annotation,
            design_name             => qr/^\w+$/,
        }
    };    
}

sub _profile_delete_design {
    my $self = shift;

    return {
        required => [ qw( design_id ) ],
        optional => [ qw( cascade ) ],
        constraint_methods => {
            design_id => FV_num_int,
            castaced  => FV_boolean
        }
    };
}

sub _profile_create_design_comment {
    my $self = shift;

    return {
        required => [ qw(
                            design_comment_category
                            created_at
                            created_by
                            is_public
                    ) ],
        optional => [ qw( design_comment ) ],
        constraint_methods => {
            design_comment_category => $self->constraint_for( 'existing_design_comment_category' ),
            design_comment          => qr/\w+/, # Intentionally not anchored, we just want at least *one* word character
            created_at              => FV_date_time,
            created_by              => $self->constraint_for( 'existing_user' ),
            is_public               => FV_boolean
        }    
    };
}

sub _profile_create_design_oligo {
    my $self = shift;

    return {
        required => [ qw( design_oligo_type design_oligo_seq ) ],
        optional => [ qw( loci ) ],
        constraint_methods => {
            design_oligo_type => $self->constraint_for( 'existing_design_oligo_type' ),
            design_oligo_seq  => FV_dna_seq,
        }
    }; 
}

sub _profile_create_design_oligo_locus {
    my $self = shift;

    return {
        required => [ qw(
                            assembly
                            chr_name
                            chr_start
                            chr_end
                            chr_strand
                    )],
        constraint_methods => {
            assembly   => $self->constraint_for( 'existing_assembly' ),
            chr_name   => $self->constraint_for( 'existing_chromosome' ),
            chr_start  => FV_num_int,
            chr_end    => FV_num_int,
            chr_strand => FV_strand
        }
    };
}

sub _profile_create_genotyping_primer {
    my $self = shift;

    return {
        required => [ qw( type seq ) ],
        constraint_methods => {
            genotyping_primer_type => $self->constraint_for( 'existing_genotyping_primer_type' ),
            genotyping_primer_seq  => FV_dna_seq
        }
    };
}

__PACKAGE__->meta->make_immutable;

1;

__END__
