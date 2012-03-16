package LIMS2::Model::Constants;

use strict;
use warnings FATAL => 'all';

use base 'Exporter';

use Const::Fast;

BEGIN {
    our @EXPORT      = ();
    our @EXPORT_OK   = qw( $DEFAULT_ASSEMBLY @QC_PROFILES @QC_PRIMER_NAMES @QC_ALIGN_REGIONS );
    our %EXPORT_TAGS = ();
}

const our $DEFAULT_ASSEMBLY => 'NCBIM37';

const our @QC_PROFILES => qw(
eucomm-tools-cre-post-gateway
artificial-intron-post-cre
eucomm-promoter-driven-pre-escell
promoter-homozygous-second-allele-post-2w-gateway
promoterless-homozygous-first-allele-post-gateway
homozygous-post-cre
eucomm-tools-cre-post-cre
eucomm-promoter-driven-post-gateway
artificial-intron-pre-escell
artificial-intron-post-gateway
);

const our @QC_PRIMER_NAMES => qw(
R2R
R4
LR
Z1
L1
PPA1
PNF
Z2
R3
R1R
FCHK
);

const our @QC_ALIGN_REGIONS => (
"5' artificial intron/exon boundary",
"5' cassette/genomic boundary",
"3' artificial intron/exon boundary",
"5' artificial intron",
"3' artificial intron",
"3' artificial cassette/genomic boundary",
"Target region",
"5' artifical intron/exon boundary",
"FCHK suffix region",
"3' arm",
"FCHK critical region length",
"5' arm",
"5' genomic/cassette boundary",
"3' cassette/genomic boundary",
"FCHK critical region",
"FCHK prefix region",
"Synthetic cassette",
);

1;

__END__

