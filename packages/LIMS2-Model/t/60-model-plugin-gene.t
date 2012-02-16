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
    is_deeply $genes, [ { ensembl_gene_id => 'ENSMUSG00000018666', external_name => 'Cbx1' } ], '...it has the expected structure';    
}

for my $name ( qw( Cbx1 ENSMUSG00000018666 MGI:105369 OTTMUSG00000001636 ) ) {
    my $genes = $model->get_genes_by_name( { name => $name, raw => 1 } );
    ok @{$genes} > 0, "Fetch $name (raw)";
    isa_ok $genes->[0], 'Bio::EnsEMBL::Gene';
    is $genes->[0]->stable_id, 'ENSMUSG00000018666', '...it has the expected stable id';
}

done_testing;
