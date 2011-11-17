package LIMS2::DeployDB::Role::SQL;

use Moose::Role;
use Const::Fast;
use Try::Tiny;
use Errno;
use namespace::autoclean;

with qw( MooseX::Log::Log4perl );
requires qw( schema dsn user password );

has dry_run => (
    is            => 'rw',
    isa           => 'Bool',
    traits        => ['Getopt'],
    documentation => "Do not run any update commands against the database",
    cmd_flag      => 'dry-run',
    cmd_aliases   => 'dryrun',
    default       => 0,
);

has params => (
    is         => 'ro',
    isa        => 'HashRef[Defined]',
    lazy_build => 1,
    traits     => [ 'NoGetopt', 'Hash' ],
    handles    => { get_param => 'get' }
);

has [qw( ro_passwd rw_passwd )] => (
    is         => 'ro',
    isa        => 'Str',
    lazy_build => 1,
    builder    => '_build_password',
    traits     => ['NoGetopt']
);

has admin_role => (
    is            => 'ro',
    isa           => 'Str',
    traits        => [ 'Getopt' ],
    documentation => 'Specify the admin role name',
    lazy_build    => 1
);
        
has ro_role => (
    is            => 'ro',
    isa           => 'Str',
    traits        => [ 'Getopt' ],
    documentation => 'Specify the read-only role name',
    lazy_build    => 1
);

has rw_role => (
    is            => 'ro',
    isa           => 'Str',
    traits        => [ 'Getopt' ],
    documentation => 'Specify the read-write role name',
    lazy_build    => 1
);

has dbh => (
    is         => 'ro',
    writer     => '_set_dbh',
    isa        => 'DBI::db',
    traits     => ['NoGetopt'],
    init_arg   => undef
);

sub _build_admin_role {
    shift->schema . '_admin';
}

sub _build_ro_role {
    shift->schema . '_ro';
}

sub _build_rw_role {
    shift->schema;
}

sub BUILD {
    my $self = shift;

    $self->log->debug( "Building database handle" );
    
    my $dbh
        = DBI->connect( $self->dsn, $self->user, $self->password,
        { AutoCommit => 0, RaiseError => 1, PrintError => 0 } )
        or die $DBI::errstr;

    $self->_set_dbh( $dbh );    
    
    my @init_statements = $self->parse_statements( $self->ddl_dir->file('init.sql'), noexist => 'continue' );
    try {
        for my $stmt ( @init_statements ) {
            $self->log->info( "Executing statement: $stmt" );
            $dbh->do( $stmt );            
        }
    } catch {
        $dbh->rollback;
        die $_;
    };
}

{
    const my @PASSWORD_CHARS => ( 'A' .. 'Z', 'a' .. 'z', '0' .. '9' );
    const my $PASSWORD_LENGTH => 10;

    sub _build_password {
        my $self = shift;

        join '', map $PASSWORD_CHARS[ int rand @PASSWORD_CHARS ], 1 .. $PASSWORD_LENGTH;
    }
}

sub _build_params {
    my $self = shift;

    my $dbh       = $self->dbh;

    my %params = (
        schema_name => $dbh->quote_identifier( $self->schema ),
        ro_role     => $dbh->quote_identifier( $self->ro_role ),
        ro_passwd   => $dbh->quote( $self->ro_passwd ),
        rw_role     => $dbh->quote_identifier( $self->rw_role ),
        rw_passwd   => $dbh->quote( $self->rw_passwd ),
        admin_role  => $dbh->quote_identifier( $self->admin_role ),
        sysadmin    => $dbh->quote_identifier( $self->user ),
    );

    if ( $self->can('to_version') ) {
        $params{to_version} = $self->to_version;
    }

    return \%params;
}

sub parse_statements {
    my ( $self, $file, %opts ) = @_;

    $opts{noexist} ||= 'die';
    
    if ( $file->stat ) {
        $self->log->info("Including statements from $file");
        my @statements = grep defined, map { $self->_cleanup_statement($_) } split ';',
            $file->slurp;
        return map { $self->_interpolate_params($_) } @statements;
    }
    elsif ( $!{ENOENT} and $opts{noexist} eq 'continue' ) {
        $self->log->warn( "File $file not found" );
        return;
    }
    else {
        die "stat $file: $!";
    }
}

sub _interpolate_params {
    my ( $self, $stmt ) = @_;

    my $get_param = sub {
        my $param_name = shift;
        if ( defined( my $param_val = $self->get_param($param_name) ) ) {
            return $param_val;
        }
        else {
            die "Statement '$stmt' references undefined parameter '$param_name'\n";
        }
    };

    ( my $interpolated = $stmt ) =~ s/(?<!\\):(\w+)/$get_param->($1)/ge;
    $interpolated =~ s/\\:/:/g;
    $self->log->debug("Interpolated statement: $interpolated");
    return $interpolated;
}

sub _cleanup_statement {
    my ( $self, $statement ) = @_;

    my @lines;
    for ( split qr/\n+/, $statement ) {

        # strip SQL comments
        s/\-\-.*$//;

        # strip leading spaces
        s/^\s+//;

        # strip trailing spaces
        s/\s+$//;

        # skip empty lines
        next if m/^\s*$/;

        # skip BEGIN/COMMIT statements entirely
        return if m/^BEGIN/ or m/^COMMIT/;
        push @lines, $_;
    }

    if (@lines) {
        return join( "\n", @lines );
    }
    else {
        return;
    }
}

sub do_or_die {
    my ( $self, $statements ) = @_;

    my $dbh = $self->dbh;

    try {
        for my $stmt ( @{$statements} ) {
            if ( $self->dry_run ) {
                $self->log->info("dry-run: $stmt");
            }
            else {
                $self->log->info("Executing statement: $stmt");
                $dbh->do($stmt);
            }
        }
    }
    catch {
        $dbh->rollback;
        die $_;
    };

    if ( $self->commit and not $self->dry_run ) {
        $self->log->info('Committing changes...');
        $dbh->commit;
    }
    else {
        $self->log->info('Rolling back changes...');
        $dbh->rollback;
    }
}

1;
