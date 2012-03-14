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

const my @PROFILES => qw(
eucomm-tools-cre-post-gateway
artificial-intron-post-cre
eucomm-promoter-driven-pre-escell
L3L4-2w-gateway-no-loc
promoter-homozygous-second-allele-post-2w-gateway
promoterless-homozygous-first-allele-post-gateway
homozygous-post-cre
eucomm-tools-cre-post-cre
eucomm-promoter-driven-post-gateway
eucomm-post-cre
artificial-intron-post-gateway
artificial-intron-pre-escell
);

my $schema = HTGT::DBFactory->connect( 'eucomm_vector' );
my $run_date = DateTime->now;

my $qc_rs;
if ( @ARGV ) {
    $qc_rs = $schema->resultset( 'QCRun' )->search( { qc_run_id => \@ARGV } );
}
else {
    $qc_rs = $schema->resultset( 'QCRun' )->search(
        { },
        {
            join => [ 'test_results' ],
            distinct => 1
        }
    );
}

while ( my $qc_run = $qc_rs->next ) {
    Log::Log4perl::NDC->push( $qc_run->qc_run_id );
    try {
        my $qc_run_date = parse_oracle_date( $qc_run->qc_run_date );
        my %qc_run = (
            qc_run_id          => $qc_run->qc_run_id,
            qc_run_date        => $qc_run_date->iso8601,
            sequencing_project => $qc_run->sequencing_project,
            template_plate     => get_template_plate_name( $qc_run->template_plate_id ),
            profile            => $qc_run->profile,
            software_version   => $qc_run->software_version,
            #qc_test_results    => get_qc_test_results( $qc_run ),
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

sub get_template_plate_name {
    my $template_plate_id = shift;

    my $template_plate = $schema->resultset('Plate')->find(
        { plate_id => $template_plate_id }, { columns => [ 'name' ] } );
    die("Template plate id not found: $template_plate_id") unless $template_plate;

    return $template_plate->name;
}

sub get_qc_test_results {
    my $qc_run = shift;
}


__END__
