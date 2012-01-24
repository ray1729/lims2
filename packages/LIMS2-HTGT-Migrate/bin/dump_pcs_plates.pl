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

const my %IS_SEQUENCING_QC_PASS => map { $_ => 1 } qw(                                                         
        pass
        pass1
        pass2
        pass2.1
        pass2.2
        pass2.3
        pass3
        pass4
        pass4.1
        pass4.3
        passa
        pass1a
        pass2a
        pass2.1a
        pass2.2a
        pass2.3a
        pass3a
        pass4a
        pass4.1a
        pass4.3a                                                         
);

Log::Log4perl->easy_init(
    {
        level  => $WARN,
        layout => '%p %x %m%n'
    }
);

my $htgt = HTGT::DBFactory->connect( 'eucomm_vector' );

my $vector_qc = HTGT::DBFactory->connect( 'vector_qc' );

my $run_date = DateTime->now;

my $pcs_plate_rs = $htgt->resultset( 'Plate' )->search(
    {
        'me.type' => [ 'PC', 'PCS' ],
    },
    {
        order_by => { -asc => 'created_date' }
    }
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

    my %plate_data = map { trim($_->data_type) => $_ } $plate->plate_data;

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
    if ( $plate_data{is_384} and $plate_data{is_384}->data_value eq 'yes' ) {
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

    my %well_data  = map { trim($_->data_type) => $_ } $well->well_data;

    my %data = (
        parent_wells => [
            {
                plate_name => $parent_well->plate->name,
                well_name  => $parent_well->well_name
            },
        ],
        cassette     => $well_data{cassette} ? $well_data{cassette}->data_value : $DEFAULT_CASSETTE,
        backbone     => $well_data{backbone} ? $well_data{backbone}->data_value : $DEFAULT_BACKBONE,
    );

    if ( $well_data{clone_name} ) {
        $data{clone_name} = $well_data{clone_name}->data_value;
    }    

    if ( my $dist = $well_data{distribute} ) {
        $data{accepted} = {
            accepted   => $dist->data_value eq 'yes' ? 1 : 0,
            created_at => parse_oracle_date( $dist->edit_date )->iso8601,
            created_by => $dist->edit_user || 'migrate_script'
        };        
    }    

    if ( $plate_data->{first_qc_date} ) {
        $data{assay_pending} = parse_oracle_date( $plate_data->{first_qc_date}->data_value )->iso8601;        
    }

    if ( $plate_data->{qc_done} ) {
        $data{assay_complete} = parse_oracle_date( $plate_data->{qc_done}->edit_date )->iso8601;
    }

    my $legacy_qc_data = get_legacy_qc_data( $well, \%well_data );
    
    if ( $legacy_qc_data ) {
        $data{legacy_qc_test_result} = $legacy_qc_data->{legacy_qc_test_result};
        $data{assay_results}         = $legacy_qc_data->{assay_results};
        unless ( $data{assay_pending} and $data{assay_pending} le $legacy_qc_data->{assay_pending} ) {
            $data{assay_pending} = $legacy_qc_data->{assay_pending};
        }
        unless ( $data{assay_complete} and $data{assay_complete} ge $legacy_qc_data->{assay_complete} ) {
            $data{assay_complete} = $legacy_qc_data->{assay_complete};
        }        
    }

    if ( $well_data{new_qc_test_result_id} ) {
        my $qc_date = parse_oracle_date( $well_data{new_qc_test_result_id}->edit_date )->iso8601;
        $data{qc_test_result} = {
            qc_test_result_id => $well_data{new_qc_test_result_id}->data_value,
            valid_primers     => $well_data{valid_primers} ? $well_data{valid_primers}->data_value : '',
            pass              => $well_data{pass_level} && $well_data{pass_level}->data_value eq 'pass' ? 1 : 0,
            mixed_reads       => $well_data{mixed_reads} && $well_data{mixed_reads}->data_value eq 'yes' ? 1 : 0
        };
        $data{assay_results} = [
            {
                assay      => 'sequencing_qc',
                result     => $well_data{pass_level}->data_value,
                created_at => $qc_date,
                created_by => $well_data{new_qc_test_result_id}->edit_user || 'migrate_script'
            }
        ];
        unless ( $data{asasy_pending} and $data{asasy_pending} le $qc_date ) {
            $data{assay_pending} = $qc_date;
        }
        unless ( $data{assay_complete} and $data{assay_complete} ge $qc_date ) {
            $data{assay_complete} = $qc_date;
        }
    }    

    return \%data;
}

sub get_legacy_qc_data {
    my ( $well, $well_data ) = @_;    

    return unless $well_data->{qctest_result_id};
    
    my $qctest_result = $vector_qc->resultset( 'QctestResult' )->find(
        {
            qctest_result_id => $well_data->{qctest_result_id}->data_value
        }
    ) or return;
    
    my $run_date = parse_oracle_date( $qctest_result->qctestRun->run_date )->iso8601;

    my %data;
    
    $data{legacy_qc_test_result} = {
        qc_test_result_id => $well_data->{qctest_result_id}->data_value,
        pass_level        => $well_data->{pass_level} ? $well_data->{pass_level}->data_value : 'fail',
        valid_primers     => valid_primers_for_well( $well, $qctest_result )
    };

    $data{assay_pending} = $run_date;

    $data{assay_results} = [
        {
            assay      => 'sequencing_qc',
            result     => exists $IS_SEQUENCING_QC_PASS{ $data{legacy_qc_test_result}{pass_level} } ? 'pass' : 'fail',
            created_at => $run_date,
            created_by => $well_data->{qctest_result_id}->edit_user || 'migrate_script'
        }
    ];

    $data{assay_complete} = parse_oracle_date( $well_data->{qctest_result_id}->edit_date )->iso8601;

    return \%data;
}
