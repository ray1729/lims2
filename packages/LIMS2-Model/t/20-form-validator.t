#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

use Test::Most;
use Data::FormValidator;
use LIMS2::Model::DBConnect;

use_ok 'LIMS2::Model::FormValidator::ProfileFactory';

ok my $schema = LIMS2::Model::DBConnect->connect( 'LIMS2_TEST' ),
    'connect to LIMS2_TEST';

ok my $factory = LIMS2::Model::FormValidator::ProfileFactory->new( schema => $schema ),
    'create ProfileFactory';

isa_ok $factory, 'LIMS2::Model::FormValidator::ProfileFactory';

can_ok $factory, 'profile_for';

ok my $create_bac_clone_profile = $factory->profile_for( 'create_bac_clone' ),
    'profile_for create_bac_clone';

{
    my $res = Data::FormValidator->check(
        {
            bac_library => 'black6',
            bac_name    => 'foo'
        }, $create_bac_clone_profile
    );    

    isa_ok $res, 'Data::FormValidator::Results';

    ok $res->success, 'result is success';
}

{
    my $res = Data::FormValidator->check(
        {
            bac_library => '128'
        }, $create_bac_clone_profile
    );

    isa_ok $res, 'Data::FormValidator::Results';

    ok ! $res->success, 'result is not success';

    ok $res->has_invalid, 'result has_invalid';

    is_deeply [ $res->invalid ], [ 'bac_library' ], 'bac_library is invalid';

    ok $res->has_missing, 'result has missing';

    is_deeply [ $res->missing ], [ 'bac_name' ], 'bac_name is missing';
}

    


done_testing;

