#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

use Test::Most;
use Hash::MoreUtils qw( slice );
use LIMS2::Model::DBConnect;

use_ok 'LIMS2::Model';

ok my $schema = LIMS2::Model::DBConnect->connect( 'LIMS2_TEST' ),
    'connect to LIMS2_TEST';

ok my $model = LIMS2::Model->new( schema => $schema ), 'instantiate model';

{
    can_ok $model, 'list_assemblies';    
    
    ok my $assemblies = $model->list_assemblies, 'list_assemblies succeeds';

    cmp_deeply $assemblies, bag( qw( NCBIM34 NCBIM36 NCBIM37 ) ), 'list_assemblies returns expected data';
}

{
    can_ok $model, 'create_bac_clone';

    my %params = (
        bac_library => 'black6',
        bac_name    => 'foo',
        loci        => [
            {
                assembly  => 'NCBIM37',
                chr_name  => '12',
                chr_start => 123456,
                chr_end   => 654321
            }
        ]
    );

    ok my $bac_clone = $model->create_bac_clone( \%params ), 'create_bac_clone should succeed';

    is_deeply $bac_clone, \%params, 'create_bac_clone returns expected data';

    can_ok $model, 'delete_bac_clone';

    lives_ok { $model->delete_bac_clone( { slice( \%params, qw( bac_library bac_name ) ) } ) }
        'delete_bac_clone should live';
}

{    
    throws_ok { $model->create_bac_clone( { bac_library => 'black6' } ) }
        'LIMS2::Model::Error::Validation', 'validation error thrown';

    my $r = $@->results;    
    
    isa_ok $r, 'Data::FormValidator::Results';

    ok ! $r->has_invalid, 'There are no invalid fields';
    ok ! $r->has_unknown, 'There are no unknown fields';
    ok $r->has_missing, 'There are missing fields';
    is_deeply [ $@->results->missing ], [ 'bac_name' ], 'Validation results contain expected fields';    
}

done_testing;
