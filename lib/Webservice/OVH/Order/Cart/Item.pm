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

    my $self = bless { _valid => 1, _api_wrapper => $api_wrapper, _id => $item_id, _properties => $porperties, _cart => $cart }, $class;

    return $self;
}

sub is_valid {

    my ($self) = @_;

    return $self->{_valid};
}

sub _is_valid {

    my ($self) = @_;

    my $item_id = $self->id;
    carp "Item $item_id is not valid anymore" unless $self->is_valid;
    return $self->is_valid;
}

sub cart {

    my ($self) = @_;

    return $self->{_cart};
}

sub id {

    my ($self) = @_;

    return $self->{_id};
}

sub properties {

    my ($self) = @_;

    return unless $self->_is_valid;

    my $api      = $self->{_api_wrapper};
    my $cart_id  = $self->{_cart}->id;
    my $item_id  = $self->id;
    my $response = $api->rawCall( method => 'get', path => "/order/cart/$cart_id/item/$item_id", noSignature => 0 );
    croak $response->error if $response->error;

    $self->{_properties} = $response->content;
    return $self->{_properties};
}

sub configurations {
    
    my ($self) = @_;
    
    return $self->{_properties}->{configurations};
}

sub duration {
    
    my ($self) = @_;
    
    return $self->{_properties}->{duration};
}

sub offer_id {
    
    my ($self) = @_;
    
    return $self->{_properties}->{offerId};
}

sub options {
    
    my ($self) = @_;
    
    return $self->{_properties}->{options};
}

sub prices {
    
    my ($self) = @_;
    
    return $self->{_properties}->{prices};
}

sub product_id {
    
    my ($self) = @_;
    
    return $self->{_properties}->{productId};
}

sub settings {
    
    my ($self) = @_;
    
    return $self->{_properties}->{settings};
}

sub available_configuration {
    
    my ($self) = @_;
    
    return unless $self->_is_valid;
    
    my $api      = $self->{_api_wrapper};
    my $cart_id  = $self->{_cart}->id;
    my $item_id  = $self->id;
    
    my $response = $api->rawCall( method => 'get', path => "/order/cart/$cart_id/item/$item_id/configuration", noSignature => 0 );
    croak $response->error if $response->error;
    
    return $response->content;
}

sub delete {

    my ($self) = @_;

    return unless $self->_is_valid;

    my $api      = $self->{_api_wrapper};
    my $cart_id  = $self->{_cart}->id;
    my $item_id  = $self->id;
    my $response = $api->rawCall( method => 'delete', path => "/order/cart/$cart_id/item/$item_id", noSignature => 0 );
    croak $response->error if $response->error;

    $self->{_valid} = 0;
}

1;
