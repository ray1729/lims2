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


has moniker_map => (
    is         => 'ro',
    isa        => 'HashRef',
    traits     => [ 'NoGetopt' ],
    default    => sub {
        +{
            # Singular problems            
            bac_clone_loci    => 'BacCloneLocus',
            design_oligo_loci => 'DesignOligoLocus',
        }
    }
);

has rel_name_map => (
    is         => 'ro',
    isa        => 'HashRef',
    traits     => [ 'NoGetopt' ],
    default    => sub {
        +{
            # Bad plurals, prefer shorter method name
            BacClone => {
                bac_clone_locis => 'loci'
            },
            DesignOligo => {
                design_oligo_locis => 'loci'
            },
            # Bad plurals
            bac_clone_locis        => 'bac_clone_loci',
            design_oligo_locis     => 'design_oligo_loci',
            # Clashes with column names
            assembly               => 'assembly_rel',
            design_type            => 'design_type_rel',
            chromosome             => 'chromosome_rel',
            bac_library            => 'bac_library_rel',
            genotyping_primer_type => 'genotyping_primer_type_rel',
        }
    }
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
            moniker_map    => $self->moniker_map,
            rel_name_map   => $self->rel_name_map
        },
        [ $self->dsn, $self->user, $self->password, {}, \%extra_opts ]
    );
}

__PACKAGE__->meta->make_immutable;

1;
