package LIMS2::WebApp::Controller::API::EngineeredSequences;
use Moose;
use HTTP::Status qw( :constants );
use IPC::System::Simple qw( systemx );
use File::Temp;
use Path::Class;
use Try::Tiny;
use namespace::autoclean;

BEGIN {extends 'LIMS2::Catalyst::Controller::REST'; }

=head1 NAME

LIMS2::WebApp::Controller::API::EngineeredSequences - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub eng_seq_params_for_well :Path( '/api/eng_seq_params' ) :Args(2) :ActionClass( 'REST' ) {
}

sub eng_seq_params_for_well_GET {
    my ( $self, $c, $plate_name, $well_name ) = @_;

    my $entity = $c->model( 'Golgi' )->retrieve_synthetic_construct_params(
        {
            plate_name => $plate_name,
            well_name  => $well_name
        }
    );

    $self->status_ok( $c, entity => $entity );
}

sub eng_seq_params_for_plate :Path( '/api/eng_seq_params' ) :Args(1) :ActionClass( 'REST' ) {
}

sub eng_seq_params_for_plate_GET {
    my ( $self, $c, $plate_name ) = @_;

    my $plate = $c->model( 'Golgi' )->retrieve( Plate => { plate_name => $plate_name }, { prefetch => 'wells' } );

    my @params;

    for my $well ( $plate->wells ) {
        push @params, $c->model( 'Golgi' )->retrieve_synthetic_construct_params(
            {
                plate_name => $plate_name,
                well_name  => $well->well_name
            }
        );        
    }

    my $entity;
    
    if ( $c->req->param( 'unique' ) ) {
        $entity = $self->_deep_uniq( \@params );
    }
    else {
        $entity = \@params;
    }    

    $self->status_ok( $c, entity => $entity );
}

sub eng_seq_for_well :Path( '/api/eng_seq' ) :Args(2) {
    my ( $self, $c, $plate_name, $well_name ) = @_;

    my $synvec;
    try {
        $synvec = $c->model( 'Golgi' )->retrieve_synthetic_construct( { plate_name => $plate_name, well_name => $well_name } );
    }
    catch {
        $c->error( $_ );
        $c->detach( 'handle_error' );
    };
        
    my $format = $c->request->param( 'format' ) || 'genbank';
    
    $c->response->body( $synvec->formatted_seq( $format ) );
    $c->response->header( 'Content-Type' => 'application/octet-stream' );
    $c->response->status( HTTP_OK );
}

sub eng_seqs_for_plate :Path( '/api/eng_seq' ) :Args(1) {
}

=head2 GET /api/eng_seq/$plate_name

Retrieve a compressed tarball containing all of the engineered sequences for C<$plate_name>.

=cut

sub eng_seqs_for_plate_GET {
    my ( $self, $c, $plate_name ) = @_;

    my $tarball;
    
    try {
        my $plate = $c->model( 'Golgi' )->retrieve( Plate => { plate_name => $plate_name }, { prefetch => 'wells' } );

        my $format = $c->request->param( 'format' ) || 'genbank';
    
        my $tempdir = File::Temp->newdir;
        my $outdir  = dir( $tempdir->dirname )->subdir( $plate );

        my %seen;
    
        for my $well ( $plate->wells ) {
            my $synvec  = $c->model( 'Golgi' )->retrieve_synthetic_construct( { plate_name => $plate->plate_name, well_name => $well->well_name } );
            next if $seen{ $synvec->display_id }++;
            my $outfile = $outdir->file( $synvec->display_id . '.gbk' );
            my $seq_io = Bio::SeqIO->new( -file => $outfile, -format => $format );
            $seq_io->write_seq( $synvec->bio_seq );
        }

        $tarball = $tempdir->file( $plate->plate_name . '.tar.gz' );
        systemx( 'tar', '-z', '-c', '-f', $tarball, $outdir );
    }
    catch {
        $c->error( $_ );
        $c->detach( 'handle_error' );
    };    

    $c->response->body( $tarball->openr );
    $c->response->header( 'Content-Type' => 'application/x-tar' ); # XXX is this the correct MIME type for compressed tar?
    $c->response->status( HTTP_OK );
}

=head1 AUTHOR

Ray Miller

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
