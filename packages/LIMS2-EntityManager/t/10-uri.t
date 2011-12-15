#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

use Test::Most;

use_ok 'LIMS2::URI', 'uri_for';

is uri_for( 'bac_clone' ), '/bac_clone';

is uri_for( 'bac_clone' => { bac_library => '129', bac_name => 'foo' } ), '/bac_clone/129/foo';

is uri_for(
    'bac_clone_locus' => {
        bac_library => '129',
        bac_name    => 'foo',
        locus       => {
            assembly => 'NCBIM37',
            chromosome => 19,
            bac_start  => 123,
            bac_end    => 321
        }
    }
), '/bac_clone_locus/129/foo/NCBIM37';

done_testing;
