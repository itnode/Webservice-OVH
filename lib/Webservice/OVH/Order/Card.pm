package Webservice::OVH::Order::Card;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

use Webservice::OVH::Order::Card::Item;

sub _new_existing {

    my ( $class, $api_wrapper, $card_id ) = @_;

    die "Missing card_id" unless $card_id;
    my $response = $api_wrapper->rawCall( method => 'get', path => "/order/cart/$card_id", noSignature => 0 );
    croak $response->error if $response->error;

    my $properties = $response->content;
    my $self = bless { _api_wrapper => $api_wrapper, _id => $card_id, _properties => $properties, _items => {} }, $class;

    return $self;

}

sub _new {

    my ( $class, $api_wrapper, %params ) = @_;

    croak "Missing ovh_subsidiary";

    my $body = {};
    $body->{description} = $params{description} if exists $params{description};
    $body->{expire}      = $params{expire}      if exists $params{expire};
    $body->{ovhSubsidiary} = $params{ovh_subsidiary};
    my $response = $api_wrapper->rawCall( method => 'post', path => "/order/cart", body => $body, noSignature => 0 );
    croak $response->error if $response->error;

    my $card_id    = $response->content->{cartId};
    my $properties = $response->content;

    my $response_assign = $api_wrapper->rawCall( method => 'post', path => "/order/cart/$card_id/assign ", noSignature => 0 );
    croak $response_assign->error if $response_assign->error;

    my $self = bless { _api_wrapper => $api_wrapper, _id => $card_id, _properties => $properties, _items => {} }, $class;

    return $self;
}

sub change {

    my ( $self, %params ) = @_;

    my $api     = $self->{_api_wrapper};
    my $cart_id = $self->id;

    if ( exists $params{description} || exists $params{expire} ) {

        my $body = {};
        $body->{description} = $params{description} if $params{description};
        $body->{expire}      = $params{expire}      if $params{expire};

        my $response = $api->rawCall( method => 'put', path => "/order/cart/$cart_id", body => $body, noSignature => 0 );
        croak $response->error if $response->error;

        $self->{_properties} = $response->content;
    }
}

sub delete {

    my ($self) = @_;

    my $api     = $self->{_api_wrapper};
    my $cart_id = $self->id;

    my $response = $api->rawCall( method => 'delete', path => "/order/cart/$cart_id", noSignature => 0 );
    croak $response->error if $response->error;
}

sub id {

    my ($self) = @_;

    return $self->{_id},;
}

sub info_domain {

    my ( $self, $domain ) = @_;

    my $api     = $self->{_api_wrapper};
    my $cart_id = $self->id;

    my $response = $api->rawCall( method => 'get', path => "/order/cart/$cart_id/domain", noSignature => 0 );
    croak $response->error if $response->error;

    return $response->content;
}

sub add_domain {

    my ( $self, $domain, %params ) = @_;

    my $api     = $self->{_api_wrapper};
    my $cart_id = $self->id;

    croak "Missing domain parameter" unless $domain;

    my $body = {};
    $body->{duration} = $params{duration} if exists $params{duration};
    $body->{offerId}  = $params{offer_id} if exists $params{offer_id};
    $body->{quantity} = $params{quantity} if exists $params{quantity};

    my $response = $api->rawCall( method => 'post', path => "/order/cart/$cart_id/domain", body => $body, noSignature => 0 );
    croak $response->error if $response->error;

    my $item_id = $response->content->{itemId};
    my $item = Webservice::OVH::Order::Card::Item->_new( $api, $self, $item_id );

    return $item;
}

sub info_domain_transfer {

    my ( $self, $domain ) = @_;

    my $api     = $self->{_api_wrapper};
    my $cart_id = $self->id;

    my $response = $api->rawCall( method => 'get', path => "/order/cart/$cart_id/domainTransfer", noSignature => 0 );
    croak $response->error if $response->error;

    return $response->content;
}

sub add_transfer {

    my ( $self, $domain, %params ) = @_;

    my $api     = $self->{_api_wrapper};
    my $cart_id = $self->id;

    croak "Missing domain parameter" unless $domain;

    my $body = {};
    $body->{duration} = $params{duration} if exists $params{duration};
    $body->{offerId}  = $params{offer_id} if exists $params{offer_id};
    $body->{quantity} = $params{quantity} if exists $params{quantity};

    my $response = $api->rawCall( method => 'post', path => "/order/cart/$cart_id/domainTransfer", body => $body, noSignature => 0 );
    croak $response->error if $response->error;

    my $item_id = $response->content->{itemId};
    my $item = Webservice::OVH::Order::Card::Item->_new( $api, $self, $item_id );

    return $item;
}

sub info_checkout {

    my ($self) = @_;
    
    my $api     = $self->{_api_wrapper};
    my $cart_id = $self->id;

    my $response = $api->rawCall( method => 'get', path => "/order/cart/{cartId}/checkout", noSignature => 0 );
    croak $response->error if $response->error;

    return $response->content;
}

sub checkout {

    my ($self) = @_;
    
    my $api     = $self->{_api_wrapper};
    my $cart_id = $self->id;

    my $response = $api->rawCall( method => 'post', path => "/order/cart/{cartId}/checkout", noSignature => 0 );
    croak $response->error if $response->error;
    
    my $order_id = $response->content->{order_id};
    my $order = Webservice::OVH::Me::Order->_new( $api, $order_id );

    return $order;
}

sub items {

    my ($self) = @_;

    my $api = $self->{_api_wrapper};
    my $cart_id = $self->id;
    my $response = $api->rawCall( method => 'get', path => "/order/cart/$cart_id/item", noSignature => 0 );
    croak $response->error if $response->error;

    my $item_ids = $response->content;
    my $items    = [];

    foreach my $item_id (@$item_ids) {

        my $item = $self->{_items}{$item_id} = $self->{_items}{$item_id} || Webservice::OVH::Order::Card::Item->_new( $api, $self, $item_id );
        push @$items, $item;
    }

    return $items;
}

sub item {

    my ( $self, $item_id ) = @_;

    my $api = $self->{_api_wrapper};
    my $item = $self->{_items}{$item_id} = $self->{_items}{$item_id} || Webservice::OVH::Domain::Service->_new( $api, $self, $item_id );
    return $item;
}

sub clear {

    my ($self) = @_;
    
    my $items = $self->{_items};
    my @items = keys %$items;
    
    foreach my $item (@items) {
        
        $item->delete;
    }
}

1;

