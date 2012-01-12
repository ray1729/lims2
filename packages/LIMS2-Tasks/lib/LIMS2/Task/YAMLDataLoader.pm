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

sub execute {
    my ( $self, $opts, $args ) = @_;

    die "No input file given\n"
        unless @{$args};

    $self->log->info( "Running " . $self->abstract );

    my $total = 0;
    
    $self->model->txn_do(
        sub {
            for my $input_file ( @{$args} ) {
                $self->log->info( "Loading data from $input_file" );
                my $file_count = 0;
                my $it = iyaml( $input_file );
                while ( my $datum = $it->next ) {
                    $self->create( $datum );
                    $file_count++;
                    if ( $file_count % 100 == 0 ) {
                        $self->log->info( "Processed $file_count records from $input_file" );
                    }                    
                }
                $self->log->info( "File $input_file complete ($file_count records)" );
                $total += $file_count;                
            }
            $self->log->info( "Processed $total records" );
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

    
