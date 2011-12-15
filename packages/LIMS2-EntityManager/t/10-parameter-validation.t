#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

use Test::Most;
use Try::Tiny;

die_on_fail;

use_ok 'LIMS2::CRUD::ValidationFactory';

ok my $vf = LIMS2::CRUD::ValidationFactory->new, 'construct ValidationFactory';

lives_ok {
    $vf->validate( { bac_library => '129', bac_name => 'foo' },
                   required => [ qw( bac_library bac_name ) ] )
} 'validate required parameters';

lives_ok {
    $vf->validate( { bac_library => '129', bac_name => 'foo' },
                   optional => [ qw( bac_library bac_name ) ] )
} 'validate optional parameters';

lives_ok {
    $vf->validate( {}, optional => [ qw( bac_library bac_name ) ] )
} 'optional parameters can be missing';

throws_ok {
    $vf->validate( { bac_library => '129' }, required => [ qw( bac_library bac_name ) ] );
} 'LIMS2::CRUD::Error::Validation';

try {
    $vf->validate( { bac_library => '129' }, required => [ qw( bac_library bac_name ) ] );
}
catch {    
    ok $_, 'missing parameter triggers an error';
    isa_ok $_, 'LIMS2::CRUD::Error::Validation';
    is_deeply $_->fields, { bac_name => 'is a required parameter' }, 'required parameter error';
};

throws_ok {
    $vf->validate( { bac_library => 'black7', bac_name => 'foo' },
                   required => [ qw( bac_library bac_name ) ] );
} 'LIMS2::CRUD::Error::Validation';

try {
    $vf->validate( { bac_library => 'black7', bac_name => 'foo' },
                   required => [ qw( bac_library bac_name ) ] );
}
catch {
    isa_ok $_, 'LIMS2::CRUD::Error::Validation';
    is_deeply $_->fields, { bac_library => 'is not a valid BAC library name' }, 'invalid BAC library error';
};

done_testing;

__END__
