package LIMS2::HTGT::Migrate::Utils;

use strict;
use warnings FATAL => 'all';

use Sub::Exporter -setup => {
    exports => [
        qw(
              htgt_plate_types
              lims2_plate_type
              format_well_name
              format_bac_library
              is_consistent_design_instance
      )
    ]
};

use Scalar::Util qw( blessed );
use Try::Tiny;
use Log::Log4perl qw( :easy );
use Const::Fast;

{
    
    const my %PLATE_TYPE_FOR => (
        DESIGN => 'design',
        EP     => 'ep',
        EPD    => 'epd',
        FP     => 'fp',
        GR     => 'pgs',
        GRD    => 'pgs',
        GRQ    => 'dna',
        PC     => 'pcs',
        PCS    => 'pcs',
        PGD    => 'pgs',
        PGG    => 'dna',
        REPD   => 'epd',
        VTP    => 'vtp'
    );
    
    sub htgt_plate_types {
        my $type = shift;

        [ grep { $PLATE_TYPE_FOR{$_} eq $type } keys %PLATE_TYPE_FOR ];
    }

    sub lims2_plate_type {
        my $type = shift;

        return $PLATE_TYPE_FOR{$type};
    }
}


sub format_well_name {
    my $well_name = shift;

    uc substr $well_name, -3;
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

sub is_consistent_design_instance {
    my ( $well, $parent_well ) = @_;

    defined $well
        and defined $parent_well
            and defined $well->design_instance_id
                and defined $parent_well->design_instance_id
                    and $well->design_instance_id == $parent_well->design_instance_id;
}

### XXX ABOVE HERE GOOD

sub valid_primers_for_well {
    my ( $well, $qctest_result ) = @_;

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

1;
