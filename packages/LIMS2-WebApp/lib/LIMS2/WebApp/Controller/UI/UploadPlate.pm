package LIMS2::WebApp::Controller::UI::UploadPlate;
use Moose;
use Try::Tiny;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

LIMS2::WebApp::Controller::UI::UploadPlate - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub begin :Private {
    my ( $self, $c ) = @_;
    $c->assert_user_roles( 'edit' );
}

=head2 index

=cut

sub index :Path( '/ui/upload_plate' ) :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash(
        plate_types => [ sort { $a->{plate_type} cmp $b->{plate_type} } map $_->as_hash, @{ $c->model( 'Golgi' )->list_plate_types } ],
        template    => 'ui/upload_plate/index.tt'
    );
}

sub process :Path( '/ui/process_upload_plate' ) :Args(0) {
    my ( $self, $c ) = @_;

    my $params = $c->request->params();
    $params->{created_by} = $c->user->user_name;

    my $golgi = $c->model( 'Golgi' );

    try {
        $golgi->check_params( $params, $golgi->pspec_create_plate );
    }
    catch {
        if ( blessed( $_ ) and $_->isa( 'LIMS2::Model::Error::Validation' ) ) {
            $_->show_params( 0 );
            $c->stash( error_msg => $_->as_string );
            $c->detach( 'index' );
        }
        else {
            die $_;
        }   
    };
    
    $c->response->body( "Processing..." );
}

        


=head1 AUTHOR

Ray Miller

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
