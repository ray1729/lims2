package LIMS2::Model::FormValidator::Constraints;

use strict;
use warnings FATAL => 'all';

use Sub::Exporter -setup => {
    exports  => [
        qw( existing_bac_library
            existing_chromosome
            existing_assembly
      )
    ],
    groups => {        
        default => [
            qw( existing_bac_library
                existing_chromosome
                existing_assembly
          )
        ],
    }
};

sub existing_bac_library {
    my ( $schema ) = @_;

    return sub {
        my $dfv = shift;
        $dfv->name_this( 'existing_bac_library' );
        
        my $val = $dfv->get_current_constraint_value();
        my $rs = $schema->resultset( 'BacLibrary' )->search_rs( { bac_library => $val } );

        return $rs->count > 0;
    };
}

sub existing_assembly {
    my ( $schema ) = @_;

    return sub {
        my $dfv = shift;
        $dfv->name_this( 'existing_assembly' );
        
        my $val = $dfv->get_current_constraint_value();
        my $rs = $schema->resultset( 'Assembly' )->search_rs( { assembly => $val } );

        return $rs->count > 0;
    };
}

sub existing_chromosome {
    my ( $schema ) = @_;

    return sub {
        my $dfv = shift;
        $dfv->name_this( 'existing_chromosome' );
        
        my $val = $dfv->get_current_constraint_value();
        my $rs = $schema->resultset( 'Chromosome' )->search_rs( { chromosome => $val } );

        return $rs->count > 0;
    };
}

1;

__END__
