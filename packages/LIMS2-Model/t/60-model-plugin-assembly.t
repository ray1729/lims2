#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

use Test::Most;
use LIMS2::Model::DBConnect;
use Const::Fast;

const my @ASSEMBLIES => qw( NCBIM34 NCBIM36 NCBIM37 );

use_ok 'LIMS2::Model';

ok my $schema = LIMS2::Model::DBConnect->connect( 'LIMS2_TEST' ),
    'connect to LIMS2_TEST';

ok my $model = LIMS2::Model->new( schema => $schema ), 'instantiate model';

can_ok $model, 'list_assemblies';    
    
cmp_deeply $model->list_assemblies, bag( @ASSEMBLIES ), 'list_assemblies returns expected data';

can_ok $model, 'create_assembly';

ok my $assembly = $model->create_assembly( { assembly => 'NCBIM35' } ), 'create_assembly suceeeds';

cmp_deeply $assembly, { assembly => 'NCBIM35' }, 'create_assembly returns the expected data';

cmp_deeply $model->list_assemblies, bag( @ASSEMBLIES, 'NCBIM35' ),
    'list_assemblies includes the new assembly';

can_ok $model, 'delete_assembly';

lives_ok { $model->delete_assembly( { assembly => 'NCBIM35' } ) }
    'delete_assembly succeeds';

cmp_deeply $model->list_assemblies, bag( @ASSEMBLIES ),
    'list_assemblies does not include the deleted assembly';

done_testing;
