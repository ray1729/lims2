package LIMS2::DeployDB::Command::deploy;

use Moose;
use namespace::autoclean;
extends 'LIMS2::DeployDB::Command';
with qw( LIMS2::DeployDB::Role::SQL LIMS2::DeployDB::Role::Version );

has [qw( pre post )] => (
    is      => 'rw',
    isa     => 'Bool',
    traits  => ['Getopt'],
    default => 1
);

sub execute {
    my ( $self, $opt, $args ) = @_;

    $self->check_versions;
    
    my $from_version = $self->from_version;
    my $to_version   = $self->to_version;

    my @deploy_statements;

    if ( $self->pre ) {
        push @deploy_statements, $self->parse_statements( $self->ddl_dir->file('pre-up-down.sql'), noexist => 'continue' );
    }

    if ( $from_version < $to_version ) {
        for my $version ( sort { $a <=> $b } $self->available_versions ) {
            next if $version <= $from_version;
            last if $version > $to_version;
            push @deploy_statements,
                $self->parse_statements( $self->versions_dir->subdir($version)->file('up.sql') );
        }
    }
    elsif ( $from_version > $to_version ) {
        for my $version ( sort { $b <=> $a } $self->available_versions ) {
            next if $version > $from_version;
            last if $version <= $to_version;
            push @deploy_statements,
                $self->parse_statements( $self->versions_dir->subdir($version)->file('down.sql') );
        }
    }

    if ( $self->post ) {
        push @deploy_statements,
            $self->parse_statements( $self->ddl_dir->file('post-up-down.sql'), noexist => 'continue' );
    }

    $self->do_or_die( \@deploy_statements );
}

__PACKAGE__->meta->make_immutable;

1;
