package LIMS2::CRUD::ValidatorFactory;

use strict;
use warnings FATAL => 'all';

use Moose;
use Const::Fast;
use Regexp::Common;
use Try::Tiny;
use DateTime::Format::ISO8601;
use namespace::autoclean;

const my %VALIDATORS => (
    NonEmptyString => LIMS2::CRUD::Validator->new(
        message  => 'must be a non-empty string',
        validate => qr/\w+/
    ),
    Integer => LIMS2::CRUD::Validator->new(
        message  => 'must be an integer',
        validate => $RE{num}{int}
    ),
    Date => LIMS2::CRUD::Validator->new(
        message  => 'must be a valid date',
        validate => \&_validate_datetime
    ),
    TimeStamp => LIMS2::CRUD::Validator->new(
        message  => 'must be a valid timestamp',
        validate => \&_validate_datetime
    ),
    BacLoci => LIMS2::CRUD::Validator->new(
        message  => 'must be a valid BAC locus',
        validate => \&_validate_bac_loci
    )
);

for my $method ( keys %VALIDATORS ) {
    __PACKAGE__->meta->add_method( $method => sub { $VALIDATORS{$method} } );
}

sub _validate_datetime {
    my $datetime = shift;

    my $is_valid = 0;
    
    try {
        DateTime::Format::ISO8601->parse_datetime( $datetime );
        $is_valid = 1;
    };
    
    return $is_valid;
}

sub _validate_bac_loci {
    my $loci = shift;

    return unless ref $loci eq 'ARRAY';    
    
    for my $locus ( @{$loci} ) {
        for my $param ( qw( assembly chromosome bac_start bac_end ) ) {
            
        
        validate_parameters( $locus, [ qw( assembly chromosome bac_start bac_end ) ] );
    }
        

    
}

__PACKAGE__->meta->make_immutable;

1;

__END__
