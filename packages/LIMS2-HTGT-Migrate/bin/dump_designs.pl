#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

use HTGT::DBFactory;
use YAML::Any;
use DateTime;
use DateTime::Format::Oracle;
use Log::Log4perl qw( :easy );
use Try::Tiny;
use Const::Fast;

const my $ASSEMBLY => 'NCBIM37';

const my @WANTED_DESIGN_STATUS => ( 'Ready to order', 'Ordered' );

const my @GENOTYPING_PRIMER_NAMES => qw( GF1 GF2 GF3 GF4
                                         GR1 GR2 GR3 GR4
                                         LF1 LF2 LF3
                                         LR1 LR2 LR3
                                         PNFLR1 PNFLR2 PNFLR3
                                         EX3 EX32 EX5 EX52 );

const my @OLIGO_NAMES => qw( G5 U5 U3 D5 D3 G3 );

Log::Log4perl->easy_init(
    {
        level  => $WARN,
        layout => '%p %x %m%n'
    }
);

my $schema = HTGT::DBFactory->connect( 'eucomm_vector' );

my $run_date = DateTime->now;

my $designs_rs = $schema->resultset( 'Design' )->search(
    {
        'statuses.is_current'            => 1,
        'design_status_dict.description' => \@WANTED_DESIGN_STATUS
    },
    {
        join => { 'statuses' => 'design_status_dict' }
    }
);

while ( my $design = $designs_rs->next ) {
    Log::Log4perl::NDC->push( $design->design_id );
    try {
        my $type = type_for( $design );
        my %design = (
            design_id               => $design->design_id,
            design_name             => $design->find_or_create_name,
            design_type             => $type,
            created_user            => $design->created_user || 'migrate_script',
            created_at              => format_date( $design->created_date ),
            phase                   => phase_for( $design, $type ),
            validated_by_annotation => $design->validated_by_annotation || '',
            oligos                  => oligos_for( $design ),
            genotyping_primers      => genotyping_primers_for( $design ),
            comments                => comments_for( $design )        
        );
        print YAML::Any::Dump( \%design );
    }
    catch {
        ERROR($_);
    }
    finally {        
        Log::Log4perl::NDC->pop;        
    };    
}

sub oligos_for {
    my $design = shift;

    my @oligos;

    my $features = $design->validated_display_features;

    for my $oligo_name ( @OLIGO_NAMES ) {
        my $oligo = $features->{$oligo_name} or next;
        my @oligo_seq = grep { $_->feature_data_type->description eq 'sequence' } $oligo->feature->feature_data;
        unless ( @oligo_seq == 1 ) {
            WARN( 'Found ' . @oligo_seq . ' sequences for oligo ' . $oligo_name );
            next;
        }
        push @oligos, {
            type => $oligo_name,
            seq  => $oligo_seq[0]->data_item,
            loci => [
                {
                    assembly   => $ASSEMBLY,
                    chr_name   => $oligo->chromosome->name,
                    chr_start  => $oligo->feature_start,
                    chr_end    => $oligo->feature_end,
                    chr_strand => $oligo->feature_strand
                }
            ]
        };
    }

    return \@oligos;
}

sub genotyping_primers_for {
    my $design = shift;

    my @genotyping_primers;

    my $feature_rs = $design->search_related(
        features => {
            'feature_type.description' => \@GENOTYPING_PRIMER_NAMES
        },
        {
            join     => [ 'feature_type' ],
            prefetch => [ 'feature_type', { 'feature_data' => 'feature_data_type' } ]
        }   
    );

    while ( my $feature = $feature_rs->next ) {
        my @primer_seq = grep { $_->feature_data_type->description eq 'sequence' } $feature->feature_data;
        unless ( @primer_seq == 1 ) {
            WARN( 'Found ' . @primer_seq . ' sequences for genotyping primer ' . $feature->feature_type->description );
            next;
        }
        push @genotyping_primers, {
            type => $feature->feature_type->description,
            seq  => $primer_seq[0]->data_item
        }
    }

    return \@genotyping_primers;
}

sub comments_for {
    my $design = shift;

    my @comments;
    for my $comment ( $design->design_user_comments ) {
        push @comments, {
            comment      => $comment->design_comment,
            category     => $comment->category->category_name,
            created_user => $comment->edited_user || 'migrate_script',
            created_at   => format_date( $comment->edited_date ),
            is_public    => $comment->visibility eq 'public'
        };
    }

    return \@comments;
}

sub type_for {
    my $design = shift;

    if ( $design->is_artificial_intron ) {
        return 'artifical-intron';
    }

    my $dt = $design->design_type;    

    if ( !defined($dt) || $dt =~ /^KO/ ) {
        return 'conditional';
    }

    if ( $dt =~ /^Ins/ ) {
        return 'inserttion';
    }

    if ( $dt =~ /^Del/ ) {
        return 'deletion';
    }

    die "Unrecognized design type '$dt'\n";
}

sub phase_for {
    my ( $design, $type ) = @_;

    my $phase = $design->phase;

    if ( defined $phase ) {
        return $phase;
    }

    if ( $design->start_exon and $type ne 'artificial-intron' ) {
        return $design->start_exon->phase;
    }

    die "Unable to determine phase for design " . $design->design_id . "\n";
}

sub format_date {
    my $maybe_date = shift;

    my $date;
    
    if ( ! defined $date ) {
        $date = $run_date;
    }
    elsif ( blessed $maybe_date ) {
        $date = $maybe_date;
    }
    else {
        try {
            $date = DateTime::Format::Oracle::parse_timestamp( $maybe_date );
        }
        catch {
            $date = DateTime::Format::Oracle::parse_datetime( $maybe_date );
        }
    }

    return $date->iso8601;
}

__END__