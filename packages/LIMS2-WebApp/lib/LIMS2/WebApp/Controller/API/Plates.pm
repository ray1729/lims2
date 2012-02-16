package LIMS2::WebApp::Controller::API::Plates;
use Moose;
use namespace::autoclean;

BEGIN {extends 'LIMS2::Catalyst::Controller::REST'; }

=head1 NAME

LIMS2::WebApp::Controller::API::Plates - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub plates :Path( '/api/plates' ) :Args(0) :ActionClass( 'REST' ) {
}

sub plates_POST {
    my ( $self, $c ) = @_;

    $c->assert_user_roles( 'edit' );

    my $plate = $c->model( 'Golgi' )->create_plate( $c->request->data );

    $self->status_created(
        $c,
        location => $c->uri_for( '/api/plate', $plate->plate_id ),
        entity   => $plate
    );    
}

sub plate :Path( '/api/plate' ) :Args(1) :ActionClass( 'REST' ) {
}

sub plate_GET {        
    my ( $self, $c, $plate_id ) = @_;

    $c->assert_user_roles( 'read' );

    my $plate = $c->model( 'Golgi' )->retrieve_plate( { plate_id => $plate_id } );

    $self->status_ok(
        $c,
        entity => $plate
    );
}

=head1 AUTHOR

Ray Miller

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
