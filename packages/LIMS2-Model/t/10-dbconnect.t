
use strict;
use warnings FATAL => 'all';

use Test::Most;
use File::Temp;
use Const::Fast;
use YAML::Any;

const my %DB_CONNECT_PARAMS => (
    lims2_test_one => {
        schema_class => 'LIMS2::Model::Schema',
        dsn          => 'dbi:SQLite:dbname=:memory:',
        user         => 'test_one',
        password     => 'eno_tset',
    },    
    lims2_test_two => {
        schema_class => 'LIMS2::Model::Schema',
        dsn          => 'dbi:SQLite:dbname=:memory:',
        user         => 'test_two',
        password     => 'owt_tset',
    }
);

use_ok 'LIMS2::Model::DBConnect';

my $tmp = File::Temp->new( SUFFIX => '.yaml' );
$tmp->print( YAML::Any::Dump( \%DB_CONNECT_PARAMS ) );
$tmp->close;

is LIMS2::Model::DBConnect->ConfigFile( $tmp->filename ), $tmp->filename, 'set config file path';

ok my $config = LIMS2::Model::DBConnect->config, 'parse config file';

is_deeply $config, \%DB_CONNECT_PARAMS, 'config has expected values';

for my $dbname ( qw( lims2_test_one lims2_test_two ) ) {
    is_deeply LIMS2::Model::DBConnect->params_for( $dbname ), $DB_CONNECT_PARAMS{$dbname}, "params_for $dbname";
    is_deeply LIMS2::Model::DBConnect->params_for( $dbname, { AutoCommit => 1 } ), { %{ $DB_CONNECT_PARAMS{$dbname} }, AutoCommit => 1 }, "params_for $dbname with override";
    local $ENV{LIMS2_DB} = $dbname;
    is_deeply LIMS2::Model::DBConnect->params_for( 'LIMS2_DB' ), $DB_CONNECT_PARAMS{$dbname}, "params for $dbname via ENV";
    ok my $s = LIMS2::Model::DBConnect->connect( 'LIMS2_DB' ), "Connect to $dbname schema";
}

done_testing;
