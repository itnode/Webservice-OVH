package Webservice::OVH::Order;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

use Webservice::OVH::Order::Cart;
use Webservice::OVH::Order::Hosting;
use Webservice::OVH::Order::Email;

sub _new {

    my ( $class, $api_wrapper ) = @_;
    
    my $hosting = Webservice::OVH::Order::Hosting->_new($api_wrapper);
    my $email = Webservice::OVH::Order::Email->_new($api_wrapper);

    my $self = bless { _api_wrapper => $api_wrapper, _cards => {}, _hosting => $hosting, _email => $email }, $class;

    return $self;
}

sub new_cart {

    my ( $self, %params ) = @_;

    my $api = $self->{_api_wrapper};
    my $card = Webservice::OVH::Order::Cart->_new( $api, %params );
    return $card;
}

sub carts {

    my ($self) = @_;

    my $api = $self->{_api_wrapper};
    my $response = $api->rawCall( method => 'get', path => "/order/cart", noSignature => 0 );
    croak $response->error if $response->error;

    my $card_ids = $response->content;
    my $cards    = [];

    foreach my $card_id (@$card_ids) {

        my $card = $self->{_cards}{$card_id} = $self->{_cards}{$card_id} || Webservice::OVH::Order::Cart->_new_existing( $api, $card_id );
        push @$cards, $card;
    }

    return $cards;
}

sub cart {

    my ( $self, $card_id ) = @_;

    my $api = $self->{_api_wrapper};
    my $from_array_card = $self->{_cards}{$card_id} if $self->{_cards}{$card_id} && $self->{_cards}{$card_id}->is_valid;
    my $card = $self->{_cards}{$card_id} = $from_array_card || Webservice::OVH::Order::Cart->_new_existing( $api, $card_id );
    return $card;
}

sub hosting {
    
    my ($self) = @_;
    
    return $self->{_hosting};
}

sub email {
    
    my ($self) = @_;
    
    return $self->{_email};
}

1;
