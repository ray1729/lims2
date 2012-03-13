package LIMS2::Model::Schema::Extensions::Plate;

use strict;
use warnings FATAL => 'all';

use Moose::Role;
use LIMS2::Model::Error::Database;
use namespace::autoclean;
use Try::Tiny;

with qw( MooseX::Log::Log4perl );

sub as_hash {
    my $self = shift;

    return {
        plate_name => $self->plate_name,
        plate_type => $self->plate_type,
        plate_desc => $self->plate_desc,
        created_at => $self->created_at->iso8601,
        created_by => $self->created_by->user_name,
        comments   => [ map { $_->as_hash } $self->plate_comments ]
    };
}        

# override plate->delete method?
sub delete_this_plate {
    my $self = shift;
    $self->log->info('Deleting Plate: ' . $self->plate_name );
    my @errors;
    my @wells = $self->wells->search(
        {}, { prefetch => [ qw( process process_int_recoms ) ] }

    );

    foreach my $well ( @wells ) {
        try {
            $well->delete_well;
        }
        catch {
            push @errors, $_;
        };
    }

    LIMS2::Model::Error::Database->throw( sprintf "Unable to delete plate %s has following errors:\n%s\n",
                                          $self->plate_name, join("\n", sort @errors) ) if @errors;

    $self->plate_comments->delete;
    $self->delete; 
}

1;

__END__
