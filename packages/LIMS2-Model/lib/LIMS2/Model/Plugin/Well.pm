package LIMS2::Model::Plugin::Well;

use strict;
use warnings FATAL => 'all';

use Moose::Role;
use Hash::MoreUtils qw( slice slice_def );
use Scalar::Util qw( blessed );
use List::MoreUtils qw( before_incl );
use namespace::autoclean;

requires qw( schema check_params throw );

sub check_parent_plate_type {
    my ( $self, $well, $parent_wells ) = @_;

    my $constraint = $well->plate->plate_type . '_parent_plate_type';

    for my $pw ( @{ $parent_wells } ) {
        $self->check_params( { plate_type => $pw->plate->plate_type },
                             { plate_type => { validate => $constraint } } );
    }    
}

sub pspec_create_well {
    return {
        plate_name     => { validate => 'plate_name' },
        well_name      => { validate => 'well_name' },
        created_by     => { validate => 'existing_user', post_filter => 'user_id_for' },
        created_at     => { validate => 'date_time', optional => 1, post_filter => 'parse_date_time' },
        assay_pending  => { validate => 'date_time', optional => 1, post_filter => 'parse_date_time' },
        assay_complete => { validate => 'date_time', optional => 1, post_filter => 'parse_date_time' },
        accepted       => { optional => 1 },
        parent_wells   => { optional => 1, default => [] },
        assay_results  => { optional => 1, default => [] },
        pipeline       => { optional => 1, validate => 'existing_pipeline', post_filter => 'pipeline_id_for' }
    }
}

# Internal function, returns a LIMS2::Model::Schema::Result::Well object
sub _instantiate_well {
    my ( $self, $params ) = @_;

    if ( blessed( $params ) and $params->isa( 'LIMS2::Model::Schema::Result::Well' ) ) {
        return $params;
    }

    my $validated_params = $self->check_params(
        { slice( $params, qw( plate_name well_name ) ) },
        { plate_name => {}, well_name  => {} }
    );
    
    $self->retrieve( Well => $validated_params, { join => 'plate', prefetch => 'plate' } );
}

# Internal function, creates entries in the tree_paths table
sub _create_tree_paths {
    my ( $self, $well, @ancestors ) = @_;

    my ( $insert_tree_paths, @bind_params );
    
    if ( @ancestors ) {
        $self->check_parent_plate_type( $well, \@ancestors );    
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
    my ( $self, $validated_params, $process, $plate ) = @_;

    $plate ||= $self->_instantiate_plate( $validated_params );

    $self->log->debug( '_create_well: ' . $plate->plate_name . '_' . $validated_params->{well_name} );

    my $well = $plate->create_related(
        wells => {
            slice_def( $validated_params, qw( well_name created_by created_at assay_pending ) ),
            process_id => $process->process_id
        }
    );

    $self->log->debug( 'created well with id: ' . $well->well_id );

    $self->_create_tree_paths( $well, map { $self->_instantiate_well( $_ ) } @{ $validated_params->{parent_wells} } );

    if ( $validated_params->{pipeline} ) {
        $process->create_related(
            process_pipeline => { pipeline_id => $validated_params->{pipeline} }
        );        
    }

    for my $assay_result ( @{ $validated_params->{assay_results} } ) {
        $self->add_well_assay_result( $assay_result, $well );
    }    
    
    if ( $validated_params->{assay_complete} ) {
        $self->set_well_assay_complete( { assay_complete => $validated_params->{assay_complete} }, $well );
    }

    if ( $validated_params->{accepted} ) {
        $self->set_well_accepted_override( $validated_params->{accepted}, $well );
    }
    
    return $well;
}

sub pspec_set_well_assay_complete {
    return {
        assay_complete => { validate    => 'date_time',
                            optional    => 1,
                            default     => sub { DateTime->now },
                            post_filter => 'parse_date_time'
                        }
    };
}

sub set_well_assay_complete {
    my ( $self, $params, $well ) = @_;

    $well ||= $self->_instantiate_well( $params );    
    
    my $validated_params = $self->check_params( { slice_def( $params, 'assay_complete' ) },
                                                $self->pspec_set_well_assay_complete );

    # XXX fire trigger to set 'accepted' flag
    
    $well->update( { assay_complete => $validated_params->{assay_complete} } );
}

sub pspec_set_well_accepted_override {
    return {
        accepted   => { validate => 'boolean' },
        created_by => { validate => 'existing_user', post_filter => 'user_id_for' },
        created_at => { validate => 'date_time', post_filter => 'parse_date_time' }
    };    
}

sub set_well_accepted_override {
    my ( $self, $params, $well ) = @_;

    $well ||= $self->_instantiate_well( $params );    

    my $validated_params = $self->check_params(
        { slice_def( $params, qw( accepted created_by created_at ) ) },
        $self->pspec_set_well_accepted_override
    );

    unless ( $well->assay_complete ) {
        $self->throw( InvalidState => 'Cannot override accepted unless assay_complete' );
    }    
    
    $well->search_related_rs( 'well_accepted_override' )->delete;

    my $accepted_override = $well->create_related( well_accepted_override => $validated_params );

    return $accepted_override->as_hash;
}

# XXX These validations do not check that assay/result is a valid combination, only the
# two fields independently
sub pspec_add_well_assay_result {
    return {
        assay      => { validate => 'existing_assay' },
        result     => { validate => 'existing_assay_result' },
        created_by => { validate => 'existing_user', post_filter => 'user_id_for' },
        created_at => { validate => 'date_time', post_filter => 'parse_date_time' }
    };    
}

sub add_well_assay_result {
    my ( $self, $params, $well ) = @_;

    $well ||= $self->_instantiate_well( $params );
    
    my $validated_params = $self->check_params(
        { slice_def( $params, qw( assay result created_by created_at ) ) },
        $self->pspec_add_well_assay_result
    );

    if ( $well->assay_complete ) {
        $self->throw( InvalidState => 'Assay results cannot be added to a well in state assay_complete' );
    }    
    
    my $assay_result = $well->create_related( well_assay_results => $validated_params );

    unless ( $well->assay_pending and $well->assay_pending <= $assay_result->created_at ) {
        $well->update( { assay_pending => $assay_result->created_at } );
    }

    return $assay_result->as_hash;
}

sub pspec_add_well_qc_result {
    return {
        qc_test_result_id => { validate => 'non_empty_string' },
        valid_primers     => { validate => 'comma_separated_list', optional => 1, default => '' },
        pass              => { validate => 'boolean' },
        mixed_reads       => { validate => 'boolean', default => 0 }
    };    
}

sub add_well_qc_result {
    my ( $self, $params, $well ) = @_;

    $well ||= $self->_instantiate_well( $params );

    my $validated_params = $self->check_params( $params, $self->pspec_add_well_qc_result );

    my $qc_result = $well->create_related( well_qc_test_result => $validated_params );

    return $qc_result->as_hash;
}

1;

__END__
