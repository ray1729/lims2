package LIMS2::Util::EnsEMBL;

use strict;
use warnings FATAL => 'all';

use Moose;
use namespace::autoclean;

with 'LIMS2::Role::EnsEMBL';

__PACKAGE__->meta->make_immutable;

1;

__END__
