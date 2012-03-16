package LIMS2::Model::Plugin::QcTemplate;

use strict;
use warnings FATAL => 'all';

use Moose::Role;
use Hash::MoreUtils qw( slice slice_def );
use Scalar::Util qw( blessed );
use namespace::autoclean;

requires qw( schema check_params throw );

# Internal function, returns a LIMS2::Model::Schema::Result::QcTemplate object
sub _instantiate_qc_template {
    my ( $self, $params ) = @_;

    if ( blessed( $params ) and $params->isa( 'LIMS2::Model::Schema::Result::QcTemplate' ) ) {
        return $params;
    }
    
    my $validated_params = $self->check_params( 
        { slice( $params, qw( qc_template_name ) ) }, { qc_template_name => {} } );
    
    $self->retrieve( QcTemplate => $validated_params );
}

sub pspec_create_qc_template {
    return {
        plate_name => { validate => 'plate_name', rename => 'qc_template_name' },
        wells      => { optional => 1 }
    }
}

sub create_qc_template {
    my ( $self, $params ) = @_;

    my $validated_params = $self->check_params( $params, $self->pspec_create_qc_template );
    
    my $qc_template = $self->schema->resultset( 'QcTemplate' )->create(
        { slice_def( $validated_params, qw( qc_template_name ) ) }
    );

    while ( my ( $well_name, $well_params ) = each %{ $validated_params->{wells} || {} } ) {
        next unless defined $well_params and keys %{$well_params};
        $well_params->{qc_template_name}      = $validated_params->{qc_template_name};
        $well_params->{qc_template_well_name} = $well_name;
        $self->create_qc_template_well( $well_params, $qc_template );
    }

    return $qc_template;
}

sub pspec_retrieve_qc_template {
    return {
        qc_template_id   => { validate => 'integer', optional => 1 },
        qc_template_name => { validate => 'existing_qc_template_name', optional => 1 },
        REQUIRE_SOME => {
            qc_template_id_or_name => [ 1, qw/qc_template_id qc_template_name/ ],
        }
    }
}

sub retrieve_qc_template {
    my ( $self, $params ) = @_;

    my $validated_params = $self->check_params( $params, $self->pspec_retrieve_qc_template );

    my $qc_template = $self->retrieve( QcTemplate => $validated_params );

    return $qc_template;
}

sub pspec_delete_qc_template {
    return {
        qc_template_id   => { validate => 'integer', optional => 1 },
        qc_template_name => { validate => 'plate_name' },
        REQUIRE_SOME => {
            qc_template_id_or_name => [ 1, qw/qc_template_id qc_template_name/ ],
        }
    };
}

sub delete_qc_template {
    my ( $self, $params ) = @_;

    my $validated_params = $self->check_params( $params, $self->pspec_delete_plate );

    my $qc_template = $self->schema->resultset( 'QcTemplate' )->find( 
        { qc_template_name => $validated_params->{qc_template_name} } );
    $self->throw( 'Plate does not exist: ' . $validated_params->{qc_template_name} ) unless $qc_template;

    $qc_template->delete_this_qc_template;
}

1;

__END__
