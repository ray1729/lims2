#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

use Test::Most;
use Const::Fast;
use Hash::MoreUtils qw( slice );

use_ok 'LIMS2::CRUD';

ok my $crud = LIMS2::CRUD->new( user_name => 'rm7' ), 'construct CRUD object';

{
    const my %clone_foo => ( bac_library => '129', bac_name => 'foo' );

    const my %clone_bar => (
        bac_library => '129',
        bac_name    => 'bar',
        loci => [
            {
                assembly => 'NCBIM37',
                chromosome => '12',
                bac_start  => 1234,
                bac_end    => 6543
            }
        ]
    );
    
    lives_ok {
        $crud->txn_do(
            sub {
                my $res = $crud->create_bac_clone( \%clone_foo )
            }
        )
    } 'create bac_clone (without locus)';

    lives_ok {
        $crud->txn_do(
            sub {
                my $res = $crud->create_bac_clone( \%clone_bar );
            }
        )
    } 'create bac_clone (with locus)';

    lives_ok {
        $crud->txn_do(
            sub {
                $crud->delete_bac_clone_locus(
                    {
                        bac_library => $clone_bar{bac_library},
                        bac_name    => $clone_bar{bac_name},
                        assembly    => $clone_bar{loci}[0]{assembly}
                    }
                );
            }
        )
    } 'delete bac_clone_locus';                                                 
    
    lives_ok {
        $crud->txn_do(
            sub {
                for my $c ( \%clone_foo, \%clone_bar ) {
                    ok $crud->delete_bac_clone( +{ slice( $c, qw( bac_library bac_name ) ) } ), 'delete clone';
                }
            }
        );
    } 'delete bac_clones';

    throws_ok {
        $crud->create_bac_clone( \%clone_foo )
    } qr/Updates can only be run inside a transaction/;

    throws_ok {
        $crud->txn_do( sub { die "testing" } );
    } qr/testing/;

    throws_ok {
        $crud->create_bac_clone( \%clone_foo )
    } qr/Updates can only be run inside a transaction/;
    
}

done_testing;
