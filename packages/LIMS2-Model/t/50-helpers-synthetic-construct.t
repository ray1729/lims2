#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

use Test::Most;
use LIMS2::Model::DBConnect;

use_ok 'LIMS2::Model::Helpers::SyntheticConstruct', 'synthetic_construct_params';

ok my $schema = LIMS2::Model::DBConnect->connect( 'LIMS2_TEST', 'tests' ),
    'connect to LIMS2_TEST';

{
    note "Testing Cre BAC Recombineering Process";

    ok my $process = $schema->resultset( 'Process' )->search(
        {
            'process_cre_bac_recom.design_id' => { '!=', undef }
        },
        {
            join => 'process_cre_bac_recom'
        }
    )->first, "Retrieve cre_bac_recom process";

    my $process_id = $process->process_id;
    
    ok my $params = synthetic_construct_params( $process ), "synthetic_construct_params for $process_id";

    is $params->{method}, 'insertion_vector_seq', 'method is insertion_vector_seq';

}

{

    note "Testing Intermediate Recombineering Process (conditional design)";

    ok my $process = $schema->resultset( 'Process' )->search(
        {
            'process_int_recom.design_well_id' => { '!=', undef },
            'design.design_type'               => 'conditional'
            
        },
        {
            join => { process_int_recom => { design_well => { process => { process_create_di => 'design' } } } }
        }
    )->first, 'Retrieve int_recom process';

    my $process_id = $process->process_id;

    ok my $params = synthetic_construct_params( $process ), "synthetic_construct_params for $process_id";

    is $params->{method}, 'conditional_vector_seq', 'method is conditional_vector_seq';
}

{
    note "Testing Rearrayed Intermediate (deletion design)";

    ok my $process = $schema->resultset( 'Process' )->search(
        {
            process_id => { -in => \[ "select distinct dest_well.process_id
                                       from wells dest_well
                                       join process_rearray_source_wells on process_rearray_source_wells.process_id = dest_well.process_id
                                       join wells src_well on src_well.well_id = process_rearray_source_wells.source_well_id
                                       join process_int_recom on process_int_recom.process_id = src_well.process_id
                                       join wells design_well on design_well.well_id = process_int_recom.design_well_id
                                       join process_create_di on process_create_di.process_id = design_well.process_id
                                       join designs on designs.design_id = process_create_di.design_id
                                       where designs.design_type = ? ", [ design_type => 'deletion' ] ]
                          }
        } 
    )->first, 'Retrieve rearrayed int_recom process';

    my $process_id = $process->process_id;
 
    ok my $params = synthetic_construct_params( $process ), "synthetic_construct_params for $process_id";

    is $params->{method}, 'deletion_vector_seq', 'method is deletion_vector_seq';
    
}

done_testing;
