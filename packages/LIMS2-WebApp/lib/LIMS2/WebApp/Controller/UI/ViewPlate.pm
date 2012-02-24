package LIMS2::WebApp::Controller::UI::ViewPlate;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

LIMS2::WebApp::Controller::UI::ViewPlate - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


sub view_plate :Path( '/ui/view_plate' ) :Args(1) {
    my ( $self, $c ) = @_;

    
    
    $c->response->body('Matched LIMS2::WebApp::Controller::UI::ViewPlate in UI::ViewPlate.');
}


=head1 AUTHOR

Ray Miller

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
