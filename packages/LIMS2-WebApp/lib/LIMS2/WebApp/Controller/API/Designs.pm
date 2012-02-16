package LIMS2::WebApp::Controller::API::Designs;
use Moose;
use namespace::autoclean;

BEGIN {extends 'LIMS2::Catalyst::Controller::REST'; }

=head1 NAME

LIMS2::WebApp::Controller::API::Designs - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub design :Path( '/api/design' ) :Args(1) :ActionClass( 'REST' ) {
}

=head2 GET /api/design/$design_id

Retrieve details of design C<$design_id>.

=cut

sub design_GET {
    my ( $self, $c, $design_id ) = @_;

    $c->assert_user_roles( 'read' );

    my $design = $c->model( 'Golgi' )->retrieve_design( { design_id => $design_id } );

    $self->status_ok(
        $c,
        entity => $design
    );
}

sub designs :Path( '/api/designs' ) :Args(0) :ActionClass( 'REST' ) {
}

=head2 GET /api/designs

Retrieve list of designs matching search criteria specified in request
parameters. Currently, only search on gene name (parameter C<gene>) is
supported.

=cut

sub designs_GET {
    my ( $self, $c ) = @_;

    $c->assert_user_roles( 'read' );

    my $designs = $c->model( 'Golgi' )->list_designs( $c->req->params );

    return $self->status_ok(
        $c,
        entity => [ map { $c->uri_for( '/api/design', $_ )->as_string } @{$designs} ]
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
