#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

use Test::Most;
use Try::Tiny;

die_on_fail;

use_ok 'LIMS2::CRUD::Validator';
use_ok 'LIMS2::CRUD::ValidatorFactory';
use_ok 'LIMS2::CRUD::ParameterValidation';

ok validate_params( { bac_library => '129', bac_name => 'foo' }, [ qw( bac_library bac_name ) ] ),
    'validate required parameters';

ok validate_params( { bac_library => '129', bac_name => 'foo' }, [], [ qw( bac_library bac_name ) ] ),
    'validate optional parameters';

ok validate_params( {}, [], [ qw( bac_library bac_name ) ] ),
    'optional parameters can be missing';

throws_ok {
    validate_params( { bac_library => '129' }, [ qw( bac_library bac_name ) ] );
} 'LIMS2::CRUD::Error::Validation';

try {
    validate_params( { bac_library => '129' }, [ qw( bac_library bac_name ) ] );
}
catch {    
    ok $_, 'missing parameter triggers an error';
    isa_ok $_, 'LIMS2::CRUD::Error::Validation';
    is_deeply $_->fields, { bac_name => 'is a required parameter' }, 'required parameter error';
};

throws_ok {
    validate_params( { bac_library => '', bac_name => 'foo' }, [ qw( bac_library bac_name ) ] );
} 'LIMS2::CRUD::Error::Validation';

try {
    validate_params( { bac_library => '', bac_name => 'foo' }, [ qw( bac_library bac_name ) ] );
}
catch {
    isa_ok $_, 'LIMS2::CRUD::Error::Validation';
    is_deeply $_->fields, { bac_library => 'must be a non-empty string' }, 'non-empty string error';
};

done_testing;
