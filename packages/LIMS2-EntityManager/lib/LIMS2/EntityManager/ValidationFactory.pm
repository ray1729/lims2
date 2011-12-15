package LIMS2::EntityManager::ValidationFactory;

use strict;
use warnings FATAL => 'all';

use Moose;
use Regexp::Common;
use Try::Tiny;
use DateTime::Format::ISO8601;
use LIMS2::DBConnect;
use LIMS2::EntityManager::Error::Validation;
use LIMS2::EntityManager::Error::Implementation;
use Const::Fast;
use namespace::autoclean;

has schema => (
    is      => 'ro',
    isa     => 'LIMS2::Schema',
    default => sub { LIMS2::DBConnect->connect( 'LIMS2_DB' ) }
);

sub validate {
    my ( $self, $params, %param_spec ) = @_;

    my $err = LIMS2::EntityManager::Error::Validation->new;
    
    for my $p ( grep $param_spec{$_}{required}, keys %param_spec ) {
        if ( not exists $params->{$p} ) {
            $err->add_field( $p, 'is a required parameter' );
        }
    }

    while ( my ( $p, $v ) = each %{ $params } ) {
        my $this_param_spec = $param_spec{$p};
        if ( ! $this_param_spec ) {
            $err->add_field( $p, 'is not allowed here' );
            next;
        }
        my $validate = 'validate_' . $this_param_spec->{validate}
            or next;
        $self->can( $validate )
            or LIMS2::EntityManager::Error::Implementation->throw( "$validate not implemented" );
        if ( my $mesg = $self->$validate( $v ) ) {
            $err->add_field( $p, $mesg );
        }

        if ( $err->has_fields ) {
            $err->throw;
        }

        return;
    }
}

has valid_bac_libraries => (
    is         => 'ro',
    isa        => 'HashRef',
    init_arg   => undef,
    lazy_build => 1,
    traits     => [ 'Hash' ],
    handles => {
        is_valid_bac_library => 'exists'
    }
);

sub _build_valid_bac_libraries {
    +{ map { $_->bac_library => 1 } shift->schema->resultset( 'BacLibrary' )->all };
}

sub validate_bac_library {
    my ( $self, $str ) = @_;

    unless ( defined $str and $self->is_valid_bac_library( $str ) ) {
        return 'is not a valid BAC library name';
    }

    return;
}

has valid_assemblies => (
    is         => 'ro',
    isa        => 'HashRef',
    init_arg   => undef,
    lazy_build => 1,
    traits     => [ 'Hash' ],
    handles    => {
        is_valid_assembly => 'exists'
    }
);

sub _build_valid_assemblies {
    +{ map { $_->assembly => 1 } shift->schema->resultset( 'Assembly' )->all };
}

sub validate_assembly {
    my ( $self, $assembly ) = @_;

    unless ( defined $assembly and $self->is_valid_assembly( $assembly ) ) {
        return 'must be a valid assembly name';
    }

    return;
}

has valid_chromosomes => (
    is         => 'ro',
    isa        => 'HashRef',
    init_arg   => undef,
    lazy_build => 1,
    traits     => [ 'Hash' ],
    handles    => {
        is_valid_chromosome => 'exists'
    }
);

sub _build_valid_chromosomes {
    +{ map { $_->chromosome => 1 } shift->schema->resultset( 'Chromosome' )->all };
}

sub validate_chromosome {
    my ( $self, $chromosome ) = @_;

    unless ( defined $chromosome and $self->is_valid_chromosome( $chromosome ) ) {
        return 'must be a valid chromosome name';
    }

    return;
}

sub validate_bac_locus {
    my ( $self, $params ) = @_;

    unless ( defined $params and ref $params eq 'HASH' ) {
        return 'BAC locus must be a reference to a hash';
    }

    if ( my $assembly_err = $self->validate_assembly( $params->{assembly} ) ) {
        return 'assembly - ' . $assembly_err;
    }

    if ( my $chromosome_err = $self->validate_chromosome( $params->{chromosome} ) ) {
        return 'chromosome - ' . $chromosome_err;
    }

    if ( my $bac_start_err = $self->validate_integer( $params->{bac_start} ) ) {
        return 'bac_start - ' . $bac_start_err;
    }
    
    if ( my $bac_end_err = $self->validate_integer( $params->{bac_end} ) ) {
        return 'bac_end - ' . $bac_end_err;
    }

    return;
}

sub validate_arrayref {
    my ( $self, $aref ) = @_;

    unless ( defined $aref and ref $aref eq 'ARRAY' ) {
        return 'must be a reference to an array';
    }
    
    return;
}

sub validate_bac_loci {
    my ( $self, $loci ) = @_;

    if ( my $err = $self->validate_arrayref( $loci ) ) {
        return $err;
    }

    for my $locus ( @{ $loci } ) {
        if ( my $err = $self->validate_bac_locus( $locus ) ) {
            return $err;
        }
    }

    return;
}

sub validate_non_empty_str {
    my ( $self, $str ) = @_;

    unless ( defined $str and length $str ) {        
        return "must be a non-empty string";
    }

    return;
}

sub validate_integer {
    my ( $self, $str ) = @_;

    unless ( defined $str and $RE{num}{int}->matches( $str ) ) {
        return "must be an integer";
    }

    return;
}

sub validate_datetime {
    my ( $self, $str ) = @_;

    unless ( defined $str and try { DateTime::Format::ISO8601->parse_datetime( $str ) } ) {
        return "must be a valid date/time";
    }
    
    return;
}

__PACKAGE__->meta->make_immutable;

1;

__END__
