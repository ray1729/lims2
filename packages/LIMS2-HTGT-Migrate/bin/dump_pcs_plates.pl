#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

use HTGT::DBFactory;
use YAML::Any;
use Log::Log4perl qw( :easy );
use DateTime;
use Try::Tiny;
use List::Util qw( min max );
use Const::Fast;
use LIMS2::HTGT::Migrate::Utils qw( trim parse_oracle_date format_bac_library format_well_name
                                    valid_primers_for_well );

const my $DEFAULT_BACKBONE => 'R3R4_pBR_DTA+_Bsd_amp';
const my $DEFAULT_CASSETTE => 'pR6K_R1R2_ZP';

Log::Log4perl->easy_init(
    {
        level  => $WARN,
        layout => '%p %x %m%n'
    }
);

my $htgt = HTGT::DBFactory->connect( 'eucomm_vector' );

my $run_date = DateTime->now;

my $pcs_plate_rs = $htgt->resultset( 'Plate' )->search(
    {
        'me.type' => [ 'PC', 'PCS' ],
    },
);

while ( my $plate = $pcs_plate_rs->next ) {
    Log::Log4perl::NDC->push( $plate->name );
    try {
        my $data = pcs_plate_data( $plate );
        print Dump( $data );
    }
    catch {
        ERROR($_);
    }
    finally {        
        Log::Log4perl::NDC->pop;
    }    
}

sub pcs_plate_data {
    my $plate = shift;

    my $created_date = $plate->created_date || $run_date;   

    my %plate_data = map { trim($_->data_type) => trim($_->data_value) } $plate->plate_data;

    # Replace qc_done=yes with the date that plate_data was entered
    if ( $plate_data{qc_done} and $plate_data{qc_done} eq 'yes' ) {
        my $qc_done = $plate->search_related( plate_data => { data_type => 'qc_done' } )->first;
        $plate_data{qc_done} = parse_oracle_date( $qc_done->edit_date );
    }

=pod

DATA_TYPE	  COUNT
archive_label     268
archive_quadrant  268
clone_selection   122
first_qc_date     71
is_384            787
plate_label       268
qc_done           281
sponsor           7

    # plate_label, archive_label, and archive_quadrant: load archive data later
    # is_384: introduce plate_groups ?
    # qc_done: use to set assay_complete date
    # first_qc_date: use to set assay_pending date

=cut
    
    my %data = (
        plate_name  => $plate->name,
        plate_type  => 'pcs',
        plate_desc  => $plate->description || '',
        created_by  => $plate->created_user || 'migrate_script',
        created_at  => $created_date->iso8601,
        comments    => comments_for( $plate, $created_date ),
        wells       => wells_for( $plate, \%plate_data, $created_date )
    );
    
    # Add 384-well plates to a plate group
    if ( $plate_data{is_384} and $plate_data{is_384} eq 'yes' ) {
        ( my $plate_group = $plate->name ) =~ s/_\d+$//
            or die "Failed to determine plate group for " . $plate->name;
        $data{plate_group} = $plate_group;
    }
    
    # XXX What about plate_blobs?
    
    return \%data;
}

sub comments_for {
    my ( $plate, $created_date ) = @_;

    my @comments;

    for my $c ( $plate->plate_comments ) {
        my $created_at = parse_oracle_date( $c->edit_date ) || $created_date;        
        push @comments, {
            plate_comment => $c->plate_comment,
            created_by    => $c->edit_user || 'migrate_script',
            created_at    => $created_at->iso8601
        }
    }

    return \@comments;
}

sub wells_for {
    my ( $plate, $plate_data, $created_date ) = @_;

    my %wells;

    for my $well ( $plate->wells ) {
        my $well_name = format_well_name( $well->well_name );
        die "Duplicate well $well_name" if $wells{$well_name};
        $wells{$well_name} = well_data_for( $well, $plate_data, $created_date );
    }

    return \%wells;
}

sub is_consistent_design_instance {
    my ( $well, $parent_well ) = @_;

    defined $well
        and defined $parent_well
            and defined $well->design_instance_id
                and defined $parent_well->design_instance_id
                    and $well->design_instance_id == $parent_well->design_instance_id;
}


sub well_data_for {
    my ( $well, $plate_data, $created_date ) = @_;    

    return {} unless defined $well->design_instance_id;
        
    my $parent_well = $well->parent_well;

    unless ( is_consistent_design_instance( $well, $parent_well ) ) {
        WARN "$well design instance mismatch";
        return {};
    }

=pod

    DATA_TYPE             COUNT
    clone_name            99051 X
    pass_level            98606 X
    qctest_result_id      97535 X
    backbone              23979 X
    distribute            22931 X
    cassette                384 X
    new_qc_test_result_id   188 X
    valid_primers           144 X
    COMMENTS                 13

=cut


    my %well_data  = map { trim($_->data_type) => trim($_->data_value) } $well->well_data;

    my %data = (
        parent_well              => {
            plate_name => $parent_well->plate->name,
            well_name  => $parent_well->well_name
        },
        cassette                 => $well_data{cassette} || $DEFAULT_CASSETTE,
        backbone                 => $well_data{backbone} || $DEFAULT_BACKBONE,
        clone_name               => $well_data{clone_name},
        accepted                 => $well_data{distribute} && $well_data{distribute} eq 'yes' ? 1 : 0
    );

    if ( $plate_data->{first_qc_date} ) {
        $data{assay_pending} = parse_oracle_date( $plate_data->{first_qc_date} )->iso8601;        
    }

    if ( $plate_data->{qc_done} ) {
        $data{assay_complete} = $plate_data->{qc_done}->iso8601;
    }
    
    if ( $well_data{qctest_result_id} ) {
        $data{legacy_qc_test_result} = {
            qc_test_result_id => $well_data{qctest_result_id},
            pass_level        => $well_data{pass_level},
            valid_primers     => valid_primers_for_well( $well, $well_data{qctest_result_id} )
        }
    }

    if ( $well_data{new_qc_test_result_id} ) {
        $data{qc_test_result} = {
            qc_test_result_id => $well_data{new_qc_test_result_id},
            valid_primers     => $well_data{valid_primers},
            pass              => $well_data{pass_level} && $well_data{pass_level} eq 'pass' ? 1 : 0,
            mixed_reads       => $well_data{mixed_reads} && $well_data{mixed_reads} eq 'yes' ? 1 : 0
        };
    }
    

    return \%data;
}
