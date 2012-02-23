package LIMS2::Model::Entity::Gene;

use strict;
use warnings FATAL => 'all';

use Moose;
use Scalar::Util qw( blessed );
use namespace::autoclean;

has ensembl_gene => (
    is       => 'ro',
    isa      => 'Bio::EnsEMBL::Gene',
    required => 1,
    handles  => {
        ensembl_gene_id => 'stable_id',
        marker_symbol   => 'external_name'
    }
);

has _ensembl_gene_chr => (
    is         => 'ro',
    isa        => 'Bio::EnsEMBL::Gene',
    lazy_build => 1,
    handles    => {
        chr_start  => 'start',
        chr_end    => 'end',
        chr_strand => 'strand'        
    }
);

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;

    if ( @_ == 1 and blessed( $_[0] ) and $_[0]->isa( 'Bio::EnsEMBL::Gene' ) ) {
        return $class->$orig( ensembl_gene => $_[0] );
    }
    else {
        return $class->$orig( @_ );
    }    
};

sub _build__ensembl_gene_chr {
    shift->ensembl_gene->transform( 'chromosome' );
}
        
sub chr_name {
    shift->_ensembl_gene_chr->slice->seq_region_name;
}

sub as_hash {
    my $self = shift;

    return {
        map { $_ => $self->$_ } qw( ensembl_gene_id marker_symbol chr_name chr_start chr_end chr_strand )
    };
}

__PACKAGE__->meta->make_immutable;

1;

__END__
