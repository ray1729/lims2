use strict;
use warnings;
use Test::More;


use Catalyst::Test 'LIMS2::WebApp';
use LIMS2::WebApp::Controller::UI::ViewPlate;

ok( request('/ui/viewplate')->is_success, 'Request should succeed' );
done_testing();
