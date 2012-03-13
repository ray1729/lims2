package LIMS2::WebApp::Controller::UI::ViewDesign;
use Moose;
use namespace::autoclean;
use Try::Tiny;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

LIMS2::WebApp::Controller::UI::ViewDesign - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub begin :Private {
    my ( $self, $c ) = @_;
    #$c->assert_user_roles( 'read' );
}

sub index :Path( '/ui/view_design' ) :Args(0) {
    my ( $self, $c ) = @_;

    my $params = $c->request->params();
    my $golgi  = $c->model( 'Golgi' );
    my $design;

    try {
        $design = $golgi->retrieve_design( $params );
    }
    catch {
        if ( blessed( $_ ) and $_->isa( 'LIMS2::Model::Error' ) ) {
            $_->show_params( 0 );
            $c->stash( error_msg => $_->as_string );
            $c->detach( 'index' );
        }
        else {
            die $_;
        }   
    };
    
    $c->stash(
        design    => $design->as_hash,
        template => 'ui/view_design/index.tt'
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
