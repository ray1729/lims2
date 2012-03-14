package LIMS2::Task::General::DeletePlate;

use strict;
use warnings FATAL => 'all';

use Moose;
use namespace::autoclean;
use Smart::Comments;

extends qw( LIMS2::Task );

has plate_name => (
    is       => 'ro',
    isa      => 'Str',
    traits   => [ 'Getopt' ],
    cmd_flag => 'plate-name',
    required => 1
);

override abstract => sub {
    "Delete a Plate and all its wells"
};

sub execute {
    my ( $self, $opts, $args ) = @_;
    $self->log->debug('Deleting plate: ' . $self->plate_name );

    $self->model->txn_do(
        sub {   
            $self->model->delete_plate( { plate_name => $self->plate_name } );
            unless ( $self->commit ) {
                warn "Rollback\n";
                $self->model->txn_rollback;
            }            
        }
    );
}

__PACKAGE__->meta->make_immutable;

1;

__END__
