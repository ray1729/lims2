#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

use HTGT::DBFactory;
use YAML::Any;

my $dbh = HTGT::DBFactory->dbi_connect( 'eucomm_vector' );

my $sth = $dbh->prepare( "select distinct data_value from well_data where data_type = 'backbone'" );
$sth->execute;

while ( my ( $b ) = $sth->fetchrow_array ) {
    print Dump( { backbone_name => $b } );
}


    
