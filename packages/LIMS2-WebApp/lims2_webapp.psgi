use strict;
use warnings;

use LIMS2::WebApp;

my $app = LIMS2::WebApp->apply_default_middlewares(LIMS2::WebApp->psgi_app);
$app;

