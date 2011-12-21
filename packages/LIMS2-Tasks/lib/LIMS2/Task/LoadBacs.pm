package LIMS2::Task::LoadBacs;

use strict;
use warnings FATAL => 'all';

use Moose;
use LIMS2::Util::YAMLIterator;
use namespace::autoclean;

extends 'LIMS2::Task';

sub execute {
    my ( $self, $opts, $args ) = @_;

    die "No input file given\n"
        unless @{$args};

    my $em = $self->entity_manager;

    $em->txn_do(
        sub {
            for my $input_file ( @{$args} ) {
                my $it = iyaml( $input_file );
                while ( my $bac = $it->next ) {
                    $em->create( BacClone => $bac );
                }
            }
            unless ( $self->commit ) {
                warn "Rollback\n";
                $self->txn_rollback;
            }
        }
    );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

    
