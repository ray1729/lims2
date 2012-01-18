package LIMS2::HTGT::Migrate::Utils;

use strict;
use warnings FATAL => 'all';

use Sub::Exporter -setup => {
    exports => [ qw(
                       parse_oracle_date
                       format_bac_library
                       format_well_name
                       trim
                       valid_primers_for_well
               )
             ]
};

use HTGT::DBFactory;
use DateTime::Format::Oracle;
use Scalar::Util qw( blessed );
use Try::Tiny;
use DateTime;
use Log::Log4perl qw( :easy );

sub format_well_name {
    my $well_name = shift;

    uc substr $well_name, -3;
}

sub parse_oracle_date {
    my $maybe_date = shift;

    if ( ! defined $maybe_date ) {
        return;
    }    
    elsif ( ref $maybe_date ) {
        return $maybe_date;
    }

    my $date = try {
        DateTime::Format::Oracle->parse_timestamp( $maybe_date );
    };

    return $date if defined $date;

    $date = try {
        DateTime::Format::Oracle->parse_datetime( $maybe_date );
    };        

    return $date;
}

sub format_bac_library {
    my $str = shift;

    if ( $str eq '129' ) {
        return $str;
    }
    elsif ( $str eq 'black6' or $str eq 'black6_M37' ) {
        return 'black6';
    }
    else {
        die "Unrecognized bac_library: '$str'";
    }
}

sub trim {
    my $str = shift;

    $str = '' unless defined $str;
    
    for ( $str ) {
        s/^\s+//;
        s/\s+$//;
    }

    return $str;
}

{
    my $qc_schema;
    
    sub valid_primers_for_well {
        my ( $well, $qctest_result_id ) = @_;

        $qctest_result_id ||= $well->well_data_value( 'qctest_result_id' );
        unless ( defined $qctest_result_id ) {
            DEBUG( "no QC test result id for $well" );
            return {};
        }

        $qc_schema ||= HTGT::DBFactory->connect( 'vector_qc' );
                
        my $qctest_result = $qc_schema->resultset( 'QctestResult' )->find(
            {
                qctest_result_id => $qctest_result_id
            }
        );

        unless ( $qctest_result ) {
            DEBUG( "QC test result $qctest_result_id not found" );
            return {};        
        }

        my %valid_primers;
    
        foreach my $primer ( $qctest_result->qctestPrimers ) {
            my $seq_align_feature = $primer->seqAlignFeature
                or next;
            my $loc_status = $seq_align_feature->loc_status
                or next;
            $valid_primers{ uc( $primer->primer_name ) } = 1
                if $loc_status eq 'ok';
        }

        DEBUG( "valid primers for $well: " . join( q{, }, keys %valid_primers ) );
        
        return join( q{,}, sort keys %valid_primers );
    }
}




1;
