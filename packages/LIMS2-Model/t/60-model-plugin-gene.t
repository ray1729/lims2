#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

use Test::Most;
use LIMS2::Model::DBConnect;
use Const::Fast;
use Data::Dump 'dd';

use_ok 'LIMS2::Model';

ok my $schema = LIMS2::Model::DBConnect->connect( 'LIMS2_DB', 'tests' ),
    'connect to LIMS2_TEST';

ok my $model = LIMS2::Model->new( schema => $schema ), 'instantiate model';

can_ok $model, 'get_genes_by_name';

for my $name ( qw( Cbx1 ENSMUSG00000018666 MGI:105369 OTTMUSG00000001636 ) ) {
    my $genes = $model->get_genes_by_name( { name => $name } );
    ok @{$genes} > 0, "Fetch $name";
    isa_ok $genes->[0], 'LIMS2::Model::Entity::Gene';
    is_deeply [ map $_->as_hash, @{$genes} ], [
        {
            ensembl_gene_id => 'ENSMUSG00000018666',
            marker_symbol    => 'Cbx1',
            chr_name         => '11',
            chr_start        => 96650441,
            chr_end          => 96669954,
            chr_strand       => 1
        }
    ], '...it has the expected structure';    
}

done_testing;
