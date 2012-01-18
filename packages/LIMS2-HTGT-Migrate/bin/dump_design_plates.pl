#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

use HTGT::DBFactory;
use YAML::Any;
use Log::Log4perl qw( :easy );
use DateTime;
use Try::Tiny;
use List::Util qw( min max );
use LIMS2::HTGT::Migrate::Utils qw( trim parse_oracle_date format_bac_library format_well_name );

Log::Log4perl->easy_init(
    {
        level  => $WARN,
        layout => '%p %x %m%n'
    }
);

my $htgt = HTGT::DBFactory->connect( 'eucomm_vector' );

my $run_date = DateTime->now;

my $design_plate_rs = $htgt->resultset( 'Plate' )->search(
    {
        'me.type' => 'DESIGN',
    },
);

while ( my $plate = $design_plate_rs->next ) {
    Log::Log4perl::NDC->push( $plate->name );
    try {
        my $data = design_plate_data( $plate );
        print Dump( $data );
    }
    catch {
        ERROR($_);
    }
    finally {        
        Log::Log4perl::NDC->pop;
    }    
}

sub design_plate_data {
    my $plate = shift;

    my $created_date = $plate->created_date || $run_date;
    
    my %data = (
        plate_name  => $plate->name,
        plate_type  => 'design',
        plate_desc  => $plate->description || '',
        created_by  => $plate->created_user || 'migrate_script',
        created_at  => $created_date->iso8601,
        comments    => comments_for( $plate, $created_date ),
        wells       => wells_for( $plate, $created_date )
    );

    # XXX Is any plate_data relevant to design plates?
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
    my ( $plate, $created_date ) = @_;

    my %wells;

    for my $well ( $plate->wells ) {
        my $well_name = format_well_name( $well->well_name );
        die "Duplicate well $well_name" if $wells{$well_name};
        $wells{$well_name} = well_data_for( $well, $created_date );
    }

    return \%wells;
}

sub well_data_for {
    my ( $well, $created_date ) = @_;

    my $di = $well->design_instance
        or return;
    
    my ( $rec_results, $assay_pending, $assay_complete ) 
        = recombineering_results_for( $well, $created_date );

    my %data = (
        design_id              => $di->design_id,
        bac_clones             => bacs_for( $di ),
        created_at             => $created_date->iso8601,
        assay_pending          => $assay_pending ? $assay_pending->iso8601 : undef,
        assay_complete         => $assay_complete ? $assay_complete->iso8601 : undef,
        recombineering_results => $rec_results,
    );

    # XXX comment/COMMENTS from well_data?     
    # XXX distribute? distribute_override?

    return \%data;
}

sub bacs_for {
    my $di = shift;

    my @bacs;

    for my $di_bac ( $di->design_instance_bacs ) {
        next unless defined $di_bac->bac_plate;        
        my $bac = $di_bac->bac;
        push @bacs, {
            bac_plate   => substr( $di_bac->bac_plate, -1 ),
            bac_name    => trim( $bac->remote_clone_id ),
            bac_library => format_bac_library( $bac->clone_lib->library )
        }
    }

    return \@bacs;
}

sub recombineering_results_for {
    my ( $well, $created_date ) = @_;

    my ( @rec_results, $assay_pending, $assay_complete );

    my $well_data_rs = $well->well_data_rs->search(
        {
            data_type => [ qw( rec_g rec_d rec_u rec_ns pcr_u pcr_d pcr_g postcre rec-result ) ]
        }
    );

    while ( my $r = $well_data_rs->next ) {
        ( my $assay = $r->data_type ) =~ s/-/_/g;
        my $created_at = parse_oracle_date( $r->edit_date ) || $created_date;
        if ( not defined $assay_pending or $assay_pending > $created_at ) {
            $assay_pending = $created_at;            
        }
        if ( not defined $assay_complete or $assay_complete < $created_at ) {
            $assay_complete = $created_at;
        }        
        push @rec_results, {
            assay      => $assay,
            result     => $r->data_value,
            created_by => $r->edit_user || 'migrate_script',
            created_at => $created_at->iso8601
        };
    }

    return ( \@rec_results, $assay_pending, $assay_complete );
}
