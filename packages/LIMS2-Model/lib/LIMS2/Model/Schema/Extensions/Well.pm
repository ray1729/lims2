package LIMS2::Model::Schema::Extensions::Well;

use strict;
use warnings FATAL => 'all';

use Moose::Role;
use LIMS2::Model::Error::Database;
use namespace::autoclean;
use Smart::Comments;

with qw( MooseX::Log::Log4perl );

sub is_accepted {
    my $self = shift;

    if ( my $o = $self->well_accepted_override ) {
        return $o->accepted;
    }

    return $self->accepted;
}

sub as_hash {
    my $self = shift;

    return {
        plate_name     => $self->plate->plate_name,
        well_name      => $self->well_name,
        created_by     => $self->created_by->user_name,
        created_at     => $self->created_at->iso8601,
        assay_pending  => $self->assay_pending ? $self->assay_pending->iso8601 : '',
        assay_complete => $self->assay_complete ? $self->assay_complete->iso8601 : '',
        accepted       => $self->is_accepted
    };
}

#should I override DBix::Row::delete method?
sub delete_well {
    my $self = shift;
    $self->log->debug('deleting well: ' . $self->well_name );

    my $process_linked_multiple_wells = $self->_check_process_linked_to_multiple_well;

    $self->_check_tree_paths;
    $self->_check_process;
    $self->_delete_sub_process unless $process_linked_multiple_wells;
    $self->_delete_well;


    $self->_delete_process unless $process_linked_multiple_wells;
}

sub _delete_well {
    my $self = shift;

    $self->log->debug('.. deleting well and its related data');
    my @related_well_data = qw( 
        tree_paths_ancestors
        tree_paths_descendants
        well_legacy_qc_test_result
        well_assay_results
        well_accepted_override
    );

    for my $related_data_type ( @related_well_data ) {
        my $related_data_rs = $self->$related_data_type;
        if ( $related_data_rs ) {
            $related_data_rs->delete;
        }
    }
    $self->delete;
}

sub _check_process_linked_to_multiple_well {
    my $self = shift;

    my $linked_wells_rs = $self->process->wells;
    if ( $linked_wells_rs->count == 1 ) {
        return;
    }
    else {
        my @well_names = map { $_->well_name } $linked_wells_rs->all;
        $self->log->info(' .. not deleting process, linked to other well: ' . join(',', @well_names) );
        return 1;
    }
}

sub _check_tree_paths {
    my $self = shift;

    # check for well descendants
    my $descendants_rs = $self->tree_paths_ancestors;
    if ( $descendants_rs->count > 1 ) {
        # this means that well has descendants, cannot delete it
        LIMS2::Model::Error::Database->throw( sprintf 'Well %s (%d) has descendant wells, cannot delete',
                                              $self->well_name, $self->well_id );
    }
    else {
        #just adding this for sanity - can remove later
        my $tree_path = $descendants_rs->next;
        unless ( $tree_path->path_length == 0 ) {
            LIMS2::Model::Error::Database->throw( sprintf 'Well %s (%d) has tree path with length > 0',
                                                  $self->well_name, $self->well_id );
        }
    }
}

sub _check_process {
    my $self = shift;

    #the tree paths check might catch everything, not sure, but lets check the
    #processes we know are linked to wells to be sure
    my @processes = qw( process_2w_gateways process_3w_gateways process_int_recoms process_rearray_source_wells );

    for my $process ( @processes ) {
        my $process_rs = $self->$process;
        if ( $process_rs->count > 0 ) {
            LIMS2::Model::Error::Database->throw( sprintf 'Well %s (%d) has a %s linked to it, cannot delete',
                                                  $self->well_name, $self->well_id, $process );
        }
    }
}

sub _delete_sub_process {
    my $self = shift;

    #delete the process and any rows tied into this
    my $process = $self->process;
    my $process_type = $process->process_type->process_type;
    my $sub_process = $process->get_process; 

    if ( $process_type eq 'rearray' ) {
        $self->log->debug('.. deleting rearray process');
        $sub_process->process_rearray_source_wells->delete;
        $sub_process->delete; # can we get this to cascade delete the process_rearray_source_wells
    }
    elsif ( $process_type eq 'int_recom' ) {
        $self->log->debug('.. deleting int_recom process');
        $sub_process->delete;
    } 
    else {
        LIMS2::Model::Error::Database->throw( sprintf 'Well %s (%d) is from a %s, unable to delete yet',
                                              $self->well_name, $self->well_id, $process_type );
    }
}

sub _delete_process {
    my $self = shift;

    my $process = $self->process;
    $self->log->debug('.. deleting process');
    my $process_pipeline = $process->process_pipeline;
    $process_pipeline->delete if $process_pipeline;

    #check and delete any synthetic_construct processes
    if ( my $synth_construct_process = $process->process_synthetic_construct ) {
        $synth_construct_process->delete;
    }

    $process->delete;
}

1;

__END__
