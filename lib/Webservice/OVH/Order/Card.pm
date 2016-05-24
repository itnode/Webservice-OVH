package Webservice::OVH::Order::Card;

use strict;
use warnings;

our $VERSION = 0.1;

use Webservice::OVH::Order::Card::Item;

sub new {

    my ( $class, $api_wrapper ) = @_;

    my $self = bless { api_wrapper => $api_wrapper, data => {} }, $class;

    return $self;
}

sub add_domain {

    my ( $self, $domain, %params ) = @_;

}

sub add_transfer {

    my ( $self, $domain, %params ) = @_;
}

sub checkout_info {

    my ($self) = @_;
}

sub checkout {

    my ($self) = @_;
}

sub items {

    my ($self) = @_;

    return [];
}

sub item {

    my ( $self, $item_id ) = @_;

    return undef;
}

sub clear {

    my ($self) = @_;
}

sub delete {

    my ($self) = @_;
}

1;
