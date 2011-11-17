package LIMS2::DeployDB::Role::Version;

use Moose::Role;
use List::Util 'max';
use Try::Tiny;
use namespace::autoclean;

has _available_versions => (
    is         => 'ro',
    isa        => 'HashRef[Int]',
    traits     => [ 'NoGetopt', 'Hash' ],
    lazy_build => 1,
    handles    => {
        is_valid_version   => 'exists',
        available_versions => 'keys'
    }
);

has from_version => (
    is         => 'rw',
    isa        => 'Int',
    traits     => ['Getopt'],
    lazy_build => 1,
    cmd_flag   => 'from-version'                 
);

has to_version => (
    is         => 'rw',
    isa        => 'Int',
    traits     => ['Getopt'],
    lazy_build => 1,
    cmd_flag   => 'to-version'
);

has current_version => (
    is         => 'rw',
    isa        => 'Int',
    traits     => ['NoGetopt'],
    lazy_build => 1
);

sub versions_dir {
    my $self = shift;

    $self->ddl_dir->subdir('versions');
}

sub _build__available_versions {
    my $self = shift;

    my $versions_dir = $self->versions_dir;
    $self->log->debug("Looking for DDL versions in $versions_dir");

    my %versions = ( 0 => 1 ); # Version 0 is always available
    while ( my $entry = $versions_dir->next ) {
        my $basename = $entry->relative( $entry->parent );
        $versions{ $basename + 0 } = 1
            if -d $entry and $basename =~ qr/^\d+$/;
    }

    $self->log->debug( "Available versions: " . join q{, }, sort keys %versions );
    return \%versions;
}

sub _build_current_version {
    my $self = shift;

    my ($query) = $self->parse_statements( $self->ddl_dir->file('current-version.sql') );

    my $current_version;
    try {
        ($current_version) = $self->dbh->selectrow_array($query);
    }
    catch {
        if ( $_ =~ m/relation ".*schema_versions" does not exist/ ) {
            $self->log->warn( $_ );
            $self->dbh->rollback;
        }
        else {
            die $_;
        }        
    };

    $current_version = 0 unless defined $current_version;
    
    return $current_version;
}

sub _build_to_version {
    my $self = shift;

    max $self->available_versions;
}

sub _build_from_version {
    my $self = shift;

    $self->current_version;
}

sub check_versions {
    my $self = shift;

    my $current_version = $self->current_version;
    my $from_version    = $self->from_version;
    my $to_version      = $self->to_version;

    die "Database is currently at version $current_version, not $from_version\n"
        unless $current_version == $from_version;

    die "Version $to_version not available\n"
        unless $self->is_valid_version($to_version);

    die "Database is already at version $current_version\n"
        if $to_version == $current_version;
}

1;
