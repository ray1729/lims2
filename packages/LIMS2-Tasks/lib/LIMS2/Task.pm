package LIMS2::Task;

use strict;
use warnings FATAL => 'all';

use Moose;
use Log::Log4perl qw( :levels );
use LIMS2::Model::DBConnect;
use namespace::autoclean;

extends qw( MooseX::App::Cmd::Command );
with qw( MooseX::Log::Log4perl );

has trace => (
    is            => 'ro',
    isa           => 'Bool',
    traits        => [ 'Getopt' ],
    documentation => 'Enable trace logging',
    default       => 0
);

has debug => (
    is            => 'ro',
    isa           => 'Bool',
    traits        => [ 'Getopt' ],
    documentation => 'Enable debug logging',
    default       => 0
);

has verbose => (
    is            => 'ro',
    isa           => 'Bool',
    traits        => [ 'Getopt' ],
    documentation => 'Enable verbose logging',
    default       => 0
);

has commit => (
    is            => 'ro',
    isa           => 'Bool',
    traits        => [ 'Getopt' ],
    documentation => 'Commit changes to the database (default is to rollback)',
    default       => 0
);

has log_layout => (
    is            => 'ro',
    isa           => 'Str',
    traits        => [ 'Getopt' ],
    documentation => 'Specify the Log::Log4perl layout',
    default       => '%d %c %p %m%n',
    cmd_flag      => 'log-layout'
);

has schema => (
    is            => 'ro',
    isa           => 'LIMS2::Model::Schema',
    traits        => [ 'NoGetopt' ],
    lazy_build    => 1
);

sub _build_schema {
    my $self = shift;

    LIMS2::Model::DBConnect->connect( 'LIMS2_DB', 'tasks' );
}

has model => (
    is            => 'ro',
    isa           => 'LIMS2::Model',
    traits        => [ 'NoGetopt' ],
    lazy_build    => 1
);

sub _build_model {
    my $self = shift;
    require LIMS2::Model;
    LIMS2::Model->new( schema => $self->schema );
}

has ensembl_util => (
    is         => 'ro',
    isa        => 'LIMS2::Util::EnsEMBL',
    traits     => [ 'NoGetopt' ],
    lazy_build => 1,
    handles    => [ qw( gene_adaptor ) ]
);

sub _build_ensembl_util {
    require LIMS2::Util::EnsEMBL;
    return LIMS2::Util::EnsEMBL->new;
}

sub BUILD {
    my $self = shift;

    my $log_level
        = $self->trace   ? $TRACE
        : $self->debug   ? $DEBUG
        : $self->verbose ? $INFO
        :                  $WARN;

    Log::Log4perl->easy_init( { level => $log_level, layout => $self->log_layout } );
}

override command_names => sub {
    # from App::Cmd::Command
    my ( $name ) = (ref( $_[0] ) || $_[0]) =~ /([^:]+)$/;

    # split camel case into words
    my @parts = $name =~ m/[[:upper:]](?:[[:upper:]]+|[[:lower:]]*)(?=\Z|[[:upper:]])/g;

    if ( @parts ) {
        return join '-', map { lc }  @parts;
    }
    else {
        return lc $name;
    }
};

__PACKAGE__->meta->make_immutable;

1;

__END__

