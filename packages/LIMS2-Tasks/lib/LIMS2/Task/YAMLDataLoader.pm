package LIMS2::Task::YAMLDataLoader;

use strict;
use warnings FATAL => 'all';

use Moose;
use LIMS2::Util::YAMLIterator;
use namespace::autoclean;

extends 'LIMS2::Task';

sub create {
    my ( $self, $datum ) = @_;

    confess "create() method must be overridden in a subclass";
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

    my ( $total_seen, $total_skipped ) = (0,0);
    
    $self->model->txn_do(
        sub {
            for my $input_file ( @{$args} ) {
                $self->log->info( "Loading data from $input_file" );
                my ($file_seen, $file_skipped) = (0,0);
                my $it = iyaml( $input_file );
                while ( my $datum = $it->next ) {
                    $file_seen++;
                    if ( ! $self->wanted( $datum ) ) {
                        $self->log->warn( "Skipping record:\n" . YAML::Any::Dump( $datum ) );
                        $file_skipped++;
                        next;                        
                    }                    
                    $self->create( $datum );
                    if ( $file_seen % 100 == 0 ) {
                        $self->log->info( "Processed $file_seen records (skipped $file_skipped)" );
                    }                    
                }
                $self->log->info( "Loading data from $input_file complete (saw $file_seen records, skipped $file_skipped)" );
                $total_seen += $file_seen;
                $total_skipped += $file_skipped;
            }
            $self->log->info( "Processed $total_seen records (skipped $total_skipped)" );
            unless ( $self->commit ) {
                $self->log->warn( "Rollback" );
                $self->model->txn_rollback;
            }
        }
    );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

    
