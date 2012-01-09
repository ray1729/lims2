package LIMS2::Model::FormValidator::Constraints;

use strict;
use warnings FATAL => 'all';

use Sub::Exporter -setup => {
    exports => [ qw(
                       FV_boolean
                       FV_date_time
                       FV_dna_seq
                       FV_in_set
                       FV_phase
                       FV_strand
                       FV_validated_by_annotation
               ) ]
};

use DateTime::Format::ISO8601;
use Try::Tiny;

sub FV_date_time {
    return sub {
        my $dfv = shift;
        $dfv->name_this( 'date_time' );
        my $val = $dfv->get_current_constraint_value();
        try {
            DateTime::Format::ISO8610->parse_datetime( $val );
        };
    }
}

sub FV_strand {
    FV_in_set( 'strand', 1, -1 );
}
        
sub FV_phase {
    FV_in_set( 'phase', qw( 0 1 2 ) );
}

sub FV_boolean {
    FV_in_set( 'boolean', qw( 0 1 ) )
}

sub FV_validated_by_annotation {
    FV_in_set( 'yes', 'no', 'maybe' );
}

sub FV_in_set {
    my $name = shift;

    my %is_in_set = map { $_ => 1 } @_;

    return sub {
        my $dfv = shift;
        $dfv->name_this( $name );
        my $val = $dfv->get_current_constraint_value();        
        return ( defined $val and $is_in_set{$val} ) || 0;
    }
}

sub FV_dna_seq {

    return sub {
        my $dfv = shift;
        $dfv->name_this( 'dna_seq' );
        return $dfv->get_current_constraint_value() =~ qr/^[ATGC]+$/
    };
}

1;

__END__
