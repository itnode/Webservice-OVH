package Webservice::OVH::Order::Card::Item;

use strict;
use warnings;

our $VERSION = 0.1;

sub new {

    my ( $class, $api_wrapper ) = @_;

    my $self = bless { api_wrapper => $api_wrapper, data => {} }, $class;

    return $self;
}

sub delete {

    my ($self) = @_;
}

1;
