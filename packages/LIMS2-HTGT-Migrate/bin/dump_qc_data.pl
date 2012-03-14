#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

use HTGT::DBFactory;
use YAML::Any;
use DateTime;
use Log::Log4perl qw( :easy );
use Try::Tiny;
use Const::Fast;
use LIMS2::HTGT::Migrate::Utils qw( trim parse_oracle_date );

Log::Log4perl->easy_init(
    {
        level  => $WARN,
        layout => '%p %x %m%n'
    }
);

const my @ALIGNMENT_FIELDS => qw(
qc_seq_read_id
primer_name
query_start
query_end
query_strand
target_start
target_end
target_strand
op_str
score
pass
features
cigar
);

const my @ALIGN_REGION_FIELDS => qw(
name
length
match_count
query_str
target_str
match_str
pass
);

my $schema = HTGT::DBFactory->connect( 'eucomm_vector' );
my $run_date = DateTime->now;

my $qc_rs;
if ( @ARGV ) {
    $qc_rs = $schema->resultset( 'QCRun' )->search( { qc_run_id => \@ARGV } );
}
else {
    $qc_rs = $schema->resultset( 'QCRun' )->search( { } );
}

while ( my $qc_run = $qc_rs->next ) {
    Log::Log4perl::NDC->push( $qc_run->qc_run_id );

    try {
        my ( $seq_read_ids, $seq_reads ) = get_qc_seq_reads( $qc_run );
        my $qc_run_date = parse_oracle_date( $qc_run->qc_run_date );
        my %qc_run = (
            qc_run_id          => $qc_run->qc_run_id,
            qc_run_date        => $qc_run_date->iso8601,
            sequencing_project => $qc_run->sequencing_project,
            template_plate     => get_template_plate_name( $qc_run->template_plate_id ),
            profile            => $qc_run->profile,
            software_version   => $qc_run->software_version,
            qc_test_results    => get_qc_test_results( $qc_run, $seq_read_ids ),
            qc_seq_reads       => $seq_reads, 
        );
        print YAML::Any::Dump( \%qc_run );
    }
    catch {
        ERROR($_);
    }
    finally {        
        Log::Log4perl::NDC->pop;        
    };    
}

sub get_qc_seq_reads {
    my $qc_run = shift;
    my %seq_read_ids;
    my @seq_reads;

    my $seq_reads_rs = $qc_run->seq_reads;

    while ( my $seq_read = $seq_reads_rs->next ) {
        my %seq_read = (
            qc_seq_read_id => $seq_read->qc_seq_read_id,
            description    => $seq_read->description,
            length         => $seq_read->length,
            seq            => $seq_read->seq,
        );
        $seq_read_ids{ $seq_read->qc_seq_read_id } = 1;
        
        push @seq_reads, \%seq_read;
    }

    return ( \%seq_read_ids, \@seq_reads );
}

sub get_template_plate_name {
    my $template_plate_id = shift;

    my $template_plate = $schema->resultset('Plate')->find(
        { plate_id => $template_plate_id }, { columns => [ 'name' ] } );
    die("Template plate id not found: $template_plate_id") unless $template_plate;

    return $template_plate->name;
}

sub get_qc_test_results {
    my ( $qc_run, $seq_read_ids ) = @_;
    my @qc_test_results;

    my $qc_test_results_rs = $qc_run->test_results;

    while ( my $qc_test_result = $qc_test_results_rs->next ) {
        push @qc_test_results, {
            well_name  => $qc_test_result->well_name,
            score      => $qc_test_result->score,
            pass       => $qc_test_result->pass,
            plate_name => $qc_test_result->plate_name, 
            synvec_id  => $qc_test_result->qc_synvec_id,
            alignments => get_test_result_alignments( $qc_test_result, $seq_read_ids ),
         };
    }
    return \@qc_test_results;
}

sub get_test_result_alignments {
    my ( $qc_test_result, $seq_read_ids ) = @_;
    my @test_result_alignments;

    my $alignments_rs = $qc_test_result->alignments;

    while ( my $alignment = $alignments_rs->next ) {
        my %alignment = map { $_ => $alignment->$_ } @ALIGNMENT_FIELDS;

        die( 'unknown seq read: ' . $alignment{qc_seq_read_id} ) 
            unless exists $seq_read_ids->{ $alignment{qc_seq_read_id} };

        $alignment{align_regions} = get_align_regions( $alignment );
        push @test_result_alignments, \%alignment;
    }

    return \@test_result_alignments;
}

sub get_align_regions {
    my $alignment = shift;
    my @align_regions;

    my $align_regions_rs = $alignment->align_regions;

    while ( my $align_region = $align_regions_rs->next ) {
        my %align_region = map{ $_ => $align_region->$_ } @ALIGN_REGION_FIELDS; 
        push @align_regions, \%align_region;
    }

    return \@align_regions;
}

__END__
