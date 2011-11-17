package LIMS2::DeployDB::Command;

use strict;
use warnings FATAL => 'all';

use Moose;
use MooseX::Types::Path::Class;
use Log::Log4perl ':levels';
use DBI;
use FindBin;
use List::Util 'max';
use Path::Class;
use Term::ReadPassword 'read_password';
use Try::Tiny;
use namespace::autoclean;

extends 'MooseX::App::Cmd::Command';

MooseX::Getopt::OptionTypeMap->add_option_type_to_map( 'Path::Class::Dir' => '=s' );
has debug => (
    is            => 'rw',
    isa           => 'Bool',
    documentation => "Enable debug logging"
);

has verbose => (
    is            => 'rw',
    isa           => 'Bool',
    documentation => 'Enable verbose logging'
);

has host => (
    is            => 'rw',
    isa           => 'Str',
    documentation => 'Specify the database server hostname',
    default       => $ENV{PGHOST}
);

has port => (
    is            => 'rw',
    isa           => 'Int',
    documentation => 'Specify the database server port',
    default       => $ENV{PGPORT}
);

has database => (
    is            => 'rw',
    isa           => 'Str',
    documentation => 'Specify the database name',
    default       => $ENV{PGDATABASE},
    required      => 1
);

has user => (
    is            => 'rw',
    isa           => 'Str',
    documentation => 'Specify the database user name',
    default       => $ENV{PGUSER} || $ENV{USER}
);

has schema => (
    is            => 'rw',
    isa           => 'Str',
    documentation => 'Specify the database schema',
    required      => 1
);

has password => (
    is            => 'rw',
    isa           => 'Str',
    documentation => "Specify the database password"
);

has commit => (
    is            => 'rw',
    isa           => 'Bool',
    documentation => 'Commit changes to the database (default is to rollback changes)',
    default       => 0
);

has ddl_dir => (
    is       => 'rw',
    isa      => 'Path::Class::Dir',
    required => 1,
    coerce   => 1,
    default  => sub { dir($FindBin::Bin)->parent->subdir('ddl') }
);

has dsn => (
    is         => 'ro',
    isa        => 'Str',
    traits     => ['NoGetopt'],
    lazy_build => 1
);

with qw( MooseX::Log::Log4perl );

sub _build_dsn {
    my $self = shift;

    my $dsn = 'dbi:Pg:dbname=' . $self->database;

    if ( defined $self->host ) {
        $dsn .= ";host=" . $self->host;
    }

    if ( defined $self->port ) {
        $dsn .= ";port=" . $self->port;
    }

    return $dsn;
}

sub BUILD {
    my $self = shift;

    my $log_level
        = $self->debug   ? $DEBUG
        : $self->verbose ? $INFO
        :                  $WARN;

    Log::Log4perl->easy_init( { level => $log_level, layout => '%p %m%n' } );

    return if $self->password;

    my $prompt = sprintf( 'Enter password for %s@%s: ', $self->user, $self->database );
    while (1) {
        my $password = read_password($prompt);
        if ( defined $password and length $password ) {
            $self->password( $password );
            last;
        }        
    }
}


__PACKAGE__->meta->make_immutable;

1;
