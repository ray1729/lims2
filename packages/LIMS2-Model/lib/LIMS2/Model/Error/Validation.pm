package LIMS2::Model::Error::Validation;

use strict;
use warnings FATAL => 'all';

use Moose;
use Data::Dump qw( pp );
use namespace::autoclean;

extends qw( LIMS2::Model::Error );

has '+message' => (
    default => 'Parameter validation failed'
);

has results => (
    is       => 'ro',
    isa      => 'Data::FormValidator::Results',
    required => 1
);

has params => (
    is       => 'ro',
    isa      => 'HashRef',
    required => 1
);

override as_string => sub {
    my $self = shift;

    my @errors;
    my $res = $self->results;
    
    if ( $res->has_missing ) {
        for my $f ( $res->missing ) {
            push @errors, "$f, is missing";
        }
    }

    if ( $res->has_invalid ) {
        for my $f ( $res->invalid ) {
            push @errors, "$f, is invalid: " . join q{,}, @{ $res->invalid( $f ) };
        }
    }

    if ( $res->has_unknown ) {
        for my $f ( $res->unknown ) {
            push @errors, "$f, is unknown";
        }
    }

    my $str = join "\n\t", $self->message, @errors;

    $str .= "\n\n" . pp( $self->params );    

    if ( $self->show_stack_trace ) {
        $str .= "\n\n" . $self->stack_trace->as_string;
    }

    return $str;
};

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;

__END__
