#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

use Test::Most;
use Const::Fast;
use Hash::MoreUtils qw( slice );

use_ok 'LIMS2::EntityManager';

ok my $em = LIMS2::EntityManager->new( user_name => 'rm7' ), 'construct EntityManager object';

{
    const my %clone_foo => ( bac_library => '130', bac_name => 'foo' );

    const my %clone_bar => (
        bac_library => '130',
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
        $em->txn_do(
            sub {
                $em->create( 'BacLibrary' => { bac_library => '130' } );
            }
        );
    } 'create BAC library';    
    
    lives_ok {
        $em->txn_do(
            sub {
                my $res = $em->create( BacClone => \%clone_foo )
            }
        )
    } 'create bac_clone (without locus)';

    lives_ok {
        $em->txn_do(
            sub {
                my $res = $em->create( BacClone => \%clone_bar );
            }
        )
    } 'create bac_clone (with locus)';

    lives_ok {
        $em->txn_do(
            sub {
                my $bac = $em->retrieve( BacClone => { bac_library => $clone_bar{bac_library}, bac_name => $clone_bar{bac_name} } )->[0];
                $bac->delete_locus( { assembly => $clone_bar{loci}[0]{assembly} } );
            }
        )
    } 'delete bac_clone_locus';                                                 
    
    lives_ok {
        $em->txn_do(
            sub {
                for my $c ( \%clone_foo, \%clone_bar ) {
                    ok !$em->delete( BacClone => { slice( $c, qw( bac_library bac_name ) ) } ), 'delete clone';
                }
            }
        );
    } 'delete bac_clones';

    lives_ok {
        $em->txn_do(
            sub {
                $em->delete( BacLibrary => { bac_library => '130' } )
            }
        )
    } 'delete BAC library';
    
    throws_ok {
        $em->create( BacClone => \%clone_foo )
    } qr/Updates can only be run inside a transaction/;

    throws_ok {
        $em->txn_do( sub { die "testing" } );
    } qr/testing/;

}

done_testing;
