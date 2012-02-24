use strict;
use warnings;
use Test::More;


use Catalyst::Test 'LIMS2::WebApp';
use LIMS2::WebApp::Controller::UI::UploadPlate;

ok( request('/ui/uploadplate')->is_success, 'Request should succeed' );
done_testing();
