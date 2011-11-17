#!/usr/bin/env perl

use FindBin;
use lib "$FindBin::Bin/../lib";
use LIMS2::DeployDB;

LIMS2::DeployDB->run;
