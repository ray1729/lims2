package LIMS2::Task::General::LoadCreBacRecomPlate;

use strict;
use warnings FATAL => 'all';

use Moose;
use Const::Fast;
use Spreadsheet::Read qw( ReadData cellrow );
use namespace::autoclean;

const my $CASSETTE => 'pGTK_En2_eGFPo_T2A_CreERT_Kan';

const my $BAC_LIBRARY => 'black6';

const my %BACKBONE_FOR => (
    qr/^RP23/ => 'pBACe3.6 (RP23) with HPRT3-9 without PUC Linker',
    qr/^RP24/ => 'pTARBAC1(RP24) with HPRT3-9 without PUC Linker'
);

const my $PLATE_TYPE => 'cre_bac_recom';

extends qw( LIMS2::Task );

has plate_name => (
    is       => 'ro',
    isa      => 'Str',
    traits   => [ 'Getopt' ],
    cmd_flag => 'plate-name',
    required => 1
);

has plate_desc => (
    is       => 'ro',
    isa      => 'Str',
    traits   => [ 'Getopt' ],
    cmd_flag => 'plate-desc',
    default  => ''
);

has plate_comments => (
    is       => 'ro',
    isa      => 'ArrayRef[Str]',
    traits   => [ 'Getopt' ],
    cmd_flag => 'plate-comment',
    default  => sub { [] }
);

has created_by => (
    is       => 'ro',
    isa      => 'Str',
    traits   => [ 'Getopt' ],
    cmd_flag => 'created-by',
    default  => $ENV{USER}
);

override abstract => sub {
    "Parse spreadsheet and create Cre BAC recombineering plate"
};

sub canonicalize_well_name {
    my $well_name = shift;
    uc substr $well_name, -3, 3;
}

sub backbone_for {
    my $bac_name = shift;

    for my $match ( keys %BACKBONE_FOR ) {
        if ( $bac_name =~ $match ) {
            return $BACKBONE_FOR{$match};
        }        
    }

    die "No backbone configured for BAC $bac_name\n";
}

sub parse_data_file {
    my ( $self, $filename ) = @_;

    my $data = ReadData( $filename );

    my $sheet = $data->[1];
    my $max_rows = $sheet->{maxrow};
    my $max_cols = $sheet->{maxcol};

    my %wells;

    # Coordinates are 1-based, first row is header, so we start with row 2
    for my $row ( 2 .. $sheet->{maxrow} ) {
        my ( $well_name, $marker, $bac_name, $design_id ) = cellrow( $sheet, $row );

        $wells{ canonicalize_well_name( $well_name ) } = {
            bac_library => $BAC_LIBRARY,
            bac_name    => $bac_name,
            design_id   => $design_id,
            cassette    => $CASSETTE,
            backbone    => backbone_for( $bac_name ),
            created_by  => $self->created_by,
        };
    }

    return {
        plate_name => $self->plate_name,
        plate_type => $PLATE_TYPE,
        plate_desc => $self->plate_desc,
        created_by => $self->created_by,
        comments   => $self->plate_comments,
        wells      => \%wells            
    };
}


sub execute {
    my ( $self, $opts, $args ) = @_;

    die "Exactly one filename must be specified\n"
        unless @{$args} == 1;

    my $data = $self->parse_data_file( $args->[0] );

    $self->model->txn_do(
        sub {   
            $self->model->create_plate( $data );
            unless ( $self->commit ) {
                warn "Rollback\n";
                $self->model->txn_rollback;
            }            
        }
    );
}

__PACKAGE__->meta->make_immutable;

1;

__END__
