package LIMS2::Model::Profile::Plate::Default;
use Moose;
use namespace::autoclean;

with qw( LIMS2::Model::Profile::Plate );

sub as_hash {
    my $self = shift;

    my $plate_data = $self->_get_plate_data;
    $plate_data->{wells} = [ map { $self->process_default_well( $_ ) } @{ $self->wells } ];
    $plate_data->{well_data} = [ qw( well_name ) ];

    return $plate_data;
}

__PACKAGE__->meta->make_immutable;

1;
