package Webservice::OVH::Order;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

use Webservice::OVH::Order::Card;

sub _new {

    my ( $class, $api_wrapper ) = @_;

    my $self = bless { _api_wrapper => $api_wrapper, _cards => {} }, $class;

    return $self;
}

sub new_card {

    my ( $self, %params ) = @_;

    my $api = $self->{_api_wrapper};
    my $card = Webservice::OVH::Domain::Service->_new( $api, %params );
    return $card;
}

sub cards {

    my ($self) = @_;

    my $api = $self->{_api_wrapper};
    my $response = $api->rawCall( method => 'get', path => "/order/cart", noSignature => 0 );
    croak $response->error if $response->error;

    my $card_ids = $response->content;
    my $cards    = [];

    foreach my $card_id (@$card_ids) {

        my $card = $self->{_cards}{$card_id} = $self->{_cards}{$card_id} || Webservice::OVH::Order::Card->_new_existing( $api, $card_id );
        push @$cards, $card;
    }

    return $cards;
}

sub card {

    my ( $self, $card_id ) = @_;

    my $api = $self->{_api_wrapper};
    my $card = $self->{_cards}{$card_id} = $self->{_cards}{$card_id} || Webservice::OVH::Domain::Service->_new_existing( $api, $card_id );
    return $card;
}

1;
