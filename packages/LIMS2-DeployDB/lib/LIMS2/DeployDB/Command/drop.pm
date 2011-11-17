package LIMS2::DeployDB::Command::drop;

use Moose;
use namespace::autoclean;
extends 'LIMS2::DeployDB::Command';
with qw( LIMS2::DeployDB::Role::SQL );
with qw( LIMS2::DeployDB::Role::Version );

sub execute {
    my ( $self, $opt, $args ) = @_;

    $self->to_version(0);
    $self->check_versions;
    
    my @drop_statements;
    
    for my $version ( reverse 1..$self->from_version ) {
        push @drop_statements, $self->parse_statements( $self->ddl_dir->subdir('versions')->subdir($version)->file( 'down.sql' ) );
    }    

    $self->do_or_die( \@drop_statements );
}

__PACKAGE__->meta->make_immutable;

1;

