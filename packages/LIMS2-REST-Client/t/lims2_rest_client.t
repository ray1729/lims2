#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

use Test::Most;
use FindBin;
use Const::Fast;
use Log::Log4perl qw( :levels );
use Data::Dump qw( dd );

Log::Log4perl->easy_init( $DEBUG );

const my $API_URL => 'http://t87-dev.internal.sanger.ac.uk:9876/api';

use_ok 'LIMS2::REST::Client';

ok my $c = LIMS2::REST::Client->new_with_config(
    configfile => $FindBin::Bin . '/../lims2_rest_client.conf'
), 'construct LIMS2::REST::Client';

isa_ok $c, 'LIMS2::REST::Client';

my $uri = $c->uri_for( 'designs', { gene => 'Cbx1' } );
is $uri, "$API_URL/designs?gene=Cbx1",
    'uri_for designs for Cbx1';

lives_ok { my $data = $c->GET( 'designs', { gene => 'Cbx1' } ); dd $data } 'GET designs for Cbx1';

done_testing;
