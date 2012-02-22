#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

use LIMS2::Model;
use LIMS2::Model::DBConnect;
use Test::Most;

ok my $schema = LIMS2::Model::DBConnect->connect( 'LIMS2_TEST', 'tests' ),
    'connect to LIMS2_TEST';

ok my $model = LIMS2::Model->new( schema => $schema ), 'instantiate model';

{
    my %data = (
        design_id           => 1,
        chr_name            => '4',
        chr_strand          => -1,
        five_arm_start      => 83128900,
        five_arm_end        => 83132876,
        target_region_start => 83128032,
        target_region_end   => 83128805,
        three_arm_start     => 83124378,
        three_arm_end       => 83127993,
        design_type         => 'conditional'
    );    

    ok my $design = $model->retrieve_design( { design_id => $data{design_id} } ), "retrieve design $data{design_id}";

    while ( my ( $k, $v ) = each %data ) {
        can_ok $design, $k;
        is $design->$k, $v, "$k is $v";
    }
}

done_testing();
