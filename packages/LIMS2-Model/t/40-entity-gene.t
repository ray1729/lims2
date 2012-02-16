#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

use LIMS2::Util::EnsEMBL;
use Test::Most;

use_ok qw( LIMS2::Model::Entity::Gene );

ok my $gene_adaptor = LIMS2::Util::EnsEMBL->new->gene_adaptor, 'instantiate gene adaptor';

ok my $g = $gene_adaptor->fetch_by_stable_id( 'ENSMUSG00000018666' ), 'fetch Cbx1';

ok my $e = LIMS2::Model::Entity::Gene->new( $g ), 'instantiate Gene entity';

can_ok $e, 'ensembl_gene';
isa_ok $e->ensembl_gene, 'Bio::EnsEMBL::Gene';

is_deeply $e->as_hash, {
    ensembl_gene_id  => 'ENSMUSG00000018666',
    marker_symbol    => 'Cbx1',
    chr_name         => '11',
    chr_start        => 96650441,
    chr_end          => 96669954,
    chr_strand       => 1        
}, 'Gene entity returns expected hash';

done_testing;







