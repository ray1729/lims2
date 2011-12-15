#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

use LIMS2::EntityManager;
use JSON qw( from_json );
use Getopt::Long;

GetOptions(
    'changeset=i' => \my $changeset,
    'entry=i@'    => \my @entries,
    'commit'      => \my $commit
) or die "Usage: $0 [--entry=CHANGESET_ENTRY_ID ...] --changeset=CHANGESET_ID\n";

my $em = LIMS2::EntityManager->new( user_name => $ENV{USER} );

$em->txn_do(
    sub {
        $em->reverse_changeset( $changeset, @entries );
        unless ( $commit ) {
            warn "Rollback\n";
            $em->schema->txn_rollback;            
        }
    }
);

        
