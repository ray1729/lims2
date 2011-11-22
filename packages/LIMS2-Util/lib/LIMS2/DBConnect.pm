package LIMS2::DBConnect;

use strict;
use warnings FATAL => 'all';

use base 'Class::Data::Inheritable';

use Carp qw( confess );
use File::stat;
use Config::Any;

BEGIN {
    __PACKAGE__->mk_classdata( 'ConfigFile' => $ENV{LIMS2_DBCONNECT_CONFIG} );
    __PACKAGE__->mk_classdata( 'CachedConfig' );
}

sub config_is_fresh {
    my $class = shift;

    return $class->CachedConfig
        and $class->CachedConfig->{filename}
            and $class->ConfigFile
                and $class->CachedConfig->{filename} eq $class->ConfigFile
                    and $class->CachedConfig->{mtime}
                        and $class->CachedConfig->{mtime} >= stat( $class->ConfigFile )->mtime;
}

sub read_config {
    my $class = shift;

    my $filename = $class->ConfigFile
        or confess "ConfigFile not specified; is the LIMS2_DBCONNECT_CONFIG environment variable set?";
    my $st       = stat( $filename )
        or confess "stat '$filename': $!";
    
    my $config = Config::Any->load_files( { files => [ $filename ], use_ext => 1, flatten_to_hash => 1 } );
    
    $class->CachedConfig( {
        filename => $filename,
        mtime    => $st->mtime,
        data     => $config->{$filename}
    } );

    return $config;
}

sub config {
    my $class = shift;
    
    if ( ! $class->config_is_fresh ) {            
        $class->read_config;
    }
    
    return $class->CachedConfig->{data};
}

sub params_for {
    my ( $class, $dbname, $override_attrs ) = @_;

    $dbname = $ENV{ $dbname } if defined $ENV{ $dbname };

    my $params = $class->config->{ $dbname }
        or confess "Database '$dbname' not configured";    

    if ( $override_attrs ) {
        return +{ %{ $params }, %{ $override_attrs } };
    }
    else {
        return $params;
    }
}

sub connect {
    my ( $class, $dbname, $override_attrs ) = @_;
    
    my $params = $class->params_for( $dbname, $override_attrs );
    my $schema_class  = $params->{schema_class}
        or confess "No schema_class defined for '$dbname'";
    
    eval "require $schema_class"
        or confess( "Failed to load $schema_class: $@" );

    $schema_class->connect( $params )
}

1;

__END__
