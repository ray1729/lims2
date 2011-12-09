package LIMS2::CRUD::ValidationFactory;

use strict;
use warnings FATAL => 'all';

use Moose;
use Regexp::Common;
use Try::Tiny;
use DateTime::Format::ISO8601;
use LIMS2::DBConnect;
use LIMS2::CRUD::Error::Validation;
use namespace::autoclean;

has schema => (
    is      => 'ro',
    isa     => 'LIMS2::Schema',
    default => sub { LIMS2::DBConnect->connect( 'LIMS2_DB' ) }
);

has validators => (
    isa      => 'HashRef',
    init_arg => undef,
    traits   => [ 'Hash' ],
    handles  => {
        validator_for => 'get'
    },
    default  => sub {
        +{
            assembly    => 'validate_assembly',
            bac_end     => 'validate_integer',
            bac_library => 'validate_bac_library',
            bac_loci    => 'validate_bac_loci',
            bac_locus   => 'validate_bac_locus',
            bac_name    => 'validate_non_empty_str',
            bac_start   => 'validate_integer',
            chromosome  => 'validate_chromosome',
        }
    }
);

sub _param_name_and_validator {
    my ( $self, $param, $required ) = @_;

    my ( $param_name, $validator_name );
    if ( ref $param ) {
        ( $param_name, $validator_name ) = @{$param};
    }
    else {
        ( $param_name, $validator_name ) = ( $param ) x 2;
    }

    return (
        $param_name => {
            validate => $self->validator_for( $validator_name ),
            required => $required
        }
    );
}

sub validate {
    my ( $self, $params, %args ) = @_;

    my %param_spec = (
        map( $self->_param_name_and_validator( $_, 0 ), @{ $args{optional} } ),
        map( $self->_param_name_and_validator( $_, 1 ), @{ $args{required} } )
    );

    my $err = LIMS2::CRUD::Error::Validation->new;
    
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
        my $validate = $this_param_spec->{validate}
            or next;
        if ( my $mesg = $self->$validate( $v ) ) {
            $err->add_field( $p, $mesg );
        }
    }

    if ( $err->has_fields ) {
        $err->throw;
    }

    return;
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
    my ( $self, $locus ) = @_;

    unless ( defined $locus and ref $locus eq 'HASH' ) {
        return 'BAC locus must be a reference to a hash';
    }

    for my $field ( qw( assembly chromosome bac_start bac_end ) ) {
        my $validate = $self->validator_for( $field )
            or next;                       
        if ( my $err = $self->$validate( $locus->{$field} ) ) {
            return $field . ' ' . $err;
        }
    }

    return;
}

sub validate_bac_loci {
    my ( $self, $loci ) = @_;

    unless ( defined $loci and ref $loci eq 'ARRAY' ) {
        return 'BAC loci must be a reference to an array';
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

    unless ( defined $str and $RE{num}{int}->match( $str ) ) {
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
