package LIMS2::URI;

use strict;
use warnings FATAL => 'all';

use Sub::Exporter -setup => {
    exports => [ qw( uri_for ) ]
};

use Const::Fast;
use URI;

{
    const my %SPEC_FOR => (
        bac_clone       => [ qw( /bac_clone bac_library bac_name ) ],
        bac_clone_locus => [ qw( /bac_clone_locus bac_library bac_name locus.assembly ) ]
    );
    
    sub uri_for {
        my ( $what, $data ) = @_;

        my $spec = $SPEC_FOR{$what}
            or LIMS2::CRUD::Error->throw( "Don't know how to construct URI for $what" );

        my ( $path, @fields ) = @{$spec};

        if ( $data ) {
            for my $field ( @fields ) {
                defined( my $value = _get_value( $data, $field ) )
                    or LIMS2::CRUD::Error->throw( "URI for $what requires $field" );
                $path .= '/' . $value;
            }
        }

        return URI->new( $path );
    }
}

sub _get_value {
    my ( $data, $field ) = @_;

    my @key_parts = split qr/\./, $field;

    for my $key ( @key_parts ) {
        return unless ref( $data ) eq 'HASH' and exists $data->{$key};
        $data = $data->{$key};
    }

    return $data;
}

1;

__END__


