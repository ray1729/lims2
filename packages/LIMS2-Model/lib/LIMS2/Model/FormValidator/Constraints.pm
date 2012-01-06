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

{
    my $bac_libraries;    

    sub existing_bac_library {
        my ( $schema ) = @_;

        unless ( $bac_libraries ) {
            $bac_libraries = { map { $_->bac_library => 1 } $schema->resultset( 'BacLibrary' )->all };            
        }
        
        return sub {
            my $dfv = shift;
            $dfv->name_this( 'existing_bac_library' );
        
            my $val = $dfv->get_current_constraint_value();

            return $bac_libraries->{$val} || 0;
        };
    }
}

{
    my $assemblies;

    sub existing_assembly {
        my ( $schema ) = @_;

        unless ( $assemblies ) {
            $assemblies = { map { $_->assembly => 1 } $schema->resultset( 'Assembly' )->all };
        }        

        return sub {
            my $dfv = shift;
            $dfv->name_this( 'existing_assembly' );
        
            my $val = $dfv->get_current_constraint_value();

            return $assemblies->{$val} || 0;
        };
    }
}

{
    my $chromosomes;
    
    sub existing_chromosome {
        my ( $schema ) = @_;

        unless ( $chromosomes ) {
            $chromosomes = { map { $_->chromosome => 1 } $schema->resultset( 'Chromosome' )->all };
        }        
        
        return sub {
            my $dfv = shift;
            $dfv->name_this( 'existing_chromosome' );
            
            my $val = $dfv->get_current_constraint_value();

            return $chromosomes->{$val} || 0;
        };
    }
}

1;

__END__
