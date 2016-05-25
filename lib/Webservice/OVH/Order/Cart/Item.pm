package Webservice::OVH::Order::Cart::Item;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

sub _new {

    my ( $class, $api_wrapper, $cart, $item_id ) = @_;
    
    die "Missing item_id" unless $item_id;
    my $cart_id = $cart->id;
    my $response = $api_wrapper->rawCall( method => 'get', path => "/order/cart/$cart_id/item/$item_id", noSignature => 0 );
    croak $response->error if $response->error;
    
    my $porperties = $response->content;

    my $self = bless { _api_wrapper => $api_wrapper, _id => $item_id, _properties => $porperties, _cart => $cart }, $class;

    return $self;
}

sub cart {
    
    my ($self) = @_;
    
    return $self->{_card};
}

sub id {
    
    my ($self) = @_;
    
    return $self->{_id};
}

sub properties {
    
    my ($self) = @_;
    
    my $api = $self->{_api_wrapper};
    my $cart_id = $self->{_cart}->id;
    my $item_id = $self->id;
    my $response = $api->rawCall( method => 'get', path => "/order/cart/$cart_id/item/$item_id", noSignature => 0 );
    croak $response->error if $response->error;
    
    $self->{_properties} = $response->content;
    return $self->{_properties};
}

sub delete {

    my ($self) = @_;
    
    my $api = $self->{_api_wrapper};
    my $cart_id = $self->{_cart}->id;
    my $item_id = $self->id;
    my $response = $api->rawCall( method => 'delete', path => "/order/cart/$cart_id/item/$item_id", noSignature => 0 );
    croak $response->error if $response->error;
}

1;
