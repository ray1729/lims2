package LIMS2::Task::YAMLDataLoader;

use strict;
use warnings FATAL => 'all';

use Moose;
use LIMS2::Util::YAMLIterator;
use Try::Tiny;
use namespace::autoclean;

extends 'LIMS2::Task';

has continue_on_error => (
    is       => 'ro',
    isa      => 'Bool',
    default  => 1,
    traits   => [ 'Getopt' ],
    cmd_flag => 'continue-on-error'
);

has dump_fail_params => (
    is       => 'ro',
    isa      => 'Bool',
    default  => 0,
    traits   => [ 'Getopt' ],
    cmd_flag => 'dump-fail-params'
);

sub create {
    my ( $self, $datum ) = @_;

    confess "create() method must be overridden in a subclass";
}

sub record_key {
    my ( $self, $datum ) = @_;

    confess "record_key() method must be overridden in a subclass";
}

sub wanted {
    my ( $self, $datum ) = @_;
    return 1;
}

sub execute {
    my ( $self, $opts, $args ) = @_;

    die "No input file given\n"
        unless @{$args};

    $self->log->info( "Running " . $self->abstract );

    my ( $total_seen, $total_skipped, $total_err ) = (0,0,0);
    
    for my $input_file ( @{$args} ) {
        my ( $file_seen, $file_skipped, $file_err ) = $self->load_data_from_file( $input_file );
        $total_seen    += $file_seen;
        $total_skipped += $file_skipped;
        $total_err     += $file_err;
    }

    $self->log->info( "Processed $total_seen records (skipped $total_skipped, failed $total_err)" );
}

sub load_data_from_file {
    my ( $self, $input_file ) = @_;
    
    $self->log->info( "Loading data from $input_file" );
    my ($file_seen, $file_skipped, $file_err) = (0,0,0);
    my $it = iyaml( $input_file );
    while ( my $datum = $it->next ) {
        $file_seen++;
        if ( ! $self->wanted( $datum ) ) {
            $file_skipped++;
            next;                        
        }
        try {
            $self->model->txn_do(
                sub {            
                    $self->create( $datum );
                    unless ( $self->commit ) {
                        $self->model->txn_rollback;
                    }
                }
            );
        }
        catch {
            $self->log->error( "Failed to process record: " . $self->record_key( $datum ) . ": $_" );
            if ( $self->dump_fail_params ) {
                print YAML::Any::Dump( $datum );
            }
            die "Aborting\n" unless $self->continue_on_error;
            $file_err++;
        };
        if ( $file_seen % 100 == 0 ) {
            $self->log->info( "Processed $file_seen records (skipped $file_skipped, failed $file_err)" );
        }
    }

    $self->log->info( "Processed $file_seen records from $input_file (skipped $file_skipped, failed $file_err)" );

    return ( $file_seen, $file_skipped, $file_err );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

    
