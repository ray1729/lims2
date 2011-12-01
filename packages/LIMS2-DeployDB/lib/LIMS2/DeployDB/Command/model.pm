package LIMS2::DeployDB::Command::model;

use Moose;
use DBIx::Class::Schema::Loader 'make_schema_at';
use FindBin;
use Path::Class;
use namespace::autoclean;
extends 'LIMS2::DeployDB::Command';

has schema_class_name => (
    is      => 'rw',
    isa     => 'Str',
    traits  => ['Getopt'],
    default => 'LIMS2::Schema'
);

has lib_dir => (
    is       => 'rw',
    isa      => 'Path::Class::Dir',
    traits   => ['Getopt'],
    required => 1,
    coerce   => 1,
    default  => sub { dir($FindBin::Bin)->parent->subdir('lib') },
    cmd_flag => 'lib-dir',
);

has components => (
    is      => 'rw',
    isa     => 'ArrayRef[Str]',
    traits  => ['Getopt'],
    default => sub { [qw( InflateColumn::DateTime )] }
);

has role => (
    is         => 'rw',
    isa        => 'Str',
    traits     => [ 'Getopt' ],
    lazy_build => 1
);

sub _build_role {
    my $self = shift;

    if ( $self->schema ) {
        return $self->schema . '_ro';
    }

    return;
}

sub execute {
    my ( $self, $opt, $args ) = @_;

    my %extra_opts;
    if ( $self->role ) {
        push @{ $extra_opts{on_connect_do} }, 'SET SESSION ROLE ' . $self->role;
    }
    if ( $self->schema ) {
        push @{ $extra_opts{on_connect_do} }, 'SET SESSION SEARCH_PATH TO ' . $self->schema;
    }    
    
    make_schema_at(
        $self->schema_class_name,
        {   debug          => $self->debug,
            dump_directory => $self->lib_dir->stringify,
            db_schema      => $self->schema,
            components     => $self->components,
            use_moose      => 1,
        },
        [ $self->dsn, $self->user, $self->password, {}, \%extra_opts ]
    );
}

__PACKAGE__->meta->make_immutable;

1;
