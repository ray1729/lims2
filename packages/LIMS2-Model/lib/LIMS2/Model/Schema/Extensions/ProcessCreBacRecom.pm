package LIMS2::Model::Schema::Extensions::ProcessCreBacRecom;

use strict;
use warnings FATAL => 'all';

use Moose::Role;
use LIMS2::Model::Error::Database;
use namespace::autoclean;
use LIMS2::Model::Constants qw( $DEFAULT_ASSEMBLY );

sub as_hash {
    my $self = shift;

    # only use loci from default lims assembly
    my $bac_clone = $self->bac_clone;
    my $bac_locus  = $bac_clone->search_related( loci => { assembly => $DEFAULT_ASSEMBLY } )->first;
    my $bac_locus_data = $bac_locus->as_hash;

    return {
        design_id          => $self->design_id,
        process_id         => $self->process_id,
        cassette           => $self->cassette,
        backbone           => $self->backbone,
        bac_library        => $self->bac_library,
        bac_name           => $self->bac_name,
        assembly           => $bac_locus_data->{assembly},
        chr_name           => $bac_locus_data->{chr_name},
        chr_start          => $bac_locus_data->{chr_start},
        chr_end            => $bac_locus_data->{chr_end},
    };    
}


1;

__END__
