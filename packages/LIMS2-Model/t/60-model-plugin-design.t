#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

use Test::Most;
use LIMS2::Model::DBConnect;
use YAML::Any;
use Data::Dump 'dd';

use_ok 'LIMS2::Model';

ok my $schema = LIMS2::Model::DBConnect->connect( 'LIMS2_TEST' ),
    'connect to LIMS2_TEST';

ok my $model = LIMS2::Model->new( schema => $schema ), 'instantiate model';

my $params = Load( do { local $/ = undef; <DATA> } );

$model->txn_do(
    sub {
        can_ok $model, 'create_design';

        ok my $design = $model->create_design( $params ), 'create_design should succeed';

        can_ok $model, 'delete_design';

        ok $model->delete_design( { design_id => $params->{design_id}, cascade => 1 } ),
            'delete_design succeeds';
    }
);

done_testing;

__DATA__
---
comments:
- design_comment_category: Alternative variant not targeted
  design_comment: Isoform specific design. Transcripts OTTMUST00000042560, OTTMUST00000042552,
    OTTMUST00000042553, OTTMUST00000042554 not targeted
  created_at: 2011-12-21T14:38:25
  created_by: am9
  is_public: ''
created_at: 2011-12-21T14:38:25
created_by: am9
design_id: '20'
design_name: EUCTV00010
design_type: conditional
genotyping_primers:
- seq: CGAGCTGAGGTGACACAGTAATCAGC
  type: GF3
- seq: CACAATCACTGATGTGAATAGCGTTCCTAC
  type: GF4
- seq: CACGCACGTACCACCGTGGACCAG
  type: EX52
- seq: CACTTGGTCTGGTCCACGGTGGTACGTGCG
  type: EX32
- seq: CTTACACAGAATCACTCTTGATGTGAGCTC
  type: GR3
- seq: GAAGCTGCTTACACAGAATCACTCTTGATG
  type: GR4
- seq: GAGGCTCCTTCATCCCAAGT
  type: PNFLR1
- seq: GTTGGGAGTGTTTGACCAGG
  type: PNFLR2
- seq: TGTTTGACCAGGAGTCACCA
  type: PNFLR3
- seq: GAGATTTGCTGGAGAGGCAG
  type: LR1
- seq: ACAGCTGGGAAGAGGTAGCA
  type: LR2
- seq: CACAGCTGGGAAGAGGTAGC
  type: LR3
- seq: ACAAAGTGCTCGCATCTCCT
  type: LF1
- seq: ATGATGTCCGGTGATGGTTT
  type: LF2
- seq: CTCCTGTACAAGCTCTGCCC
  type: LF3
oligos:
- loci:
  - assembly: NCBIM37
    chr_end: '63100534'
    chr_name: '4'
    chr_start: '63100485'
    chr_strand: '-1'
  seq: GTATGTATAGACAAGGTGAGAAATAAAGGGGCTAAGATACTATTACGTCC
  type: G5
- loci:
  - assembly: NCBIM37
    chr_end: '63097188'
    chr_name: '4'
    chr_start: '63097139'
    chr_strand: '-1'
  seq: TTTAGAATGCCAGTGATACTTTAGCTTACTAAAGGAAGTAAAACAAACAA
  type: U5
- loci:
  - assembly: NCBIM37
    chr_end: '63096984'
    chr_name: '4'
    chr_start: '63096935'
    chr_strand: '-1'
  seq: GATTTCTTATCTACTACACGCTTTATTTTTATTCTATGTGCATATATGAG
  type: U3
- loci:
  - assembly: NCBIM37
    chr_end: '63096179'
    chr_name: '4'
    chr_start: '63096130'
    chr_strand: '-1'
  seq: CCTGCATTCAGATGCTCCCAGATGCACTAAACACCCAGTAAAGTGATTTG
  type: D5
- loci:
  - assembly: NCBIM37
    chr_end: '63095943'
    chr_name: '4'
    chr_start: '63095894'
    chr_strand: '-1'
  seq: CTATGCAGGAGAAAAGAAGGGAGTACATGAGAGAAATAAGACACTGTTGG
  type: D3
- loci:
  - assembly: NCBIM37
    chr_end: '63092490'
    chr_name: '4'
    chr_start: '63092441'
    chr_strand: '-1'
  seq: ACTGCAATTATGGAGTTCTTGTTTTGTCTAACCATCCTTTACATTTTATT
  type: G3
phase: '0'
validated_by_annotation: yes
