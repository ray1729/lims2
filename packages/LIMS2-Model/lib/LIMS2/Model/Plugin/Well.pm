package LIMS2::Model::Plugin::Well;

use strict;
use warnings FATAL => 'all';

use Moose::Role;
use Hash::MoreUtils qw( slice_def );
use Scalar::Util qw( blessed );
use namespace::autoclean;

requires qw( schema check_params throw );

sub pspec_create_well {
    return {
        plate_name     => { validate => 'existing_plate_name' },
        well_name      => { validate => 'well_name' },
        created_by     => { validate => 'existing_user', post_filter => 'user_id_for' },
        created_at     => { validate => 'date_time', optional => 1, post_filter => 'parse_date_time' },
        assay_pending  => { validate => 'date_time', optional => 1, post_filter => 'parse_date_time' },
        assay_complete => { validate => 'date_time', optional => 1, post_filter => 'parse_date_time' },
        accepted       => { optional => 1 },
        parent_wells   => { optional => 1, default => [] },
        assay_results  => { optional => 1, default => [] }
    }
}

sub pspec_create_accepted_override {
    return {
        accepted   => { validate => 'boolean' },
        created_at => { validate => 'date_time', optional => 1, post_filter => 'parse_date_time' },
        created_by => { validate => 'existing_user', post_filter => 'user_id_for' }
    }
};

# Internal function, returns a LIMS2::Model::Schema::Result::Well object
sub _instantiate_well {
    my ( $self, $params ) = @_;

    if ( blessed( $params ) and $params->isa( 'LIMS2::Model::Schema::Result::Well' ) ) {
        return $params;
    }

    $self->retrieve( Well => { slice_def( $params, qw( plate_name well_name ) ) }, { join => 'Plate' } );
}

# Internal function, creates entries in the tree_paths table
sub _create_tree_paths {
    my ( $self, $well, @ancestors ) = @_;

    my ( $insert_tree_paths, @bind_params );
    
    if ( @ancestors ) {
        $insert_tree_paths = sprintf( <<'EOT', join q{, }, ('?')x@ancestors );
insert into tree_paths( ancestor, descendant, path_length )
  select t.ancestor, cast( ? as integer ), t.path_length + 1
  from tree_paths t
  where t.descendant in ( %s )
union all
  select cast( ? as integer ), cast( ? as integer ), 0
EOT
        @bind_params = ( $well->well_id, map( $_->well_id, @ancestors ), $well->well_id, $well->well_id ); 
    }    
    else {
        $insert_tree_paths = <<'EOT';
insert into tree_paths( ancestor, descendant, path_length ) values( ?, ?, 0 )
EOT
        @bind_params = ( $well->well_id, $well->well_id );
    }
    
    $self->schema->storage->dbh_do(
        sub {
            my $sth = $_[1]->prepare_cached( $insert_tree_paths );
            $sth->execute( @bind_params );
        }
    );
}

# Internal function, returns LIMS2::Model::Schema::Result::Well object
sub _create_well {
    my ( $self, $plate, $validated_params ) = @_;

    $plate ||= $self->retrieve( Plate => { plate_name => $validated_params->{plate_name} } );

    $self->log->debug( '_create_well: ' . $plate->plate_name . '_' . $validated_params->{well_name} );
    
    my $well = $plate->create_related(
        wells => {
            slice_def( $validated_params, qw( well_name created_by created_at assay_pending ) )
        }
    );

    $self->log->debug( 'created well with id: ' . $well->well_id );

    $self->_create_tree_paths( $well, map { $self->_instantiate_well( $_ ) } @{ $self->{parent_wells} } );

    for my $assay_result ( @{ $validated_params->{assay_results} } ) {
        $self->add_well_assay_result( $assay_result, $well );
    }    
    
    if ( $validated_params->{assay_complete} ) {
        $self->set_well_assay_complete( { assay_complete => $validated_params->{assay_complete} }, $well );
    }

    if ( $validated_params->{accepted} ) {
        my $override = $self->check_params( $validated_params->{accepted}, $self->pspec_create_accepted_override );
        $well->create_related( well_accepted_override => $override );
    }
    
    return $well;
}

sub pspec_set_well_assay_complete {
    return {
        plate_name     => { validate => 'existing_plate_name', optional => 1 },
        well_name      => { validate => 'well_name', optional => 1 },
        assay_complete => { validate => 'date_time', optional => 1, default => sub { DateTime->now }, post_filter => 'parse_date_time' },
    };
}

sub set_well_assay_complete {
    my ( $self, $params, $well ) = @_;

    my $validated_params = $self->check_params( $params, $self->pspec_set_well_assay_complete );

    $well ||= $self->_instantiate_well( $validated_params );

    # XXX fire trigger to set 'accepted' flag
    
    $well->update( { assay_complete => $validated_params->{assay_complete} } );
}

# XXX These validations do not check that assay/result is a valid combination, only the
# two fields independently
sub pspec_add_well_assay_result {
    return {
        plate_name => { validate => 'existing_plate_name', optional => 1 },
        well_name  => { validate => 'well_name', optional => 1 },
        assay      => { validate => 'existing_assay' },
        result     => { validate => 'existing_assay_result' },
        created_by => { validate => 'existing_user', post_filter => 'user_id_for' },
        created_at => { validate => 'date_time', post_filter => 'parse_date_time' }
    };    
}

sub add_well_assay_result {
    my ( $self, $params, $well ) = @_;

    my $validated_params = $self->check_params( $params, $self->pspec_add_well_assay_result );

    $well ||= $self->_instantiate_well( $validated_params );

    if ( $well->assay_complete ) {
        $self->throw( InvalidState => 'Assay results cannot be added to a well in state assay_complete' );
    }    
    
    my $assay_result = $well->create_related(
        well_assay_results => {
            slice_def( $validated_params, qw( assay result created_at created_by ) )
        }
    );

    unless ( $well->assay_pending and $well->assay_pending <= $assay_result->created_at ) {
        $well->update( { assay_pending => $assay_result->{created_at} } );
    }

    return $assay_result->as_hash;
}


1;

__END__
