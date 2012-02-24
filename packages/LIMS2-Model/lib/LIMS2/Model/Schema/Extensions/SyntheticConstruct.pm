package LIMS2::Model::Schema::Extensions::SyntheticConstruct;

use strict;
use warnings FATAL => 'all';

use Moose::Role;
use Bio::SeqIO;
use IO::String;
use LIMS2::Model::Helpers::SyntheticConstruct;
use namespace::autoclean;

sub bio_seq {
    my $self = shift;

    LIMS2::Model::Helpers::SyntheticConstruct::genbank_to_bio_seq(
        $self->synthetic_construct_genbank
    );
}

sub formatted_seq {
    my ( $self, $format ) = @_;

    if ( not defined $format or $format eq 'genbank' ) {
        return $self->synthetic_construct_genbank;
    }
    
    my $seq_str;
    my $seq_io = Bio::SeqIO->new( -fh     => IO::String->new( $seq_str ),
                                  -format => $format
                              );

    $seq_io->write_seq( $self->bio_seq );

    return $seq_str;
}

1;

__END__
