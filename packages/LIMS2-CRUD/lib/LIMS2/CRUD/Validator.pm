package LIMS2::CRUD::Validator;

use strict;
use warnings FATAL => 'all';

use Moose;
use namespace::autoclean;

has message => (
    is      => 'ro',
    isa     => 'Str',
    default => 'failed validation'
);

has validate => (
    is       => 'ro',
    isa      => 'CodeRef',
    traits   => [ 'Code' ],
    handles  => {
        is_valid => 'execute'
    },
    required => 1
);

around BUILDARGS => sub {
    my $orig = shift;
    my $class = shift;

    my $args = $class->$orig(@_);

    my $validate = $args->{validate};
    
    if ( ref $validate eq 'Regexp::Common' ) {
        $args->{validate} = sub { my $v = shift; defined $v and $validate->match($v) };
    }
    elsif ( ref $validate eq 'Regexp' ) {
        $args->{validate} = sub { my $v = shift; defined $v and $v =~ $validate };
    }
    
    return $args;
};                                 

__PACKAGE__->meta->make_immutable;

1;

__END__
