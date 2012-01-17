#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

use HTGT::DBFactory;
use YAML::Any;

my $dbh = HTGT::DBFactory->dbi_connect( 'eucomm_vector' );

my $sth = $dbh->prepare( "select distinct data_value from well_data where data_type = 'cassette'" );
$sth->execute;

while ( my ( $c ) = $sth->fetchrow_array ) {
    print Dump( { cassette_name => $c } );
}


    
