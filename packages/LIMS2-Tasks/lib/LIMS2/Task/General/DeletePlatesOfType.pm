package LIMS2::Task::General::DeletePlatesOfType;

use strict;
use warnings FATAL => 'all';

use Moose;
use namespace::autoclean;
use Smart::Comments;
use Try::Tiny;

extends qw( LIMS2::Task );

has plate_type => (
    is       => 'ro',
    isa      => 'Str',
    traits   => [ 'Getopt' ],
    cmd_flag => 'plate-type',
    required => 1
);

override abstract => sub {
    "Delete all Plates of specified Type"
};

sub execute {
    my ( $self, $opts, $args ) = @_;
    $self->log->debug('Deleting plate types: ' . $self->plate_type );

    my $plate_type = $self->schema->resultset('PlateType')->find( { plate_type => $self->plate_type } );
    unless ( $plate_type ) {
        $self->log->error( 'Invalid plate type: ' . $self->plate_type );
        return;
    }

    my @plates = $plate_type->plates->search( {}, { prefetch => ['wells'] } );
    for my $plate ( @plates )  {
        try{
            $self->_delete_plate( $plate );
        }
        catch {
            $self->log->error('Unable to delete plate: ' . $plate->plate_name . "\n" . $_);
        };
    }
}

sub _delete_plate {
    my ( $self, $plate ) = @_;

    $self->model->txn_do(
        sub {   
            $plate->delete_this_plate;
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
