package LIMS2::Model::Profile::Plate;
use strict;
use warnings FATAL => 'all';

use Moose::Role;
use Hash::MoreUtils qw( slice slice_def );
use Scalar::Util qw( blessed );
use namespace::autoclean;
use Smart::Comments;

requires qw( as_hash );

has plate => (
    is => 'ro',
    isa => 'LIMS2::Model::Schema::Result::Plate',
    required => 1,
);

has plate_name => (
    is  => 'ro',
    isa => 'Str',
    lazy_build => 1,
);

sub _build_plate_name {
    my $self = shift;

    return $self->plate->plate_name;
}

has plate_created_by => (
    is    => 'ro',
    isa     => 'Str',
    lazy_build => 1,
);

sub _build_plate_created_by {
    my $self = shift;

    return $self->plate->created_by->user_name;
}

has plate_description => (
    is    => 'ro',
    isa   => 'Str',
    lazy_build => 1,
);

sub _build_plate_description {
    my $self = shift;

    return $self->plate->plate_desc;
}

has wells => (
    is => 'ro',
    isa  => 'ArrayRef[LIMS2::Model::Schema::Result::Well]',
    lazy_build => 1,
);

sub _build_wells {
    my $self = shift;

    return [ sort { $a->well_name cmp $b->well_name } $self->plate->wells->all ];
}

sub _get_plate_data {
    my $self = shift;
    my %plate_data;

    $plate_data{plate_name}  = $self->plate_name;
    $plate_data{created_by}  = $self->plate_created_by;
    $plate_data{description} = $self->plate_description;

    return \%plate_data;
}

sub process_default_well {
    my ( $self, $well ) = @_;
    my %well_data;

    $well_data{well_name} = $well->well_name;
    my $process_pipeline = $well->process->process_pipeline;
    $well_data{pipeline} = $process_pipeline ? $process_pipeline->pipeline->pipeline_name : '';

    return \%well_data;
}
1;

__END__
