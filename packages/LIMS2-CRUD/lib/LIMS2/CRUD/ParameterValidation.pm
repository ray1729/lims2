package LIMS2::CRUD::ParameterValidation;

use strict;
use warnings FATAL => 'all';

use Sub::Exporter -setup => {
    exports => [ qw( validate_params ) ],
    groups  => {
        default => [ qw( validate_params ) ]
    }
};

use Const::Fast;
use LIMS2::CRUD::ValidatorFactory;
use LIMS2::CRUD::Error::Validation;

{
    
    const my %VALIDATOR_FOR => (
        assembly     => 'NonEmptyString', 
        bac_clone_id => 'Integer',
        bac_end      => 'Integer',
        bac_library  => 'NonEmptyString',
        bac_name     => 'NonEmptyString',
        bac_start    => 'Integer',
        chromosome   => 'NonEmptyString',
        bac_loci     => 'BacLoci'
    );

    sub validator_for {
        my ( $what ) = @_;

        if ( my $v = $VALIDATOR_FOR{$what} ) {
            return LIMS2::CRUD::ValidatorFactory->$v;
        }
        
        return;
    }
}

sub _build_param_spec {
    my ( $params, $required ) = @_;

    return [] unless defined $params and @{$params};
    
    my @param_spec;
    for my $param ( @{$params} ) {
        my ( $param_name, $validator_name );
        if ( ref ( $param ) ) {
            ( $param_name, $validator_name ) = @{$param};
        }
        else {
            ( $param_name, $validator_name ) = ( $param ) x 2;
        }
        push @param_spec,  $param_name => {
            validator => validator_for( $validator_name ),
            required  => $required
        };
    }

    return \@parm_spec;
}

sub validate_params {
    my ( $params, $required, $optional ) = @_;

    my %param_spec = (
        @{ _build_param_spec( $optional, 0 ) },
        @{ _build_param_spec( $required, 1 ) }
    );
    
    my %error_for;
    
    for my $p ( grep { $param_spec{$_}{required} } keys %param_spec ) {
        if ( ! exists $params->{$p} ) {
            $error_for{$p} = 'is a required parameter';
        }
    }

    while ( my ( $p, $v ) = each %{ $params } ) {
        if ( ! $param_spec{$p} ) {
            $error_for{ $p } = 'is not allowed here';
            next;
        }
        my $validator = $param_spec{$p}{validator};
        if ( $validator and not $validator->is_valid( $v ) ) {
            $error_for{$p} = $validator->message;
        }
    }

    if ( keys %error_for ) {
        LIMS2::CRUD::Error::Validation->throw( fields => \%error_for );
    }

    return 1;
}

1;

__END__
