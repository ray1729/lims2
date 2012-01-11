package LIMS2::Task::LoadMgiGeneData;

use strict;
use warnings FATAL => 'all';

use Moose;
use MooseX::Types::URI qw( Uri );
use URI;
use Const::Fast;
use File::Temp;
use LWP::UserAgent;
use Hash::MoreUtils qw( slice );
use Iterator::Simple qw( iter imap igrep );
use Try::Tiny;
use namespace::autoclean;

extends qw( LIMS2::Task );

const my @MGI_COORDINATE_COLUMNS => qw(
    mgi_accession_id
    marker_type
    marker_symbol
    marker_name
    representative_genome_id
    representative_genome_chr
    representative_genome_start
    representative_genome_end
    representative_genome_strand
    representative_genome_build
    entrez_gene_id
    ncbi_gene_chromosome
    ncbi_gene_start
    ncbi_gene_end
    ncbi_gene_strand
    ensembl_gene_id
    ensembl_gene_chromosome
    ensembl_gene_start
    ensembl_gene_end
    ensembl_gene_strand    
    vega_gene_id
    vega_gene_chromosome
    vega_gene_start
    vega_gene_end
    vega_gene_strand
    unists_gene_chromosome
    unists_gene_start
    unists_gene_end
    mgi_qtl_gene_chromosome
    mgi_qtl_gene_start
    mgi_qtl_gene_end
    mirbase_gene_id
    mirbase_gene_chromosome
    mirbase_gene_start
    mirbase_gene_end
    mirbase_gene_strand
    roopenian_sts_gene_start
    roopenian_sts_gene_end
);

const my @MGI_GENE_DATA     => grep !/^ensembl_|vega_/, @MGI_COORDINATE_COLUMNS;

const my @ENSEMBL_GENE_DATA => grep /^ensembl_/, @MGI_COORDINATE_COLUMNS;

const my @VEGA_GENE_DATA    => grep /^vega_/, @MGI_COORDINATE_COLUMNS;

const my @STRAND_DATA       => grep /_strand$/, @MGI_COORDINATE_COLUMNS;

const my @MGI_ENSEMBL_COLUMNS => qw (
    mgi_accession_id
    marker_symbol
    marker_name
    cm_position
    chromosome
    ensembl_gene_id
    ensembl_transcript_id
    ensembl_protein_id
);

has mgi_coordinate_url => (
    is       => 'ro',
    isa      => Uri,
    traits   => [ 'Getopt' ],
    cmd_flag => 'mgi-coordinate-url',
    required => 1,
    coerce   => 1,
    default  => sub { URI->new( 'ftp://ftp.informatics.jax.org/pub/reports/MGI_Coordinate.rpt' ) }
);

has mgi_ensembl_url => (
    is       => 'ro',
    isa      => Uri,
    traits   => [ 'Getopt' ],
    cmd_flag => 'mgi-ensembl-url',
    required => 1,
    coerce   => 1,
    default  => sub { URI->new( 'ftp://ftp.informatics.jax.org/pub/reports/MRK_ENSEMBL.rpt' ) }
);

has _errors => (
    isa      => 'ArrayRef',
    traits   => [ 'Array', 'NoGetopt' ],
    default  => sub { [] },
    handles  => {
        add_error  => 'push',
        has_errors => 'count',
        errors     => 'elements'
    }
);

override abstract => sub {
    "Download MGI gene data and load into LIMS2 schema"
};

sub execute {
    my $self = shift;

    # Construct the iterators here. This invokes an FTP get and will abort
    # if the download fails.
    my $mgi_coordinate_iterator = $self->mgi_coordinate_iterator;
    my $mgi_ensembl_iterator    = $self->mgi_ensembl_iterator;
    
    $self->schema->txn_do(
        sub {
            $self->delete_gene_data;
            $self->load_mgi_coordinate_data( $mgi_coordinate_iterator );
            $self->load_mgi_ensembl_data( $mgi_ensembl_iterator );
            if ( ! $self->commit ) {
                $self->log->warn( "Rollback" );
                $self->schema->txn_rollback;                
            }
        }
    );

    return $self->has_errors ? 0 : 1;
}

sub mgi_coordinate_iterator {
    my $self = shift;

    my $fh = $self->download( $self->mgi_coordinate_url );

    imap { $self->parse_mgi_coordinate_record( $_ ) } igrep { m/^MGI:/ } iter( $fh );
}

sub mgi_ensembl_iterator {
    my $self = shift;

    my $fh = $self->download( $self->mgi_ensembl_url );

    imap { $self->parse_mgi_ensembl_record( $_ ) } igrep { m/^MGI:/ } iter( $fh );
}      

sub download {
    my ( $self, $url ) = @_;

    $self->log->info( "Downloading $url" );    
    
    my $tmp = File::Temp->new();

    my $ua = LWP::UserAgent->new();
    $ua->env_proxy;

    my $response = $ua->get( $url, ':content_file' => $tmp->filename );

    unless ( $response->is_success ) {        
        die "Error retrieving $url: " . $response->status_line;
    }

    return $tmp;
}

sub parse_mgi_ensembl_record {
    my ( $self, $input_line ) = @_;

    my %data;
    @data{@MGI_ENSEMBL_COLUMNS} = split "\t", $input_line;

    return \%data;
}

sub parse_mgi_coordinate_record {
    my ( $self, $input_line ) = @_;

    my %data;
    @data{@MGI_COORDINATE_COLUMNS} = split "\t", $_;
    
    for ( keys %data ) {
        $data{$_} = undef if $data{$_} and lc( $data{$_} ) eq 'null';
    }

    for ( @STRAND_DATA ) {
        next unless $data{$_};
        if ( $data{$_} eq '+' ) {
            $data{$_} = 1;
        }
        elsif ( $data{$_} eq '-' ) {
            $data{$_} = -1;
        }
        else {
            $self->log->warn( "Invalid $_ '$data{$_}' for $data{mgi_accession_id}" );
            delete $data{$_};            
        }        
    }

    return \%data;
}

sub delete_gene_data {
    my $self = shift;

    for ( qw( MgiEnsemblGeneMap EnsemblGeneData MgiVegaGeneMap VegaGeneData MgiGeneData ) ) {
        $self->log->info( "Delete $_" );
        $self->schema->resultset( $_ )->delete;
    }
}

sub load_mgi_coordinate_data {
    my ( $self, $iterator ) = @_;

    $self->log->info( "Loading MGI coordinate data" );
    
    while ( my $record = $iterator->next ) {
        try {
            $self->add_mgi_gene_data( $record );
        }
        catch {
            $self->add_error( $_ );
            $self->log->error( $_ );
        };      
    }
}

sub load_mgi_ensembl_data {
    my ( $self, $iterator ) = @_;

    $self->log->info( "Loading MGI EnsEMBL data" );
    
    while ( my $record = $iterator->next ) {
        try {
            my $mgi_gene = $self->schema->resultset( 'MgiGeneData' )->find(
                {
                    mgi_accession_id => $record->{mgi_accession_id}
                }
            );                            
            if ( $mgi_gene ) {
                $self->add_ensembl_gene_data( $mgi_gene, $record );
            }
            else {
                $self->log->warn( "Cannot load map for $record->{ensembl_gene_id}: MGI accession $record->{mgi_accession_id} not found" );
            }
        }
        catch {
            $self->add_error( $_ );
            $self->log->error( $_ );
        };        
    }
}

sub add_mgi_gene_data {
    my ( $self, $data ) = @_;

    my %mgi_gene_data = slice $data, @MGI_GENE_DATA;
    
    $self->log->info( "Creating MgiGeneData: $data->{mgi_accession_id}" );
    
    my $mgi_gene = $self->schema->resultset( 'MgiGeneData' )->create( \%mgi_gene_data );    
    
    if ( $data->{ensembl_gene_id} ) {
        $self->add_ensembl_gene_data( $mgi_gene, $data );
    }

    if ( $data->{vega_gene_id} ) {
        $self->add_vega_gene_data( $mgi_gene, $data );
    }
}

sub add_ensembl_gene_data {
    my ( $self, $mgi_gene, $data ) = @_;

    for my $ensembl_gene_id ( split /\s*,\s*/, $data->{ensembl_gene_id} ) {
        my $gene_data = $self->schema->resultset( 'EnsemblGeneData' )->find(
            {
                ensembl_gene_id => $ensembl_gene_id
            }
        );
        unless ( $gene_data ) {
            $gene_data = $self->create_ensembl_gene_data( $ensembl_gene_id );
        }
        next unless $gene_data;        
        $self->log->info( "Creating MgiEnsemblGeneMap $data->{mgi_accession_id} => $ensembl_gene_id" );
        $self->schema->resultset( 'MgiEnsemblGeneMap' )->find_or_create(
            {
                mgi_accession_id => $mgi_gene->mgi_accession_id,
                ensembl_gene_id  => $ensembl_gene_id
            }
        );
    }
}

sub add_vega_gene_data {
    my ( $self, $mgi_gene, $data ) = @_;

    my %vega_gene_data = slice $data, @VEGA_GENE_DATA;   

    for my $vega_gene_id ( split /\s*,\s*/, $data->{vega_gene_id} ) {
        $self->log->info( "Creating VegaGeneData for: $vega_gene_id" );
        $self->schema->resultset( 'VegaGeneData' )->find_or_create( \%vega_gene_data );
        $self->log->info( "Creating MgiVegaGeneMap $data->{mgi_accession_id} => $vega_gene_id" );
        $self->schema->resultset( 'MgiVegaGeneMap' )->create(
            {
                mgi_accession_id => $mgi_gene->mgi_accession_id,
                vega_gene_id     => $vega_gene_id
            }
        );
    }
}

sub create_ensembl_gene_data {
    my ( $self, $ensembl_gene_id ) = @_;

    my $gene = $self->gene_adaptor->fetch_by_stable_id( $ensembl_gene_id );
    unless ( $gene ) {
        $self->log->warn( "failed to retrieve Ensembl gene $ensembl_gene_id" );
        return;
    }        
        
    my ( $sp, $tm ) = ( 0, 0 );
    
    for my $transcript ( @{ $gene->get_all_Transcripts } ) {
        my $translation = $transcript->translation
            or next;
        for my $domain ( @{ $translation->get_all_ProteinFeatures }  ) {
            my $logic_name = $domain->analysis->logic_name;
            if ( $logic_name eq 'signalp' ) {
                $sp = 1;
            }
            elsif ( $logic_name eq 'tmhmm' ) {
                $tm = 1;
            }                
        }
        # No need to consider other transcripts if we found the
        # domains we are looking for
        last if $sp and $tm;
    }
    
    $self->log->info( "Creating EnsemblGeneData for: $ensembl_gene_id" );
    $self->schema->resultset( 'EnsemblGeneData' )->create(
        {
            ensembl_gene_id         => $ensembl_gene_id,
            ensembl_gene_chromosome => $gene->seq_region_name,
            ensembl_gene_start      => $gene->seq_region_start,
            ensembl_gene_end        => $gene->seq_region_end,
            ensembl_gene_strand     => $gene->seq_region_strand,
            sp                      => $sp,
            tm                      => $tm
        }
    );
}

__PACKAGE__->meta->make_immutable;

1;

__END__
